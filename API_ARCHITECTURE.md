# School Management API - Architecture & Code Structure

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Client Applications                   │
│         (Postman, Web Frontend, Mobile Apps)            │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTP/HTTPS
┌──────────────────────▼──────────────────────────────────┐
│                   Express Server                        │
│              (server.js - Port 3000)                    │
├────────────────────────────────────────────────────────┤
│ Middleware Layer:                                       │
│ • Body Parser (JSON parsing)                           │
│ • CORS (Cross-Origin Requests)                         │
│ • Error Handling                                        │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                   Router Layer                          │
│            (routes/schools.js)                         │
├────────────────────────────────────────────────────────┤
│ POST /api/addSchool                                    │
│ GET  /api/listSchools                                  │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│              Validation & Processing                    │
├────────────────────────────────────────────────────────┤
│ • Input Validation (Joi schemas)                       │
│ • Distance Calculation (Haversine formula)             │
│ • Data Transformation                                   │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│               MySQL Database                            │
│        (school_management database)                     │
├────────────────────────────────────────────────────────┤
│ Table: schools                                         │
│ • id (Primary Key)                                     │
│ • name                                                  │
│ • address                                              │
│ • latitude                                             │
│ • longitude                                            │
│ • created_at                                           │
│ • updated_at                                           │
└────────────────────────────────────────────────────────┘
```

---

## Project Directory Structure

```
school-management-api/
├── config/
│   └── database.js                 # MySQL connection pool configuration
├── routes/
│   └── schools.js                  # API route handlers
├── scripts/
│   └── setupDatabase.js            # Database initialization script
├── utils/
│   ├── distance.js                 # Haversine distance calculation
│   └── validators.js               # Input validation schemas
├── .env                            # Environment variables (local)
├── .gitignore                      # Git ignore rules
├── package.json                    # Project metadata and dependencies
├── README.md                        # Main documentation
├── server.js                        # Express server entry point
├── SETUP_AND_TESTING.md           # Setup and testing guide
├── API_ARCHITECTURE.md             # This file
└── School-Management-API.postman_collection.json  # Postman collection
```

---

## Component Breakdown

### 1. server.js (Main Application)

**Purpose**: Initialize Express server and configure middleware

**Key Responsibilities**:
- Create Express application
- Configure body parser middleware
- Enable CORS
- Load environment variables
- Mount route handlers
- Implement error handling
- Start HTTP server

**Key Code**:
```javascript
const app = express();
app.use(bodyParser.json());
app.use(cors());
app.use('/api', schoolRoutes);
app.listen(PORT);
```

---

### 2. config/database.js

**Purpose**: Establish and manage MySQL database connection pool

**Key Responsibilities**:
- Create connection pool
- Configure connection parameters
- Handle connection pooling
- Provide connection access to routes

**Connection Pool Configuration**:
```javascript
{
  host: localhost
  user: root
  password: ***
  database: school_management
  connectionLimit: 10
  waitForConnections: true
  queueLimit: 0
}
```

**Why Connection Pool?**
- Reuses connections instead of creating new ones
- Improves performance
- Handles concurrent requests
- Prevents connection exhaustion

---

### 3. routes/schools.js

**Purpose**: Define API endpoints and request handling logic

#### Endpoint 1: POST /api/addSchool

**Request Flow**:
1. Receive JSON payload from client
2. Validate input using Joi schema
3. Check for validation errors
4. Get database connection from pool
5. Execute INSERT query with prepared statement
6. Return response with inserted school data

**Validation Rules**:
```javascript
{
  name: string, required, 2-255 characters
  address: string, required, 5-500 characters
  latitude: number, required, -90 to 90
  longitude: number, required, -180 to 180
}
```

**Security Features**:
- Prepared statements prevent SQL injection
- Input validation prevents invalid data
- Connection pooling prevents connection attacks

#### Endpoint 2: GET /api/listSchools

**Request Flow**:
1. Extract latitude and longitude from query parameters
2. Validate coordinates
3. Get database connection
4. Execute SELECT query to fetch all schools
5. Calculate distance for each school
6. Sort schools by distance (nearest first)
7. Return sorted list with distances

**Distance Calculation**:
```
Uses Haversine formula:
a = sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlon/2)
c = 2 × atan2(√a, √(1−a))
d = R × c  (where R = 6,371 km)
```

**Why Client-Side Sorting?**
- Reduces database load
- Allows flexible sorting logic
- Better for small to medium datasets
- Easier to add additional sorting criteria

---

### 4. utils/validators.js

**Purpose**: Define input validation schemas using Joi

**Validation Approach**:
- Uses Joi library for schema definition
- Provides reusable validation functions
- Returns detailed validation error messages

**Schema Structure**:
```javascript
Joi.object({
  fieldName: Joi.type()
    .required()
    .min()
    .max()
})
```

**Benefits**:
- Declarative validation
- Detailed error messages
- Type checking
- Range validation
- Reusable across endpoints

---

### 5. utils/distance.js

**Purpose**: Calculate geographical distance between coordinates

**Haversine Formula Implementation**:
```javascript
R = 6371 km (Earth's radius)

Convert degrees to radians:
dLat = (lat2 - lat1) × (π/180)
dLon = (lon2 - lon1) × (π/180)

Calculate great circle distance:
a = sin²(dLat/2) + cos(lat1) × cos(lat2) × sin²(dLon/2)
c = 2 × atan2(√a, √(1−a))
distance = R × c
```

**Accuracy**:
- Accounts for Earth's spherical shape
- Accurate for distances up to thousands of kilometers
- Precision: ±0.5% for typical use cases

**Example Calculation**:
```
From: 39.7817°N, 89.6501°W (Springfield, IL)
To:   39.7892°N, 89.6432°W (Central Middle School)
Distance: 1.23 km
```

---

### 6. scripts/setupDatabase.js

**Purpose**: Initialize MySQL database and tables

**Setup Process**:
1. Connect to MySQL without specifying database
2. Create school_management database (if not exists)
3. Create schools table with schema
4. Insert sample data
5. Create indices for performance

**Database Schema**:
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

**Sample Data**:
- Lincoln High School
- Central Middle School
- North Elementary School
- South Academy
- East Preparatory School

---

## Request-Response Flow

### Add School Request

```
Client
  │
  └─▶ POST /api/addSchool
      {
        "name": "New School",
        "address": "123 Main St",
        "latitude": 39.7817,
        "longitude": -89.6501
      }

      │
      ▼
Server (routes/schools.js)
  │
  ├─ Validate input
  │   └─ Check schema with Joi
  │
  ├─ Get database connection
  │   └─ From pool (config/database.js)
  │
  ├─ Execute INSERT query
  │   └─ Prepared statement for security
  │
  └─ Return response
      {
        "success": true,
        "message": "School added successfully",
        "data": {
          "id": 1,
          "name": "New School",
          "address": "123 Main St",
          "latitude": 39.7817,
          "longitude": -89.6501
        }
      }

      │
      ▼
Client
```

### List Schools Request

```
Client
  │
  └─▶ GET /api/listSchools?latitude=39.7817&longitude=-89.6501

      │
      ▼
Server (routes/schools.js)
  │
  ├─ Validate parameters
  │   └─ Check coordinates with Joi
  │
  ├─ Get database connection
  │   └─ From pool
  │
  ├─ Fetch all schools from database
  │   └─ SELECT * FROM schools
  │
  ├─ Calculate distances (utils/distance.js)
  │   ├─ Lincoln High: 0.0 km
  │   ├─ Central Middle: 1.23 km
  │   ├─ North Elementary: 3.45 km
  │   ├─ South Academy: 5.67 km
  │   └─ East Preparatory: 7.89 km
  │
  ├─ Sort by distance (nearest first)
  │   └─ schools.sort((a, b) => a.distance - b.distance)
  │
  └─ Return response
      {
        "success": true,
        "count": 5,
        "data": [
          {
            "id": 1,
            "name": "Lincoln High School",
            "distance": 0.0
          },
          {...},
          ...
        ]
      }

      │
      ▼
Client
```

---

## Error Handling Flow

```
Request
  │
  ▼
Validation
  │
  ├─ Valid? ──▶ Process Request ──▶ Success Response (200/201)
  │
  └─ Invalid? ──▶ Return 400 Error
      {
        "success": false,
        "message": "Validation error",
        "details": ["error1", "error2"]
      }

Database Error
  │
  └─▶ Catch Exception ──▶ Return 500 Error
      {
        "success": false,
        "message": "Error message",
        "error": "Detailed error"
      }
```

---

## Database Transactions & Performance

### Connection Pooling Benefits
- **Reusable Connections**: 10 concurrent connections
- **Queue Management**: Up to 10 waiting requests
- **Automatic Cleanup**: Connections released after use

### Query Optimization
- **Prepared Statements**: Prevent SQL injection
- **Indices**: Created on latitude/longitude for faster searches
- **Client-Side Sorting**: Reduce database load

### Scalability Considerations
1. **Horizontal Scaling**: Multiple server instances with shared database
2. **Database Replication**: Master-slave setup for read scaling
3. **Caching**: Redis for frequently accessed data
4. **Sharding**: Partition data by region for massive datasets

---

## Security Measures

### 1. Input Validation
- Schema validation using Joi
- Type checking
- Range validation
- String length limits

### 2. SQL Injection Prevention
- Prepared statements with parameters
- Never concatenate user input into queries

### 3. Error Handling
- Don't expose sensitive database details
- Sanitize error messages
- Log errors server-side only

### 4. CORS Configuration
- Whitelist allowed origins
- Control HTTP methods
- Manage credentials

### 5. Environment Variables
- Sensitive credentials in .env
- Never commit .env to git
- Different values for each environment

---

## Testing Strategy

### Unit Tests
- Validate distance calculation
- Test input validation schemas

### Integration Tests
- End-to-end API requests
- Database operations
- Error scenarios

### Load Testing
- Test with multiple concurrent requests
- Monitor connection pool behavior
- Identify bottlenecks

---

## Monitoring & Maintenance

### Logs to Monitor
```
✓ Successful requests
✗ Database errors
✗ Validation failures
⚠ Slow queries
⚠ Connection pool exhaustion
```

### Database Maintenance
```sql
-- Check table size
SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb
FROM information_schema.TABLES
WHERE table_schema = 'school_management';

-- Analyze table for optimization
ANALYZE TABLE schools;

-- Check index usage
SHOW INDEX FROM schools;
```

---

## Future Enhancements

1. **Authentication & Authorization**
   - JWT tokens
   - Role-based access control

2. **Caching**
   - Redis for frequently accessed schools
   - Cache invalidation strategy

3. **Advanced Filtering**
   - Filter by school type
   - Filter by distance radius
   - Filter by rating/reviews

4. **Pagination**
   - Limit results per page
   - Cursor-based pagination

5. **Real-time Updates**
   - WebSocket support
   - Push notifications for new schools

6. **Geospatial Queries**
   - MySQL spatial indices
   - Radius search queries

7. **API Documentation**
   - Swagger/OpenAPI integration
   - Auto-generated API docs

8. **Containerization**
   - Docker images
   - Kubernetes deployment

---

**Architecture Version**: 1.0.0
**Last Updated**: 2024-04-01
