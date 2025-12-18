
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const User = require('./models/User');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// MongoDB Connection
mongoose.connect('mongodb://127.0.0.1:27017/appquanlytaichinh', {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
    .then(() => console.log('MongoDB Connected'))
    .catch(err => console.log(err));

// Routes

// Register
app.post('/api/auth/register', async (req, res) => {
    const { email, password, phone } = req.body;
    try {
        // Check if user exists
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ success: false, message: 'Email đã tồn tại' });
        }

        const newUser = new User({
            email,
            password, // Note: In production, hash this password!
            phone,
            name: email.split('@')[0]
        });

        await newUser.save();
        res.json({ success: true, user: { id: newUser._id, email: newUser.email, name: newUser.name, phone: newUser.phone } });
    } catch (err) {
        console.log(err);
        res.status(500).json({ success: false, message: 'Lỗi Server' });
    }
});

// Login
app.post('/api/auth/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const user = await User.findOne({ email, password });
        if (!user) {
            return res.status(401).json({ success: false, message: 'Sai email hoặc mật khẩu' });
        }
        res.json({ success: true, user: { id: user._id, email: user.email, name: user.name, phone: user.phone || '' } });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi Server' });
    }
});

// Change Password
app.post('/api/auth/change-password', async (req, res) => {
    const { email, oldPassword, newPassword } = req.body;
    try {
        const user = await User.findOne({ email, password: oldPassword });
        if (!user) {
            return res.status(401).json({ success: false, message: 'Mật khẩu cũ không đúng' });
        }
        user.password = newPassword;
        await user.save();
        res.json({ success: true, message: 'Đổi mật khẩu thành công' });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi Server' });
    }
});

const Category = require('./models/Category');
const Transaction = require('./models/Transaction');

// ... (Existing middlewares)

// Routes

// --- Auth Routes (Keep existing) ---
// Register...
// Login...
// Change Password...

// --- Category Routes ---
app.get('/api/categories', async (req, res) => {
    try {
        // Get default categories + user specific categories (if any implementation later)
        // For now, let's just seed some defaults if empty
        const count = await Category.countDocuments();
        if (count === 0) {
            const defaults = [
                { name: 'Ăn uống', type: 'expense', icon: 'restaurant', isDefault: true },
                { name: 'Di chuyển', type: 'expense', icon: 'directions_car', isDefault: true },
                { name: 'Nhà cửa', type: 'expense', icon: 'home', isDefault: true },
                { name: 'Giải trí', type: 'expense', icon: 'movie', isDefault: true },
                { name: 'Mua sắm', type: 'expense', icon: 'shopping_bag', isDefault: true },
                { name: 'Lương', type: 'income', icon: 'attach_money', isDefault: true },
                { name: 'Thưởng', type: 'income', icon: 'card_giftcard', isDefault: true },
                { name: 'Khác', type: 'income', icon: 'more_horiz', isDefault: true },
            ];
            await Category.insertMany(defaults);
        }

        const categories = await Category.find();
        res.json({ success: true, data: categories });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi lấy danh mục' });
    }
});

// --- Transaction Routes ---

// Get all transactions for a user
app.get('/api/transactions/:userId', async (req, res) => {
    try {
        const transactions = await Transaction.find({ user: req.params.userId })
            .populate('category')
            .sort({ date: -1 }); // Newest first
        res.json({ success: true, data: transactions });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi lấy giao dịch' });
    }
});

// Add Transaction
app.post('/api/transactions', async (req, res) => {
    try {
        const { userId, categoryId, amount, type, date, note, tags } = req.body;

        const newTrans = new Transaction({
            user: userId,
            category: categoryId,
            amount,
            type,
            date: date || Date.now(),
            note,
            tags: tags || []
        });

        await newTrans.save();
        // Populate category info for immediate UI update
        await newTrans.populate('category');

        res.json({ success: true, data: newTrans });
    } catch (err) {
        console.log(err);
        res.status(500).json({ success: false, message: 'Lỗi thêm giao dịch' });
    }
});

// Update Transaction (Basic)
app.put('/api/transactions/:id', async (req, res) => {
    try {
        const updated = await Transaction.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true }
        ).populate('category');
        res.json({ success: true, data: updated });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi cập nhật' });
    }
});

// Delete Transaction
app.delete('/api/transactions/:id', async (req, res) => {
    try {
        await Transaction.findByIdAndDelete(req.params.id);
        res.json({ success: true, message: 'Đã xóa' });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi xóa giao dịch' });
    }
});

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
