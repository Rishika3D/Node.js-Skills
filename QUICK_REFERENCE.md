# School Management API - Quick Reference Guide

## Installation & Running

```bash
# 1. Clone and setup
git clone https://github.com/Rishika3D/Node.js-Skills.git
cd Node.js-Skills
npm install

# 2. Configure .env with your MySQL credentials

# 3. Initialize database
npm run setup

# 4. Start server
npm start
```

---

## API Endpoints Summary

### 1. Health Check
```http
GET /health

Response: 200 OK
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2024-04-01T10:30:00.000Z"
}
```

### 2. Add School
```http
POST /api/addSchool
Content-Type: application/json

{
  "name": "School Name",
  "address": "123 Main St",
  "latitude": 39.7817,
  "longitude": -89.6501
}

Response: 201 Created
{
  "success": true,
  "message": "School added successfully",
  "data": {
    "id": 1,
    "name": "School Name",
    "address": "123 Main St",
    "latitude": 39.7817,
    "longitude": -89.6501
  }
}
```

### 3. List Schools by Proximity
```http
GET /api/listSchools?latitude=39.7817&longitude=-89.6501

Response: 200 OK
{
  "success": true,
  "message": "Schools retrieved successfully",
  "userLocation": {
    "latitude": 39.7817,
    "longitude": -89.6501
  },
  "count": 5,
  "data": [
    {
      "id": 1,
      "name": "Lincoln High School",
      "address": "123 Main St, Springfield",
      "latitude": 39.7817,
      "longitude": -89.6501,
      "distance": 0.0
    },
    {
      "id": 2,
      "name": "Central Middle School",
      "distance": 1.23
    }
  ]
}
```

---

## cURL Commands

### Add a School
```bash
curl -X POST http://localhost:3000/api/addSchool \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test School",
    "address": "123 Test St, City",
    "latitude": 40.7128,
    "longitude": -74.0060
  }'
```

### List Schools
```bash
curl -X GET "http://localhost:3000/api/listSchools?latitude=40.7128&longitude=-74.0060"
```

### Health Check
```bash
curl http://localhost:3000/health
```

---

## Validation Rules

| Field | Type | Required | Min | Max | Range |
|-------|------|----------|-----|-----|-------|
| name | string | ✓ | 2 | 255 | - |
| address | string | ✓ | 5 | 500 | - |
| latitude | number | ✓ | - | - | -90 to 90 |
| longitude | number | ✓ | - | - | -180 to 180 |

---

## Common Responses

### Success Response
```json
{
  "success": true,
  "message": "Description",
  "data": {
    // Response data
  }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error information"
}
```

### Validation Error
```json
{
  "success": false,
  "message": "Validation error",
  "details": [
    "\"field\" is required",
    "\"field\" must be between X and Y"
  ]
}
```

---

## HTTP Status Codes

| Code | Meaning | When |
|------|---------|------|
| 200 | OK | Successful GET request |
| 201 | Created | School added successfully |
| 400 | Bad Request | Validation error |
| 404 | Not Found | Invalid endpoint |
| 500 | Server Error | Database or server error |

---

## Environment Variables

```env
DB_HOST=localhost          # MySQL server host
DB_USER=root              # MySQL user
DB_PASSWORD=              # MySQL password
DB_NAME=school_management # Database name
DB_PORT=3306              # MySQL port
PORT=3000                 # Express server port
NODE_ENV=development      # Environment
```

---

## File Structure

```
├── config/database.js              # DB connection
├── routes/schools.js               # API routes
├── scripts/setupDatabase.js       # DB setup
├── utils/
│   ├── distance.js                # Distance calc
│   └── validators.js              # Validation
├── server.js                       # Main server
├── package.json                    # Dependencies
├── .env                            # Environment
├── README.md                       # Full docs
├── SETUP_AND_TESTING.md           # Testing guide
├── API_ARCHITECTURE.md             # Architecture
└── School-Management-API.postman_collection.json
```

---

## Postman Setup

1. **Import Collection**: Use `School-Management-API.postman_collection.json`
2. **Set Environment Variable**:
   - Key: `base_url`
   - Value: `http://localhost:3000`
3. **Run Requests**: Use provided test cases

---

## Troubleshooting

### Server won't start
```bash
# Check if port 3000 is in use
lsof -ti:3000

# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Change PORT in .env
```

### Database connection error
```bash
# Check .env credentials
# Verify MySQL is running
# Test connection with:
mysql -h localhost -u root -p
```

### Validation errors
```
"latitude" must be between -90 and 90
"name" is required
"address" must be at least 5 characters long
```

---

## Example Workflow

### 1. Start Server
```bash
npm start
```

### 2. Check Health
```bash
curl http://localhost:3000/health
```

### 3. Add Sample Schools
```bash
# School 1
curl -X POST http://localhost:3000/api/addSchool \
  -H "Content-Type: application/json" \
  -d '{"name":"School A","address":"123 Main St","latitude":40.7128,"longitude":-74.0060}'

# School 2
curl -X POST http://localhost:3000/api/addSchool \
  -H "Content-Type: application/json" \
  -d '{"name":"School B","address":"456 Oak Ave","latitude":40.7580,"longitude":-73.9855}'
```

### 4. List by Proximity
```bash
curl "http://localhost:3000/api/listSchools?latitude=40.7200&longitude=-74.0050"
```

---

## Database Query Examples

```sql
-- View all schools
SELECT * FROM schools;

-- Count schools
SELECT COUNT(*) FROM schools;

-- Find school by ID
SELECT * FROM schools WHERE id = 1;

-- Update school
UPDATE schools SET name = 'New Name' WHERE id = 1;

-- Delete school
DELETE FROM schools WHERE id = 1;

-- Find schools in specific area
SELECT * FROM schools WHERE latitude BETWEEN 39.5 AND 40.0;
```

---

## Distance Formula

The API uses the **Haversine formula** to calculate distances:

```
distance = 2 * R * asin(sqrt(sin²((lat2-lat1)/2) + cos(lat1)*cos(lat2)*sin²((lon2-lon1)/2)))

Where:
- R = 6371 km (Earth's radius)
- Distances in kilometers
- Accurate for all distance ranges
```

---

## Performance Tips

1. **Use Query Parameters**: Don't add unnecessary fields
2. **Batch Operations**: Add multiple schools in sequence
3. **Limit Results**: Consider pagination for large datasets
4. **Cache Results**: In client application for frequently accessed data
5. **Monitor Logs**: Check server logs for errors

---

## Security Best Practices

✓ Keep `.env` secure (never commit to git)
✓ Use strong database passwords
✓ Validate all inputs
✓ Use HTTPS in production
✓ Monitor logs for suspicious activity
✓ Update dependencies regularly

---

## Deployment Checklist

- [ ] Clone repository
- [ ] Install dependencies: `npm install`
- [ ] Configure .env file
- [ ] Initialize database: `npm run setup`
- [ ] Test endpoints locally
- [ ] Configure server/hosting
- [ ] Set environment variables on host
- [ ] Start server: `npm start`
- [ ] Verify endpoints accessible
- [ ] Set up monitoring/logging
- [ ] Share Postman collection with team

---

## Support & Resources

- **GitHub**: https://github.com/Rishika3D/Node.js-Skills
- **Documentation**: README.md, API_ARCHITECTURE.md, SETUP_AND_TESTING.md
- **Postman Collection**: School-Management-API.postman_collection.json
- **Error Logs**: Check console output for issues

---

**Version**: 1.0.0
**Last Updated**: 2024-04-01
