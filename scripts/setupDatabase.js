const mysql = require('mysql2/promise');
require('dotenv').config();

async function setupDatabase() {
  let connection;

  try {
    // Connect to MySQL without specifying database
    connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      port: process.env.DB_PORT
    });

    console.log('Connected to MySQL');

    // Create database if it doesn't exist
    const dbName = process.env.DB_NAME;
    await connection.execute(`CREATE DATABASE IF NOT EXISTS ${dbName}`);
    console.log(`Database '${dbName}' created or already exists`);

    // Switch to the database
    await connection.execute(`USE ${dbName}`);
    console.log(`Using database '${dbName}'`);

    // Create schools table
    const createTableQuery = `
      CREATE TABLE IF NOT EXISTS schools (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        address VARCHAR(500) NOT NULL,
        latitude FLOAT NOT NULL,
        longitude FLOAT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_location (latitude, longitude)
      )
    `;

    await connection.execute(createTableQuery);
    console.log('Schools table created or already exists');

    // Insert sample data
    const sampleSchools = [
      ['Lincoln High School', '123 Main St, Springfield', 39.7817, -89.6501],
      ['Central Middle School', '456 Oak Ave, Springfield', 39.7892, -89.6432],
      ['North Elementary School', '789 Pine Rd, Springfield', 39.8045, -89.6789],
      ['South Academy', '321 Elm St, Springfield', 39.7634, -89.6234],
      ['East Preparatory School', '654 Maple Dr, Springfield', 39.7945, -89.6045]
    ];

    for (const school of sampleSchools) {
      const checkQuery = 'SELECT id FROM schools WHERE name = ?';
      const [existing] = await connection.execute(checkQuery, [school[0]]);

      if (existing.length === 0) {
        const insertQuery = 'INSERT INTO schools (name, address, latitude, longitude) VALUES (?, ?, ?, ?)';
        await connection.execute(insertQuery, school);
        console.log(`Inserted sample school: ${school[0]}`);
      }
    }

    console.log('\n✓ Database setup completed successfully!');

  } catch (err) {
    console.error('Error setting up database:', err);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// Run setup
setupDatabase();
