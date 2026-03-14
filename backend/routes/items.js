const express = require('express');
const router = express.Router();
const Item = require('../models/Item');
const Claim = require('../models/Claim');
const Notification = require('../models/Notification');
const Message = require('../models/Message');

router.get('/', async (req, res) => {
  try {
    const items = await Item.find().sort({ date: -1 });
    res.json(items);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const item = await Item.findById(req.params.id);
    if (!item) return res.status(404).json({ error: 'Item not found' });
    res.json(item);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const { title, description, location, imageBase64, type, postedBy } = req.body;
    const item = new Item({ title, description, location, imageBase64, type, postedBy });
    await item.save();
    res.status(201).json(item);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.put('/:id/mark-found', async (req, res) => {
  try {
    const { foundBy } = req.body;
    if (!foundBy) {
      return res.status(400).json({ error: 'foundBy username is required' });
    }

    const item = await Item.findByIdAndUpdate(
      req.params.id,
      { type: 'found', foundBy: foundBy },
      { new: true }
    );
    if (!item) return res.status(404).json({ error: 'Item not found' });

    // Notify the original poster
    if (item.postedBy !== foundBy) {
      await Notification.create({
        recipientUsername: item.postedBy,
        message: `Your item '${item.title}' has been found by ${foundBy}!`,
        itemId: item._id,
        type: 'item_found',
      });
    }

    res.json(item);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const item = await Item.findByIdAndDelete(req.params.id);
    if (!item) return res.status(404).json({ error: 'Item not found' });
    await Claim.deleteMany({ itemId: req.params.id });
    await Message.deleteMany({ itemId: req.params.id });
    await Notification.deleteMany({ itemId: req.params.id });
    res.json({ message: 'Item deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
