const { sequelize } = require('./config/database');
const User = require('./Models/User/User');

async function check() {
  try {
    await sequelize.authenticate();
    console.log('Database connected');
    const userCount = await User.count().catch(() => -1);
    if (userCount === -1) {
      console.log('Tables do not exist');
      await sequelize.sync({ alter: true });
      console.log('Tables created');
    } else {
      console.log(`Found ${userCount} users`);
    }
  } catch (err) {
    console.error('Check failed:', err.message);
  } finally {
    process.exit();
  }
}

check();
