
const mongoose = require('mongoose');
const { Schema } = mongoose;



// Purchase Schema
const purchaseSchema = new Schema({
  purchaseId: { type: String, required: true, unique: true },
  customerId: { type: String, required: true },
  timestamp: { type: Date, required: true, default: Date.now },
  amount: { type: Number, required: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});




const Purchase = mongoose.model('Purchase', purchaseSchema);

module.exports = { Purchase };

