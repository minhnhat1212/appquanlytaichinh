
const mongoose = require('mongoose');

const TransactionSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    category: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Category',
        required: true
    },
    amount: {
        type: Number,
        required: true
    },
    type: {
        type: String, // 'income' or 'expense'
        required: true
    },
    date: {
        type: Date,
        default: Date.now
    },
    note: {
        type: String,
        default: ''
    },
    tags: [{
        type: String
    }],
    currency: {
        type: String,
        default: 'VND'
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Transaction', TransactionSchema);
