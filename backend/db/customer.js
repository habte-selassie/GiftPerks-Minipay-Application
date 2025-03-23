
const mongoose = require('mongoose');
const { Schema } = mongoose;

// Customer Schema
const customerSchema = new Schema({
  customerId: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  email: { type: String, required: true },
  phoneNumber: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});


const Customer = mongoose.model('Customer', customerSchema);

module.exports = { Customer, Purchase, GiftCard };

