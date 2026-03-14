const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  itemId: { type: mongoose.Schema.Types.ObjectId, ref: 'Item', required: true },
  senderUsername: { type: String, required: true },
  text: { type: String, required: true },
  date: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Message', messageSchema);
