# School Management API - Setup and Testing Guide

## Quick Start

### 1. Local Development Setup

#### Prerequisites
- Node.js v14+ installed
- MySQL Server running
- npm installed

#### Step 1: Clone Repository
```bash
git clone https://github.com/Rishika3D/Node.js-Skills.git
cd Node.js-Skills
```

#### Step 2: Install Dependencies
```bash
npm install
```

#### Step 3: Configure Database
Edit `.env` file with your MySQL credentials:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=school_management
DB_PORT=3306
PORT=3000
NODE_ENV=development
```

#### Step 4: Initialize Database
```bash
npm run setup
```

Expected output:
```
Connected to MySQL
Database 'school_management' created or already exists
Using database 'school_management'
Schools table created or already exists
Inserted sample school: Lincoln High School
Inserted sample school: Central Middle School
...
✓ Database setup completed successfully!
```

#### Step 5: Start Server
```bash
npm start
```

Expected output:
```
Server is running on port 3000
Environment: development
Endpoints:
  Health: http://localhost:3000/health
  API: http://localhost:3000/api
```

---

## Testing with Postman

### Import Collection

1. Open Postman
2. Click **Import** button (top left)
3. Select **Upload Files**
4. Choose `School-Management-API.postman_collection.json`
5. Click **Import**

### Configure Environment

1. Click the **Environment** dropdown
2. Click **Create new environment**
3. Name it: `School Management API`
4. Add variable:
   - **Key**: `base_url`
   - **Value**: `http://localhost:3000`
5. Save and select the environment

### Test Requests

#### 1. Health Check
- **Request**: `GET /health`
- **Expected Status**: 200
- **Expected Response**:
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2024-04-01T10:30:00.000Z"
}
```

#### 2. Add School
- **Request**: `POST /api/addSchool`
- **Body**:
```json
{
  "name": "Harvard University Academy",
  "address": "500 Harvard St, Cambridge, MA 02138",
  "latitude": 42.3601,
  "longitude": -71.0589
}
```
- **Expected Status**: 201
- **Expected Response**:
```json
{
  "success": true,
  "message": "School added successfully",
  "data": {
    "id": 6,
    "name": "Harvard University Academy",
    "address": "500 Harvard St, Cambridge, MA 02138",
    "latitude": 42.3601,
    "longitude": -71.0589
  }
}
```

#### 3. List Schools (From Center)
- **Request**: `GET /api/listSchools`
- **Parameters**:
  - `latitude`: 39.7817
  - `longitude`: -89.6501
- **Expected Status**: 200
- **Expected Response**:
```json
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
      "address": "456 Oak Ave, Springfield",
      "latitude": 39.7892,
      "longitude": -89.6432,
      "distance": 1.23
    }
  ]
}
```

#### 4. List Schools (From Different Location)
- **Request**: `GET /api/listSchools`
- **Parameters**:
  - `latitude`: 39.8
  - `longitude`: -89.65
- **Note**: Schools will be sorted differently based on proximity to this new location

#### 5. Validation Error Testing
- **Request**: `POST /api/addSchool`
- **Body** (missing latitude):
```json
{
  "name": "Test School",
  "address": "123 Test St",
  "longitude": -89.65
}
```
- **Expected Status**: 400
- **Expected Response**:
```json
{
  "success": false,
  "message": "Validation error",
  "details": ["\"latitude\" is required"]
}
```

#### 6. Invalid Coordinates Test
- **Request**: `GET /api/listSchools`
- **Parameters**:
  - `latitude`: 95 (invalid)
  - `longitude`: -89.65
- **Expected Status**: 400
- **Expected Response**:
```json
{
  "success": false,
  "message": "Validation error",
  "details": ["\"latitude\" must be less than or equal to 90"]
}
```

---

## cURL Testing (Command Line)

If you prefer testing via command line instead of Postman:

### Health Check
```bash
curl -X GET http://localhost:3000/health
```

### Add School
```bash
curl -X POST http://localhost:3000/api/addSchool \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Kennedy High School",
    "address": "300 West St, Springfield, IL 62704",
    "latitude": 39.7950,
    "longitude": -89.6600
  }'
```

### List Schools
```bash
curl -X GET "http://localhost:3000/api/listSchools?latitude=39.7817&longitude=-89.6501"
```

---

## Deployment Guide

### Option 1: Heroku Deployment

#### Prerequisites
- Heroku CLI installed
- GitHub account
- MySQL database (Heroku Add-on or external)

#### Steps
1. Login to Heroku:
```bash
heroku login
```

2. Create Heroku app:
```bash
heroku create your-app-name
```

3. Add MySQL database (ClearDB or JawsDB):
```bash
heroku addons:create jawsdb:kitefin
```

4. Get database URL:
```bash
heroku config:get JAWSDB_URL
```

5. Update .env with database credentials from URL

6. Deploy:
```bash
git push heroku main
```

7. Initialize database:
```bash
heroku run npm run setup
```

8. View logs:
```bash
heroku logs --tail
```

### Option 2: AWS EC2 Deployment

#### Prerequisites
- AWS Account
- EC2 instance running Ubuntu
- Security group configured for port 3000 and 3306

#### Steps
1. SSH into EC2 instance
2. Install Node.js and MySQL:
```bash
sudo apt update
sudo apt install nodejs npm mysql-server
```

3. Clone repository:
```bash
git clone https://github.com/Rishika3D/Node.js-Skills.git
cd Node.js-Skills
```

4. Install dependencies and setup:
```bash
npm install
npm run setup
```

5. Start server with PM2 (for production):
```bash
npm install -g pm2
pm2 start server.js --name "school-api"
pm2 startup
pm2 save
```

6. Configure Nginx reverse proxy to forward traffic to port 3000

7. Set up SSL with Let's Encrypt

### Option 3: DigitalOcean App Platform

#### Steps
1. Connect GitHub repository to DigitalOcean
2. Select the repository and branch
3. Configure environment variables in UI
4. Set run command: `npm run setup && npm start`
5. Add MySQL database component
6. Deploy

---

## Environment Variables for Production

```env
DB_HOST=your-database-host
DB_USER=your-database-user
DB_PASSWORD=your-secure-password
DB_NAME=school_management
DB_PORT=3306
PORT=3000
NODE_ENV=production
```

---

## Monitoring and Logs

### View Server Logs
```bash
npm start
```

### Check Database Connection
```bash
node -e "require('mysql2/promise').createConnection(require('dotenv').config(), {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
}).then(() => console.log('✓ Database connected')).catch(err => console.error('✗ Connection failed:', err))"
```

### Common Issues

#### Issue: "Cannot find module 'express'"
```bash
npm install
```

#### Issue: "MySQL connection error"
- Check `.env` file credentials
- Verify MySQL server is running
- Check firewall rules

#### Issue: "EADDRINUSE: address already in use"
- Port 3000 is already in use
- Change PORT in `.env` or kill process using port:
```bash
lsof -ti:3000 | xargs kill -9
```

---

## API Documentation Summary

### Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/health` | Health check |
| GET | `/` | API info |
| POST | `/api/addSchool` | Add new school |
| GET | `/api/listSchools` | List schools by proximity |

### Response Format

**Success Response**:
```json
{
  "success": true,
  "message": "Description",
  "data": {}
}
```

**Error Response**:
```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error"
}
```

---

## Distance Calculation Example

For schools near Springfield, IL (39.7817, -89.6501):

| School | Latitude | Longitude | Distance (km) |
|--------|----------|-----------|---------------|
| Lincoln High | 39.7817 | -89.6501 | 0.0 |
| Central Middle | 39.7892 | -89.6432 | 1.23 |
| North Elementary | 39.8045 | -89.6789 | 3.45 |
| South Academy | 39.7634 | -89.6234 | 5.67 |
| East Preparatory | 39.7945 | -89.6045 | 7.89 |

---

## Database Queries for Verification

```sql
-- Check database created
SHOW DATABASES;

-- Use database
USE school_management;

-- Check table structure
DESCRIBE schools;

-- View all schools
SELECT * FROM schools;

-- Count schools
SELECT COUNT(*) as total_schools FROM schools;

-- View sample school
SELECT * FROM schools LIMIT 1;
```

---

**Last Updated**: 2024-04-01
**API Version**: 1.0.0
