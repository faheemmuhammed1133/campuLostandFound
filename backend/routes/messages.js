const express = require('express');
const router = express.Router();
const Message = require('../models/Message');
const Item = require('../models/Item');
const Claim = require('../models/Claim');
const Notification = require('../models/Notification');

// GET conversations for a user (items where they have sent messages, excluding items they posted)
router.get('/conversations', async (req, res) => {
  try {
    const { username } = req.query;
    if (!username) {
      return res.status(400).json({ error: 'username query param is required' });
    }

    // Find distinct itemIds where this user has sent messages
    const itemIds = await Message.distinct('itemId', { senderUsername: username });

    // Get those items (excluding items posted by this user)
    const items = await Item.find({
      _id: { $in: itemIds },
      postedBy: { $ne: username },
    }).sort({ date: -1 });

    // Also include items posted by others where this user participated
    // Plus items posted by this user where others have messaged
    const ownItemIds = await Message.distinct('itemId');
    const ownItems = await Item.find({
      _id: { $in: ownItemIds },
      postedBy: username,
    }).sort({ date: -1 });

    // Merge and deduplicate
    const allItems = [...items, ...ownItems];
    const seen = new Set();
    const uniqueItems = allItems.filter(item => {
      const id = item._id.toString();
      if (seen.has(id)) return false;
      seen.add(id);
      return true;
    });

    // For each item, get the last message
    const result = [];
    for (const item of uniqueItems) {
      const lastMessage = await Message.findOne({ itemId: item._id }).sort({ date: -1 });
      // Only include if this user has actually sent at least one message
      const userSent = await Message.findOne({ itemId: item._id, senderUsername: username });
      if (userSent) {
        result.push({
          item: item,
          lastMessage: lastMessage,
        });
      }
    }

    // Sort by last message date descending
    result.sort((a, b) => b.lastMessage.date - a.lastMessage.date);

    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET messages for an item
router.get('/', async (req, res) => {
  try {
    const { itemId } = req.query;
    if (!itemId) {
      return res.status(400).json({ error: 'itemId query param is required' });
    }
    const messages = await Message.find({ itemId }).sort({ date: 1 });
    res.json(messages);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST send a message
router.post('/', async (req, res) => {
  try {
    const { itemId, senderUsername, text } = req.body;
    if (!itemId || !senderUsername || !text) {
      return res.status(400).json({ error: 'itemId, senderUsername, and text are required' });
    }

    const message = new Message({ itemId, senderUsername, text });
    await message.save();

    // Notify all other participants
    const item = await Item.findById(itemId);
    if (item) {
      const claims = await Claim.find({ itemId });
      const participants = new Set();
      participants.add(item.postedBy);
      if (item.foundBy) participants.add(item.foundBy);
      claims.forEach((c) => participants.add(c.claimerUsername));
      participants.delete(senderUsername);

      for (const recipient of participants) {
        await Notification.create({
          recipientUsername: recipient,
          message: `New message from ${senderUsername} about '${item.title}'`,
          itemId: item._id,
          type: 'new_message',
        });
      }
    }

    res.status(201).json(message);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
