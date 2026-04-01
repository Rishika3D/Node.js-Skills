# School Management API - Live Deployment Guide

## 🚀 Deploy to Live Endpoints

Choose one of the following deployment options:

---

## Option 1: Deploy to Heroku (Easiest)

### Prerequisites
- Heroku Account (free tier available)
- Heroku CLI installed: https://devcenter.heroku.com/articles/heroku-cli
- Git installed

### Step 1: Login to Heroku
```bash
heroku login
```
This opens a browser to authenticate.

### Step 2: Create Heroku App
```bash
cd /Users/ashi/NodeJS
heroku create your-school-api-app
# Example: heroku create rishika-school-api
```

**Note**: Replace `your-school-api-app` with your desired app name. Heroku will provide URL like: `https://rishika-school-api.herokuapp.com`

### Step 3: Add MySQL Database (ClearDB)
```bash
heroku addons:create cleardb:ignite
```

Or use JawsDB:
```bash
heroku addons:create jawsdb:kitefin
```

### Step 4: Get Database URL
```bash
heroku config:get CLEARDB_DATABASE_URL
```

Output will look like:
```
mysql://user:password@host/database
```

### Step 5: Update .env for Production
Create `.env.production`:
```bash
heroku config:set DB_HOST=your-host
heroku config:set DB_USER=your-user
heroku config:set DB_PASSWORD=your-password
heroku config:set DB_NAME=your-database
heroku config:set DB_PORT=3306
heroku config:set PORT=5000
heroku config:set NODE_ENV=production
```

Or set all at once:
```bash
heroku config:set DB_HOST=host DB_USER=user DB_PASSWORD=pass DB_NAME=dbname NODE_ENV=production
```

### Step 6: Deploy
```bash
git push heroku main
```

### Step 7: Initialize Database on Heroku
```bash
heroku run npm run setup
```

### Step 8: View Live App
```bash
heroku open
```

Or visit: `https://your-school-api-app.herokuapp.com`

### Step 9: View Logs
```bash
heroku logs --tail
```

### Verify Deployment
```bash
# Health check
curl https://your-school-api-app.herokuapp.com/health

# Add school
curl -X POST https://your-school-api-app.herokuapp.com/api/addSchool \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","address":"123 St","latitude":40.7128,"longitude":-74.0060}'

# List schools
curl "https://your-school-api-app.herokuapp.com/api/listSchools?latitude=40.7128&longitude=-74.0060"
```

---

## Option 2: Deploy to Railway (Modern, Free)

### Prerequisites
- Railway Account: https://railway.app
- GitHub account with repository

### Step 1: Connect to Railway
1. Go to https://railway.app
2. Click "Deploy Now"
3. Connect GitHub account
4. Select repository: `Node.js-Skills`

### Step 2: Add MySQL Database
1. In Railway dashboard, click "Add Service"
2. Select "MySQL"
3. Railway creates database automatically

### Step 3: Configure Environment
1. Click "Variables"
2. Set:
   ```
   DB_HOST=database-host (from Railway)
   DB_USER=root
   DB_PASSWORD=your-password
   DB_NAME=school_management
   DB_PORT=3306
   NODE_ENV=production
   ```

### Step 4: Deploy
1. Click "Deploy"
2. Wait for deployment to complete

### Step 5: Get Live URL
- Found in "Deployments" section
- Example: `https://your-app-random.railway.app`

### Verify
```bash
curl https://your-app-random.railway.app/health
```

---

## Option 3: Deploy to AWS EC2

### Prerequisites
- AWS Account
- EC2 instance running Ubuntu 20.04 or later
- Security group allows ports 80, 443, 3000

### Step 1: SSH into EC2
```bash
ssh -i your-key.pem ec2-user@your-ec2-ip
```

### Step 2: Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### Step 3: Install Node.js
```bash
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs
```

### Step 4: Install MySQL
```bash
sudo apt install -y mysql-server
```

### Step 5: Clone Repository
```bash
git clone https://github.com/Rishika3D/Node.js-Skills.git
cd Node.js-Skills
npm install
```

### Step 6: Configure Database
Edit `.env`:
```bash
nano .env
```

Add credentials for EC2 MySQL

### Step 7: Setup Database
```bash
npm run setup
```

### Step 8: Install PM2 (Process Manager)
```bash
sudo npm install -g pm2
```

### Step 9: Start Application
```bash
pm2 start server.js --name "school-api"
pm2 startup
pm2 save
```

### Step 10: Setup Nginx Reverse Proxy
```bash
sudo apt install -y nginx

# Create config
sudo nano /etc/nginx/sites-available/school-api
```

Add:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable:
```bash
sudo ln -s /etc/nginx/sites-available/school-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Step 11: Setup SSL with Let's Encrypt
```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### Live URL
```
https://your-domain.com/api/addSchool
https://your-domain.com/api/listSchools
```

---

## Option 4: Deploy to DigitalOcean App Platform

### Prerequisites
- DigitalOcean Account
- GitHub repository

### Step 1: Login to DigitalOcean
- Visit: https://cloud.digitalocean.com

### Step 2: Create App
1. Click "Apps" → "Create App"
2. Connect GitHub repository
3. Select `Node.js-Skills` repo

### Step 3: Configure Build
- Runtime: Node.js
- Build command: `npm install`
- Run command: `npm start`

### Step 4: Add MySQL Database
1. Click "Add Component"
2. Select "MySQL Database"
3. Configure credentials

### Step 5: Set Environment Variables
```
DB_HOST=database-host
DB_USER=root
DB_PASSWORD=your-password
DB_NAME=school_management
DB_PORT=3306
NODE_ENV=production
```

### Step 6: Deploy
Click "Deploy App" and wait for completion

### Live URL
Found in App dashboard: `https://school-api-random.ondigitalocean.app`

---

## 📤 Share Postman Collection

### Method 1: Direct Link (Free)
1. Go to https://www.postman.com
2. Sign in or create account
3. Click "Upload" → Select `School-Management-API.postman_collection.json`
4. Make public or share link
5. Copy share link
6. Send via email

**Email Template**:
```
Subject: School Management API - Postman Collection

Hi Team,

Here's the Postman collection for the School Management API:

📚 Collection Link: [PASTE_POSTMAN_LINK_HERE]

🔗 Live API: https://your-app-name.herokuapp.com

📖 Documentation: https://github.com/Rishika3D/Node.js-Skills/blob/main/README.md

Steps to use:
1. Click the link to open in Postman
2. Set environment variable: base_url = https://your-app-name.herokuapp.com
3. Run the test requests

Endpoints:
- Health: GET /health
- Add School: POST /api/addSchool
- List Schools: GET /api/listSchools?latitude=X&longitude=Y

Best regards,
[Your Name]
```

### Method 2: Postman Workspace (Recommended)
1. Create Postman Workspace
2. Upload collection
3. Invite team members
4. Collaborate in real-time

**Steps**:
1. In Postman, click "Workspaces"
2. Click "Create Workspace"
3. Name: "School Management API"
4. Upload collection
5. Click "Invite" and add team emails

### Method 3: GitHub Link
Since collection is in GitHub:
```
https://github.com/Rishika3D/Node.js-Skills/blob/main/School-Management-API.postman_collection.json
```

Share this direct GitHub link to team

### Method 4: Email with Attachment
1. Attach `School-Management-API.postman_collection.json` to email
2. Include live API URL
3. Include quick setup instructions

---

## 📋 Complete Email Template

```
Subject: 🚀 School Management API - Live Deployment

Hi Team,

The School Management API is now live and ready for testing!

═══════════════════════════════════════════════════════════

🔗 LIVE API ENDPOINTS
═══════════════════════════════════════════════════════════

Base URL: https://rishika-school-api.herokuapp.com

✅ Health Check:
   GET https://rishika-school-api.herokuapp.com/health

✅ Add School:
   POST https://rishika-school-api.herokuapp.com/api/addSchool

✅ List Schools:
   GET https://rishika-school-api.herokuapp.com/api/listSchools?latitude=X&longitude=Y

═══════════════════════════════════════════════════════════

📚 POSTMAN COLLECTION
═══════════════════════════════════════════════════════════

Option A: Postman Workspace (Recommended)
   Join workspace: [PASTE_WORKSPACE_LINK]

Option B: Direct Import
   Download: School-Management-API.postman_collection.json
   (See attachment or GitHub repo)

Option C: GitHub Link
   https://raw.githubusercontent.com/Rishika3D/Node.js-Skills/main/School-Management-API.postman_collection.json

═══════════════════════════════════════════════════════════

🚀 QUICK START
═══════════════════════════════════════════════════════════

1. Import Postman collection (see above)
2. Set environment variable:
   - Key: base_url
   - Value: https://rishika-school-api.herokuapp.com
3. Run requests:
   ✓ Health Check
   ✓ Add School (sample 1, 2, 3)
   ✓ List Schools (different locations)

═══════════════════════════════════════════════════════════

📖 DOCUMENTATION
═══════════════════════════════════════════════════════════

📘 Full API Docs:
   https://github.com/Rishika3D/Node.js-Skills/blob/main/README.md

📙 Setup Guide:
   https://github.com/Rishika3D/Node.js-Skills/blob/main/SETUP_AND_TESTING.md

📕 Quick Reference:
   https://github.com/Rishika3D/Node.js-Skills/blob/main/QUICK_REFERENCE.md

═══════════════════════════════════════════════════════════

🧪 TEST CASES INCLUDED
═══════════════════════════════════════════════════════════

✓ Health Check
✓ Add School (3 examples)
✓ List Schools (2 locations)
✓ Validation Error Tests
✓ Invalid Data Tests

═══════════════════════════════════════════════════════════

💡 KEY FEATURES
═══════════════════════════════════════════════════════════

✓ Add schools with validation
✓ List schools by proximity to user location
✓ Distance calculated using Haversine formula
✓ Comprehensive input validation
✓ Error handling and logging
✓ Production-ready

═══════════════════════════════════════════════════════════

📊 API RESPONSE EXAMPLE
═══════════════════════════════════════════════════════════

GET /api/listSchools?latitude=39.7817&longitude=-89.6501

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
      "distance": 0.0
    },
    {
      "id": 2,
      "name": "Central Middle School",
      "distance": 1.23
    }
  ]
}

═══════════════════════════════════════════════════════════

❓ QUESTIONS?
═══════════════════════════════════════════════════════════

Check the documentation files or reach out!

Repository: https://github.com/Rishika3D/Node.js-Skills

Best regards,
[Your Name]
```

---

## 🔍 Verify Live Deployment

### Test with cURL
```bash
# Health check
curl https://your-live-url.com/health

# Add school
curl -X POST https://your-live-url.com/api/addSchool \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test School",
    "address": "123 Test St",
    "latitude": 40.7128,
    "longitude": -74.0060
  }'

# List schools
curl "https://your-live-url.com/api/listSchools?latitude=40.7128&longitude=-74.0060"
```

### Test with Postman
1. Import collection
2. Set base_url to live URL
3. Run all test requests
4. Verify all pass

---

## 🔐 Security Checklist for Production

- [ ] Change default database password
- [ ] Enable HTTPS/SSL
- [ ] Set NODE_ENV=production
- [ ] Use environment variables for secrets
- [ ] Enable database backups
- [ ] Setup monitoring and alerts
- [ ] Configure rate limiting
- [ ] Setup logging and error tracking
- [ ] Document API changes
- [ ] Version your API

---

## 📊 Monitoring Live API

### Heroku Logs
```bash
heroku logs --tail
```

### AWS CloudWatch
```bash
aws logs tail /aws/lambda/school-api --follow
```

### DigitalOcean Logs
View in dashboard under "Logs" tab

### Application Monitoring
- Monitor response times
- Track error rates
- Check database connection pool
- Monitor server resources

---

## 📝 Next Steps

1. ✅ Deploy using Option 1 (Heroku - Easiest)
2. ✅ Get live URL
3. ✅ Create Postman workspace or share collection
4. ✅ Send email to team
5. ✅ Monitor logs
6. ✅ Celebrate! 🎉

---

**Last Updated**: 2024-04-01
**Version**: 1.0.0
