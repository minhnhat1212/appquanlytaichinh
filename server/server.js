
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
        res.json({ success: true, user: { email: newUser.email, name: newUser.name, phone: newUser.phone } });
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
        res.json({ success: true, user: { email: user.email, name: user.name, phone: user.phone || '' } });
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

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
