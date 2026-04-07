const bcrypt = require('bcryptjs');
const { Sequelize, DataTypes } = require('sequelize');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '..', '.env') });

const sequelize = process.env.MYSQL_URL
  ? new Sequelize(process.env.MYSQL_URL, { logging: false })
  : new Sequelize(
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

    const admins = [
      { name: 'GK Healthcare', email: 'gkhealthcare@gmail.com', password: '440412', phone: '1111111111' },
      { name: 'Dlevith', email: 'dlevith@gmail.com', password: '7004189', phone: '2222222222' },
      { name: 'Mounesh', email: 'mounesh@gmail.com', password: '445862', phone: '3333333333' },
      { name: 'Chandrama', email: 'chandrama@gmail.com', password: '778455', phone: '4444444444' }
    ];

    for (const admin of admins) {
      const hashedPassword = await bcrypt.hash(admin.password, 10);
      const [user, created] = await User.findOrCreate({
        where: { email: admin.email },
        defaults: {
          name: admin.name,
          phone: admin.phone,
          password: hashedPassword,
          userType: 'admin'
        }
      });

      if (created) {
        console.log(`Admin ${admin.email} created successfully.`);
      } else {
        user.password = hashedPassword;
        user.name = admin.name;
        user.userType = 'admin';
        await user.save();
        console.log(`Admin ${admin.email} updated.`);
      }
    }

    process.exit(0);
  } catch (err) {
    console.error('Error:', err);
    process.exit(1);
  }
}

run();
