const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const { validateAddSchool, validateListSchools } = require('../utils/validators');
const { calculateDistance } = require('../utils/distance');

/**
 * POST /addSchool
 * Add a new school to the database
 */
router.post('/addSchool', async (req, res) => {
  try {
    const { error, value } = validateAddSchool(req.body);

    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        details: error.details.map(d => d.message)
      });
    }

    const { name, address, latitude, longitude } = value;
    const connection = await pool.getConnection();

    try {
      const query = 'INSERT INTO schools (name, address, latitude, longitude) VALUES (?, ?, ?, ?)';
      const [result] = await connection.execute(query, [name, address, latitude, longitude]);

      res.status(201).json({
        success: true,
        message: 'School added successfully',
        data: {
          id: result.insertId,
          name,
          address,
          latitude,
          longitude
        }
      });
    } finally {
      connection.release();
    }
  } catch (err) {
    console.error('Error adding school:', err);
    res.status(500).json({
      success: false,
      message: 'Error adding school',
      error: err.message
    });
  }
});

/**
 * GET /listSchools
 * Get all schools sorted by proximity to user location
 */
router.get('/listSchools', async (req, res) => {
  try {
    const { latitude, longitude } = req.query;
    const { error, value } = validateListSchools({ latitude: parseFloat(latitude), longitude: parseFloat(longitude) });

    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        details: error.details.map(d => d.message)
      });
    }

    const connection = await pool.getConnection();

    try {
      const query = 'SELECT id, name, address, latitude, longitude FROM schools';
      const [schools] = await connection.execute(query);

      // Calculate distance and add to each school
      const schoolsWithDistance = schools.map(school => ({
        ...school,
        distance: calculateDistance(value.latitude, value.longitude, school.latitude, school.longitude)
      }));

      // Sort by distance
      schoolsWithDistance.sort((a, b) => a.distance - b.distance);

      res.status(200).json({
        success: true,
        message: 'Schools retrieved successfully',
        userLocation: {
          latitude: value.latitude,
          longitude: value.longitude
        },
        count: schoolsWithDistance.length,
        data: schoolsWithDistance
      });
    } finally {
      connection.release();
    }
  } catch (err) {
    console.error('Error fetching schools:', err);
    res.status(500).json({
      success: false,
      message: 'Error fetching schools',
      error: err.message
    });
  }
});

module.exports = router;
