const { sequelize } = require('../config/database');

async function testUpdate() {
  try {
    const contactId = 4; // Use ID from logs
    const newPosId = 6;  // Biomedical Engineer
    
    console.log(`Testing raw SQL update for contact ${contactId} to position ${newPosId}...`);
    
    const query = `
      UPDATE customer_contacts 
      SET 
        positionId = ?, 
        updatedAt = NOW() 
      WHERE id = ?
    `;

    const [result] = await sequelize.query(query, { replacements: [newPosId, contactId] });
    console.log('Update result:', result);

    const [rows] = await sequelize.query('SELECT positionId FROM customer_contacts WHERE id = ?', { replacements: [contactId] });
    console.log('Check after update:', rows[0]);

    process.exit(0);
  } catch (err) {
    console.error('Update failed:', err);
    process.exit(1);
  }
}

testUpdate();
