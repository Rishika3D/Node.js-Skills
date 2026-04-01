# School Management API

A Node.js REST API for managing schools with location-based sorting using Express.js and MySQL.

## Features

- **Add Schools**: POST endpoint to add new schools with validation
- **List Schools**: GET endpoint to retrieve all schools sorted by proximity to user location
- **Distance Calculation**: Uses Haversine formula for accurate geographical distance
- **Input Validation**: Comprehensive validation using Joi schema validation
- **CORS Support**: Cross-Origin Resource Sharing enabled
- **Error Handling**: Structured error responses

## Prerequisites

- Node.js (v14 or higher)
- MySQL Server (v5.7 or higher)
- npm or yarn

## Installation

1. Clone the repository:
```bash
git clone https://github.com/Rishika3D/Node.js-Skills.git
cd Node.js-Skills
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
Edit `.env` file with your MySQL credentials:
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=school_management
DB_PORT=3306
PORT=3000
NODE_ENV=development
```

4. Setup database:
```bash
npm run setup
```

This will:
- Create the `school_management` database
- Create the `schools` table with proper schema
- Insert sample school data

## Running the Server

```bash
npm start
```

The server will start on `http://localhost:3000`

## API Endpoints

### 1. Health Check
```
GET /health
```

**Response:**
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2024-04-01T10:30:00.000Z"
}
```

### 2. Add School
```
POST /api/addSchool
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "School Name",
  "address": "123 Main Street, City",
  "latitude": 39.7817,
  "longitude": -89.6501
}
```

**Response (Success - 201):**
```json
{
  "success": true,
  "message": "School added successfully",
  "data": {
    "id": 1,
    "name": "School Name",
    "address": "123 Main Street, City",
    "latitude": 39.7817,
    "longitude": -89.6501
  }
}
```

**Response (Validation Error - 400):**
```json
{
  "success": false,
  "message": "Validation error",
  "details": ["\"name\" is required", "\"latitude\" must be between -90 and 90"]
}
```

### 3. List Schools (Sorted by Proximity)
```
GET /api/listSchools?latitude=39.7817&longitude=-89.6501
```

**Parameters:**
- `latitude` (required): User's latitude (-90 to 90)
- `longitude` (required): User's longitude (-180 to 180)

**Response (Success - 200):**
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

## Validation Rules

### Add School
- `name`: Required, string, 2-255 characters
- `address`: Required, string, 5-500 characters
- `latitude`: Required, number, -90 to 90
- `longitude`: Required, number, -180 to 180

### List Schools
- `latitude`: Required, number, -90 to 90
- `longitude`: Required, number, -180 to 180

## Database Schema

### schools table
```sql
CREATE TABLE schools (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  address VARCHAR(500) NOT NULL,
  latitude FLOAT NOT NULL,
  longitude FLOAT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_location (latitude, longitude)
);
```

## Project Structure

```
.
├── config/
│   └── database.js           # Database configuration and connection pool
├── routes/
│   └── schools.js            # School API routes
├── scripts/
│   └── setupDatabase.js      # Database setup script
├── utils/
│   ├── distance.js           # Distance calculation utility
│   └── validators.js         # Input validation schemas
├── .env                       # Environment variables (local)
├── .gitignore                # Git ignore rules
├── package.json              # Project dependencies
├── README.md                 # This file
└── server.js                 # Main Express server
```

## Distance Calculation

The API uses the **Haversine formula** to calculate the shortest distance between two points on Earth's surface:

```
a = sin²(Δlat/2) + cos(lat1) * cos(lat2) * sin²(Δlon/2)
c = 2 * atan2(√a, √(1−a))
d = R * c
```

Where:
- R = Earth's radius (6,371 km)
- lat1, lon1 = User's coordinates
- lat2, lon2 = School's coordinates

Distance is returned in kilometers.

## Testing with Postman

1. Import the provided Postman collection
2. Set environment variables:
   - `base_url`: http://localhost:3000
3. Run the requests:
   - Health Check (to verify server)
   - Add School (create test schools)
   - List Schools (retrieve and sort by proximity)

## Error Handling

All endpoints return consistent error responses:

```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error information"
}
```

HTTP Status Codes:
- `200`: Success
- `201`: Created successfully
- `400`: Bad request (validation error)
- `404`: Not found
- `500`: Internal server error

## Environment Variables

```
DB_HOST          MySQL host (default: localhost)
DB_USER          MySQL user (default: root)
DB_PASSWORD      MySQL password (default: empty)
DB_NAME          Database name (default: school_management)
DB_PORT          MySQL port (default: 3306)
PORT             Server port (default: 3000)
NODE_ENV         Environment (development/production)
```

## Security Considerations

- Input validation with Joi schema validation
- SQL injection prevention with prepared statements
- CORS configured for cross-origin requests
- Proper error handling without exposing sensitive data
- Environment variables for sensitive configuration

## Deployment

### Requirements for Deployment
- Node.js runtime
- MySQL database
- Environment variables configured

### Popular Hosting Options
- **Heroku**: Simple deployment with git push
- **AWS EC2**: Full control over infrastructure
- **DigitalOcean**: Affordable VPS option
- **Railway**: Modern Node.js deployment platform

### Deployment Steps
1. Set environment variables on hosting platform
2. Run `npm install` to install dependencies
3. Run `npm run setup` to initialize database
4. Run `npm start` to start the server

## License

ISC

## Support

For issues or questions, please open an issue in the GitHub repository.

---

**Created**: 2024
**Version**: 1.0.0
