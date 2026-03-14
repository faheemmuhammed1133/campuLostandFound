const mongoose = require('mongoose');

const claimSchema = new mongoose.Schema({
  itemId: { type: mongoose.Schema.Types.ObjectId, ref: 'Item', required: true },
  claimerUsername: { type: String, required: true },
  description: { type: String, required: true },
  status: { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
  date: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Claim', claimSchema);
