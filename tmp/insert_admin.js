const bcrypt = require('bcryptjs');
const { Sequelize, DataTypes } = require('sequelize');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '..', 'backend', '.env') });

const sequelize = new Sequelize(
  process.env.DB_NAME || 'gk_healthcare',
  process.env.DB_USER || 'root',
  process.env.DB_PASSWORD || '',
  {
    host: process.env.DB_HOST || 'localhost',
    dialect: 'mysql',
    logging: false,
  }
);

const User = sequelize.define('User', {
  id: { type: DataTypes.BIGINT, primaryKey: true, autoIncrement: true },
  name: { type: DataTypes.STRING, allowNull: false },
  phone: { type: DataTypes.STRING, allowNull: false, unique: true },
  email: { type: DataTypes.STRING, allowNull: false, unique: true },
  password: { type: DataTypes.STRING, allowNull: false },
  userType: { type: DataTypes.ENUM('admin', 'user'), defaultValue: 'user' },
}, { timestamps: true, tableName: 'users' });

async function run() {
  try {
    await sequelize.authenticate();
    console.log('Database connected.');

    const name = 'gkadmin';
    const email = 'admin@gmail.com';
    const password = '@gk213';
    const phone = '0000000000'; // Dummy phone as it's NOT NULL and UNIQUE

    const hashedPassword = await bcrypt.hash(password, 10);

    const [user, created] = await User.findOrCreate({
      where: { email },
      defaults: {
        name,
        phone,
        password: hashedPassword,
        userType: 'admin'
      }
    });

    if (created) {
      console.log('Admin user created successfully.');
    } else {
      user.password = hashedPassword;
      user.name = name;
      user.userType = 'admin';
      await user.save();
      console.log('Admin user updated (password/name refreshed).');
    }

    process.exit(0);
  } catch (err) {
    console.error('Error:', err);
    process.exit(1);
  }
}

run();
