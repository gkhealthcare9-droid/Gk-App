const { User } = require('./Models/User/User');
const { sequelize } = require('./config/database');

async function listUsers() {
  try {
    const User = require('./Models/User/User');
    const users = await User.findAll();
    console.log('--- Users in Database ---');
    users.forEach(user => {
      console.log(`ID: ${user.id}, Name: ${user.name}, Email: ${user.email}, Type: ${user.userType}`);
    });
    process.exit(0);
  } catch (err) {
    console.error('Error listing users:', err);
    process.exit(1);
  }
}

listUsers();
