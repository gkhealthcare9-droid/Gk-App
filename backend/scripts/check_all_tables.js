const { sequelize } = require('../config/database');

async function checkAll() {
  try {
    await sequelize.authenticate();
    console.log('Database connected');

    const [tables] = await sequelize.query('SHOW TABLES');
    const tableKey = Object.keys(tables[0])[0];
    
    console.log('--- Table Row Counts ---');
    for (const row of tables) {
      const tableName = row[tableKey];
      const [counts] = await sequelize.query(`SELECT COUNT(*) as count FROM \`${tableName}\``);
      const count = counts[0].count;
      console.log(`${tableName}: ${count}`);
    }
  } catch (err) {
    console.error('Check failed:', err.message);
  } finally {
    process.exit();
  }
}

checkAll();
