
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
// Get Categories (Default + User Custom)
app.get('/api/categories', async (req, res) => {
    try {
        const { userId } = req.query;

        // Logic: Find categories where (isDefault = true) OR (user = userId)
        // Note: If userId is not provided, returns only defaults.

        const query = {
            $or: [
                { isDefault: true },
                ...(userId ? [{ user: userId }] : [])
            ]
        };

        // Seed defaults logic (Keep existing but simplified)
        const count = await Category.countDocuments({ isDefault: true });
        if (count === 0) {
            // ... existing seed code ...
            const defaults = [
                { name: 'Ăn uống', type: 'expense', icon: 'restaurant', color: '0xFFE57373', isDefault: true },
                { name: 'Di chuyển', type: 'expense', icon: 'directions_car', color: '0xFF64B5F6', isDefault: true },
                { name: 'Nhà cửa', type: 'expense', icon: 'home', color: '0xFFFFB74D', isDefault: true },
                { name: 'Giải trí', type: 'expense', icon: 'movie', color: '0xFFBA68C8', isDefault: true },
                { name: 'Mua sắm', type: 'expense', icon: 'shopping_bag', color: '0xFF4DB6AC', isDefault: true },
                { name: 'Lương', type: 'income', icon: 'attach_money', color: '0xFF81C784', isDefault: true },
                { name: 'Thưởng', type: 'income', icon: 'card_giftcard', color: '0xFFAED581', isDefault: true },
                { name: 'Khác', type: 'income', icon: 'more_horiz', color: '0xFFE0E0E0', isDefault: true },
            ];
            await Category.insertMany(defaults);
        }

        const categories = await Category.find(query);
        res.json({ success: true, data: categories });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi lấy danh mục' });
    }
});

// Add User Category
app.post('/api/categories', async (req, res) => {
    try {
        const { name, type, icon, color, userId } = req.body;
        const newCat = new Category({
            name, type, icon, color,
            user: userId,
            isDefault: false
        });
        await newCat.save();
        res.json({ success: true, data: newCat });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi tạo danh mục' });
    }
});

// Delete User Category
app.delete('/api/categories/:id', async (req, res) => {
    try {
        // Prevent deleting defaults just in case (though UI should handle)
        const cat = await Category.findById(req.params.id);
        if (cat && cat.isDefault) {
            return res.status(403).json({ success: false, message: 'Không thể xóa danh mục mặc định' });
        }

        await Category.findByIdAndDelete(req.params.id);
        res.json({ success: true, message: 'Đã xóa danh mục' });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Lỗi xóa danh mục' });
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
