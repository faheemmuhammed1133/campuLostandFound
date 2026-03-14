const mongoose = require('mongoose');

const itemSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, required: true },
  location: { type: String, required: true },
  imageBase64: { type: String, default: null },
  type: { type: String, enum: ['lost', 'found'], required: true },
  postedBy: { type: String, required: true },
  foundBy: { type: String, default: null },
  status: { type: String, enum: ['active', 'resolved'], default: 'active' },
  date: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Item', itemSchema);
