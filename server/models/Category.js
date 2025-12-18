
const mongoose = require('mongoose');

const CategorySchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    type: {
        type: String, // 'income' or 'expense'
        required: true
    },
    icon: {
        type: String, // Store icon code or name
        default: 'help_outline'
    },
    color: {
        type: String, // Hex code
        default: '0xFF000000'
    },
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        default: null // null means global/default category
    },
    isDefault: {
        type: Boolean,
        default: false
    }
});

module.exports = mongoose.model('Category', CategorySchema);
