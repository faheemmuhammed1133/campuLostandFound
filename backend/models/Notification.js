const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  recipientUsername: { type: String, required: true },
  message: { type: String, required: true },
  itemId: { type: mongoose.Schema.Types.ObjectId, ref: 'Item', default: null },
  type: {
    type: String,
    enum: ['item_found', 'claim_submitted', 'claim_approved', 'claim_rejected', 'new_message'],
    required: true,
  },
  isRead: { type: Boolean, default: false },
  date: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Notification', notificationSchema);
