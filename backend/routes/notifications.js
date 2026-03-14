const express = require('express');
const router = express.Router();
const Notification = require('../models/Notification');

// GET notifications for a user
router.get('/', async (req, res) => {
  try {
    const { username } = req.query;
    if (!username) {
      return res.status(400).json({ error: 'username query param is required' });
    }
    const notifications = await Notification.find({ recipientUsername: username })
      .sort({ date: -1 });
    res.json(notifications);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT mark a single notification as read
router.put('/:id/read', async (req, res) => {
  try {
    const notification = await Notification.findByIdAndUpdate(
      req.params.id,
      { isRead: true },
      { new: true }
    );
    if (!notification) return res.status(404).json({ error: 'Notification not found' });
    res.json(notification);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT mark all notifications as read for a user
router.put('/read-all', async (req, res) => {
  try {
    const { username } = req.query;
    if (!username) {
      return res.status(400).json({ error: 'username query param is required' });
    }
    await Notification.updateMany(
      { recipientUsername: username, isRead: false },
      { isRead: true }
    );
    res.json({ message: 'All notifications marked as read' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
