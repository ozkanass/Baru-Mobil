const bcrypt = require('bcrypt');

async function generateHash(password) {
  const saltRounds = 12;
  const hash = await bcrypt.hash(password, saltRounds);
  console.log('Password Hash:', hash);
}

// Örnek şifre için hash oluştur
generateHash('Club123!');