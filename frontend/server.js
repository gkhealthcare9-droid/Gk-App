const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 8080;

// Serve static files from the build/web directory
app.use(express.static(path.join(__dirname, 'build', 'web')));

// Handle all roots by serving index.html (useful for Flutter routing)
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'web', 'index.html'));
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Flutter Web Server is running on port ${PORT}`);
});
