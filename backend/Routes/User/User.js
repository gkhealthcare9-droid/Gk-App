const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../../Models/User/User");
const userAuth = require("../../Middleware/auth");
const router = express.Router();
const { Op } = require("sequelize");

// Add User
router.post("/add", async (req, res) => {
  try {
    const { name, phone, email, password, DOJ, userType, positionId } =
      req.body;

    const existing = await User.findOne({
      where: {
        [Op.or]: [{ email }, { phone }],
      },
    });

    if (existing)
      return res.status(400).json({ message: "User already exists" });

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = await User.create({
      name,
      phone,
      email,
      password: hashedPassword,
      doj: DOJ,
      userType: userType || "user",
      positionId: positionId,
    });

    res.status(201).json({ message: "User created", userId: newUser.id });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

// Login
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ where: { email } });
    if (!user) return res.status(400).json({ message: "Invalid credentials" });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch)
      return res.status(400).json({ message: "Invalid credentials" });

    const token = jwt.sign(
      {
        id: user.id,
        userType: user.userType,
        name: user.name,
        email: user.email,
      },
      process.env.JWT_SECRET,
      { expiresIn: "7d" },
    );

    user.lastLogin = new Date();
    await user.save();

    res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        userType: user.userType,
      },
    });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

// Get Profile (Protected)
router.get("/profile", userAuth, async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id, {
      attributes: { exclude: ["password"] },
    });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

const Category = require("../../Models/Classification/Category");

// Get All (Filtered for non-admin staff)
router.get("/all", userAuth, async (req, res) => {
  try {
    // Strictly only the Master Admin (ID 1 or "GK Healthcare") can see all staff profiles.
    // Other admins (Level 2) should only see the 'user' records.
    const isMainAdmin =
      req.user.id === 1 ||
      req.user.id === "1" ||
      (req.user.name && req.user.name.toUpperCase() === "GK HEALTHCARE");
    console.log(
      `Fetching staff list for User ${req.user.id} (${req.user.name}) - isMainAdmin: ${isMainAdmin}`,
    );

    const users = await User.findAll({
      where: isMainAdmin
        ? {}
        : {
            [Op.or]: [{ userType: "user" }, { name: "GK Healthcare" }],
          },
      attributes: { exclude: ["password"] },
      include: [{ model: Category, as: "position" }],
    });
    res.json(users);
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

// Update User
router.put("/:id", userAuth, async (req, res) => {
  try {
    const { name, phone, email, positionId } = req.body;
    const user = await User.findByPk(req.params.id);

    if (!user) return res.status(404).json({ message: "User not found" });

    user.name = name || user.name;
    user.phone = phone || user.phone;
    user.email = email || user.email;
    user.positionId = positionId || user.positionId;

    await user.save();
    res.json({ message: "User updated successfully", user });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

// Delete User
router.delete("/:id", userAuth, async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ message: "User not found" });

    await user.destroy();
    res.json({ message: "User deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: "Server error", error: err.message });
  }
});

module.exports = router;
