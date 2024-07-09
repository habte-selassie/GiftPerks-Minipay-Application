
const mongoose = require('mongoose');
const { Schema } = mongoose;

// Gift Card Schema
const giftCardSchema = new Schema({
  cardId: { type: String, required: true, unique: true },
  customerId: { type: String, required: true },
  tokenId: { type: String, required: true, unique: true },
  issueDate: { type: Date, required: true, default: Date.now },
  balance: { type: Number, required: true },
  isActive: { type: Boolean, required: true, default: true },
  sender: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

const GiftCard = mongoose.model('GiftCard', giftCardSchema);

module.exports = { Customer, Purchase, GiftCard };

