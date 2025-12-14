# 🚀 DevOps Deployment Guide - BMI Health Tracker
## For Complete Beginners Who Know About EC2

---

## 📋 Table of Contents
1. [What This Application Does](#what-this-application-does)
2. [How the 3-Tier Architecture Works](#how-the-3-tier-architecture-works)
3. [API Endpoints & Communication Flow](#api-endpoints--communication-flow)
4. [Before You Start](#before-you-start)
5. [Step-by-Step Deployment Guide](#step-by-step-deployment-guide)
6. [Testing Your Deployment](#testing-your-deployment)
7. [Troubleshooting Common Issues](#troubleshooting-common-issues)
8. [Maintenance & Monitoring](#maintenance--monitoring)

---

## 🎯 What This Application Does

The BMI Health Tracker is a web application that helps users:
- Calculate their Body Mass Index (BMI)
- Track their Basal Metabolic Rate (BMR)
- Monitor daily calorie requirements
- View 30-day health trends with charts
- Store and retrieve historical measurements

**Tech Stack:**
- **Frontend:** React (JavaScript framework for UI) + Vite (build tool)
- **Backend:** Node.js + Express (JavaScript server)
- **Database:** PostgreSQL (relational database)

---

## 🏗️ How the 3-Tier Architecture Works

### The Three Tiers Explained

```
┌─────────────────────────────────────────────────────────────┐
│                    TIER 1: FRONTEND                          │
│  (What Users See - React App Running in Browser)            │
│                                                              │
│  User fills form → Frontend validates → Sends HTTP request  │
│                                                              │
│  Location: /var/www/bmi-health-tracker (static files)       │
│  Access: http://your-domain.com or http://your-ip           │
└─────────────────────────────────────────────────────────────┘
                              ↓ HTTP Request
                              ↓ (via Nginx proxy)
┌─────────────────────────────────────────────────────────────┐
│                    TIER 2: BACKEND                           │
│  (Application Logic - Node.js + Express Server)             │
│                                                              │
│  Receives request → Validates data → Calculates BMI/BMR     │
│  → Queries database → Returns response                      │
│                                                              │
│  Location: ~/backend/src/server.js                          │
│  Runs on: Port 3000                                         │
│  Managed by: PM2 (process manager)                          │
└─────────────────────────────────────────────────────────────┘
                              ↓ SQL Query
                              ↓ (PostgreSQL protocol)
┌─────────────────────────────────────────────────────────────┐
│                    TIER 3: DATABASE                          │
│  (Data Storage - PostgreSQL)                                │
│                                                              │
│  Stores measurements → Returns query results                │
│                                                              │
│  Database Name: bmidb                                       │
│  User: bmi_user                                             │
│  Runs on: Port 5432 (default PostgreSQL port)              │
└─────────────────────────────────────────────────────────────┘
```

### How They Communicate

#### 1️⃣ **Frontend → Backend Communication**

**Development Mode (on your laptop):**
```javascript
// vite.config.js sets up proxy
server: {
  proxy: {
    '/api': {
      target: 'http://localhost:3000',  // Backend server
      changeOrigin: true
    }
  }
}
```

**What happens:**
- User visits: `http://localhost:5173` (Vite dev server)
- Frontend makes request: `/api/measurements`
- Vite proxy forwards to: `http://localhost:3000/api/measurements`
- Backend processes and responds

**Production Mode (on EC2):**
```nginx
# Nginx configuration forwards requests
location /api/ {
    proxy_pass http://localhost:3000/;  // Backend on port 3000
    proxy_http_version 1.1;
}
```

**What happens:**
- User visits: `http://your-ip` (Nginx serves static files)
- Frontend makes request: `/api/measurements`
- Nginx forwards to: `http://localhost:3000/api/measurements`
- Backend processes and responds

#### 2️⃣ **Backend → Database Communication**

**Connection String (in backend/.env):**
```bash
DATABASE_URL=postgresql://bmi_user:password@localhost:5432/bmidb
#                        username:password@host:port/database_name
```

**How it works:**
```javascript
// backend/src/db.js
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,  // Maximum 20 simultaneous connections
});

// When you make a query:
const result = await pool.query('SELECT * FROM measurements');
```

**Connection Pool Explained:**
- Instead of opening/closing database connection every time
- Backend keeps 20 open connections ready
- Reuses connections for better performance
- Automatically handles connection errors

#### 3️⃣ **Complete Request Flow Example**

**Scenario:** User submits a new health measurement

```
1. USER ACTION
   User fills form and clicks "Add Measurement"
   
2. FRONTEND (React)
   ├─ Validates input (weight > 0, height > 0, etc.)
   ├─ Makes HTTP POST request
   └─ Code: api.post('/measurements', { weightKg: 70, heightCm: 175, ... })
   
3. NETWORK
   ├─ HTTP POST http://localhost:3000/api/measurements
   ├─ Headers: Content-Type: application/json
   └─ Body: {"weightKg":70,"heightCm":175,"age":30,"sex":"male","activity":"moderate"}
   
4. BACKEND (Express)
   ├─ CORS middleware checks origin is allowed
   ├─ Body parser converts JSON to JavaScript object
   ├─ Route handler: router.post('/measurements', ...)
   ├─ Validates required fields
   ├─ Calculates BMI = weightKg / (heightCm/100)^2
   ├─ Calculates BMR using Mifflin-St Jeor equation
   ├─ Calculates daily calories = BMR × activity multiplier
   └─ Prepares SQL query
   
5. DATABASE QUERY
   ├─ SQL: INSERT INTO measurements (weight_kg, height_cm, ...)
   ├─      VALUES ($1, $2, ...) RETURNING *
   ├─ PostgreSQL validates constraints
   ├─ Inserts row into table
   └─ Returns inserted row with ID and timestamp
   
6. BACKEND RESPONSE
   ├─ Status: 201 Created
   ├─ Body: {"measurement": {"id":1,"bmi":22.9,"bmr":1680,...}}
   └─ Sends response back
   
7. FRONTEND RECEIVES
   ├─ Success handler runs
   ├─ Shows success message
   ├─ Refreshes measurement list
   └─ Updates dashboard stats
```

---

## 📡 API Endpoints & Communication Flow

### Complete API Reference

#### 1. **Health Check Endpoint**

```
GET /health
```

**Purpose:** Check if backend server is running

**Request Example:**
```bash
curl http://localhost:3000/health
```

**Response:**
```json
{
  "status": "ok",
  "environment": "production"
}
```

**Used By:** 
- System monitoring
- Deployment scripts to verify server is up
- Load balancers for health checks

---

#### 2. **Create New Measurement**

```
POST /api/measurements
```

**Purpose:** Save a new health measurement with calculated BMI/BMR

**Request Body:**
```json
{
  "weightKg": 70,
  "heightCm": 175,
  "age": 30,
  "sex": "male",
  "activity": "moderate"
}
```

**Validation Rules:**
- `weightKg`: Required, must be > 0
- `heightCm`: Required, must be > 0
- `age`: Required, must be > 0
- `sex`: Required, must be "male" or "female"
- `activity`: Optional, one of: sedentary, light, moderate, active, very_active

**Backend Processing:**
```javascript
// routes.js
router.post('/measurements', async (req, res) => {
  // 1. Extract data from request
  const {weightKg, heightCm, age, sex, activity} = req.body;
  
  // 2. Validate required fields
  if (!weightKg || !heightCm || !age || !sex) {
    return res.status(400).json({ error: 'Missing required fields' });
  }
  
  // 3. Calculate metrics (from calculations.js)
  const bmi = weightKg / Math.pow(heightCm/100, 2);
  const bmr = calculateBMR(weightKg, heightCm, age, sex);
  const dailyCalories = bmr * activityMultiplier[activity];
  
  // 4. Insert into database
  const query = `INSERT INTO measurements (
    weight_kg, height_cm, age, sex, activity_level,
    bmi, bmi_category, bmr, daily_calories, created_at
  ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,now()) RETURNING *`;
  
  const values = [weightKg, heightCm, age, sex, activity, 
                  bmi, bmiCategory, bmr, dailyCalories];
  
  const result = await db.query(query, values);
  
  // 5. Return created record
  res.status(201).json({measurement: result.rows[0]});
});
```

**Response (Success - 201):**
```json
{
  "measurement": {
    "id": 1,
    "weight_kg": "70.00",
    "height_cm": "175.00",
    "age": 30,
    "sex": "male",
    "activity_level": "moderate",
    "bmi": "22.9",
    "bmi_category": "Normal weight",
    "bmr": 1680,
    "daily_calories": 2604,
    "created_at": "2025-12-14T10:30:00.000Z"
  }
}
```

**Response (Error - 400):**
```json
{
  "error": "Missing required fields"
}
```

**Frontend Usage:**
```javascript
// MeasurementForm.jsx
const handleSubmit = async (e) => {
  e.preventDefault();
  
  try {
    const response = await api.post('/measurements', formData);
    // Show success message
    // Reload measurement list
    onSaved(); // Callback to refresh data
  } catch (error) {
    // Show error message
  }
};
```

---

#### 3. **Get All Measurements**

```
GET /api/measurements
```

**Purpose:** Retrieve all health measurements, newest first

**Request Example:**
```bash
curl http://localhost:3000/api/measurements
```

**Backend Processing:**
```javascript
// routes.js
router.get('/measurements', async (req, res) => {
  // Simple query, ordered by newest first
  const result = await db.query(
    'SELECT * FROM measurements ORDER BY created_at DESC'
  );
  
  res.json({rows: result.rows});
});
```

**Response:**
```json
{
  "rows": [
    {
      "id": 3,
      "weight_kg": "72.00",
      "height_cm": "175.00",
      "bmi": "23.5",
      "bmi_category": "Normal weight",
      "bmr": 1705,
      "daily_calories": 2643,
      "created_at": "2025-12-14T10:30:00.000Z"
    },
    {
      "id": 2,
      "weight_kg": "71.00",
      "height_cm": "175.00",
      "bmi": "23.2",
      "created_at": "2025-12-13T08:15:00.000Z"
    }
  ]
}
```

**Frontend Usage:**
```javascript
// App.jsx
const loadMeasurements = async () => {
  const response = await api.get('/measurements');
  setRows(response.data.rows);  // Update state with data
  
  // Display in UI:
  // - Latest measurement for dashboard stats
  // - First 10 measurements in recent list
};
```

---

#### 4. **Get 30-Day BMI Trends**

```
GET /api/measurements/trends
```

**Purpose:** Get daily average BMI for the last 30 days (for charts)

**Request Example:**
```bash
curl http://localhost:3000/api/measurements/trends
```

**Backend Processing:**
```javascript
// routes.js
router.get('/measurements/trends', async (req, res) => {
  const query = `
    SELECT 
      date_trunc('day', created_at) AS day,  -- Group by day
      AVG(bmi) AS avg_bmi                    -- Average BMI per day
    FROM measurements
    WHERE created_at > now() - interval '30 days'
    GROUP BY day
    ORDER BY day
  `;
  
  const result = await db.query(query);
  res.json({rows: result.rows});
});
```

**Response:**
```json
{
  "rows": [
    {
      "day": "2025-11-14T00:00:00.000Z",
      "avg_bmi": "22.5"
    },
    {
      "day": "2025-11-15T00:00:00.000Z",
      "avg_bmi": "22.7"
    },
    {
      "day": "2025-12-14T00:00:00.000Z",
      "avg_bmi": "23.1"
    }
  ]
}
```

**Frontend Usage:**
```javascript
// TrendChart.jsx
useEffect(() => {
  const loadTrends = async () => {
    const response = await api.get('/measurements/trends');
    const data = response.data.rows;
    
    // Format for Chart.js
    const chartData = {
      labels: data.map(d => new Date(d.day).toLocaleDateString()),
      datasets: [{
        label: 'BMI Trend',
        data: data.map(d => parseFloat(d.avg_bmi)),
        borderColor: '#3b82f6',
        backgroundColor: 'rgba(59, 130, 246, 0.1)'
      }]
    };
    
    setChartData(chartData);
  };
  
  loadTrends();
}, []);
```

---

### Network Communication Details

#### Request Headers (Frontend → Backend)

```
POST /api/measurements HTTP/1.1
Host: localhost:3000
Content-Type: application/json
Accept: application/json
Origin: http://localhost:5173

{"weightKg":70,"heightCm":175,...}
```

#### Response Headers (Backend → Frontend)

```
HTTP/1.1 201 Created
Content-Type: application/json
Access-Control-Allow-Origin: http://localhost:5173
Access-Control-Allow-Credentials: true

{"measurement":{...}}
```

#### CORS Configuration Explained

```javascript
// server.js
const corsOptions = {
  // In development: Allow localhost:5173 (Vite)
  // In production: Only allow your domain
  origin: NODE_ENV === 'production' 
    ? process.env.FRONTEND_URL || 'http://localhost'
    : ['http://localhost:5173', 'http://localhost:3000'],
  credentials: true  // Allow cookies if needed
};

app.use(cors(corsOptions));
```

**Why CORS?**
- Browser security prevents frontend (localhost:5173) from calling backend (localhost:3000)
- CORS headers tell browser: "It's okay, I trust this origin"
- Without CORS: "blocked by CORS policy" error

---

### Database Schema & Queries

#### Table Structure

```sql
CREATE TABLE measurements (
  -- Primary Key
  id SERIAL PRIMARY KEY,
  
  -- Input Data (from user)
  weight_kg NUMERIC(5,2) NOT NULL CHECK (weight_kg > 0 AND weight_kg < 1000),
  height_cm NUMERIC(5,2) NOT NULL CHECK (height_cm > 0 AND height_cm < 300),
  age INTEGER NOT NULL CHECK (age > 0 AND age < 150),
  sex VARCHAR(10) NOT NULL CHECK (sex IN ('male', 'female')),
  activity_level VARCHAR(30) CHECK (activity_level IN ('sedentary', 'light', 'moderate', 'active', 'very_active')),
  
  -- Calculated Data (from backend)
  bmi NUMERIC(4,1) NOT NULL,
  bmi_category VARCHAR(30),
  bmr INTEGER,
  daily_calories INTEGER,
  
  -- Timestamp
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Indexes for faster queries
CREATE INDEX idx_measurements_created_at ON measurements(created_at DESC);
CREATE INDEX idx_measurements_bmi ON measurements(bmi);
```

#### Example Queries

**Insert New Measurement:**
```sql
INSERT INTO measurements (
  weight_kg, height_cm, age, sex, activity_level,
  bmi, bmi_category, bmr, daily_calories, created_at
) VALUES (
  70.00, 175.00, 30, 'male', 'moderate',
  22.9, 'Normal weight', 1680, 2604, now()
) RETURNING *;
```

**Get Recent Measurements:**
```sql
SELECT * FROM measurements 
ORDER BY created_at DESC 
LIMIT 10;
```

**Get 30-Day Trends:**
```sql
SELECT 
  date_trunc('day', created_at) AS day,
  AVG(bmi) AS avg_bmi
FROM measurements
WHERE created_at > now() - interval '30 days'
GROUP BY day
ORDER BY day;
```

---

## 🎬 Before You Start

### What You Need

#### 1. **AWS Account**
- Sign up at https://aws.amazon.com
- You'll need a credit card (but we'll use free tier)

#### 2. **EC2 Instance Requirements**
- **OS:** Ubuntu 22.04 LTS (or 20.04 LTS)
- **Instance Type:** t2.micro (free tier eligible) or t2.small
- **Storage:** 20 GB (default 8 GB is too small)
- **Security Group:** Allow ports 22 (SSH), 80 (HTTP), 443 (HTTPS)

#### 3. **Domain Name (Optional but Recommended)**
- Purchase from GoDaddy, Namecheap, or Route53
- Point DNS A record to your EC2 public IP
- Example: `bmi-tracker.yourdomain.com`

#### 4. **SSH Key Pair**
- You'll create this when launching EC2
- Download the `.pem` file
- Keep it safe - you need it to access your server

---

## 🚀 Step-by-Step Deployment Guide

### Phase 1: Launch EC2 Instance

#### Step 1.1: Create EC2 Instance

1. **Log into AWS Console**
   - Go to https://console.aws.amazon.com
   - Navigate to EC2 Dashboard

2. **Launch Instance**
   - Click "Launch Instance" button
   - **Name:** BMI-Health-Tracker
   - **OS Image:** Ubuntu Server 22.04 LTS (Free tier eligible)
   - **Instance Type:** t2.micro (1 vCPU, 1 GB RAM)
   - **Key Pair:** Create new key pair
     - Name: `bmi-tracker-key`
     - Type: RSA
     - Format: `.pem` (for Mac/Linux) or `.ppk` (for Windows PuTTY)
     - **IMPORTANT:** Download and save this file!

3. **Configure Storage**
   - Change from 8 GB to **20 GB**
   - Type: gp3 (General Purpose SSD)

4. **Network Settings (Security Group)**
   - Create new security group: `bmi-tracker-sg`
   - Add these rules:
   
   | Type  | Protocol | Port | Source      | Description          |
   |-------|----------|------|-------------|----------------------|
   | SSH   | TCP      | 22   | My IP       | SSH access           |
   | HTTP  | TCP      | 80   | 0.0.0.0/0   | Web traffic          |
   | HTTPS | TCP      | 443  | 0.0.0.0/0   | Secure web traffic   |

5. **Review and Launch**
   - Click "Launch Instance"
   - Wait 2-3 minutes for instance to start
   - Note your **Public IPv4 Address** (e.g., 54.123.45.67)

#### Step 1.2: Connect to Your Instance

**On Mac/Linux:**
```bash
# 1. Move key to safe location
mv ~/Downloads/bmi-tracker-key.pem ~/.ssh/

# 2. Set correct permissions (MUST DO THIS)
chmod 400 ~/.ssh/bmi-tracker-key.pem

# 3. Connect to your instance
ssh -i ~/.ssh/bmi-tracker-key.pem ubuntu@YOUR_EC2_PUBLIC_IP

# Example:
# ssh -i ~/.ssh/bmi-tracker-key.pem ubuntu@54.123.45.67
```

**On Windows (using PowerShell):**
```powershell
# 1. Connect using SSH
ssh -i C:\path\to\bmi-tracker-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

**On Windows (using PuTTY):**
1. Open PuTTYgen → Load your .pem file → Save as .ppk
2. Open PuTTY
3. Host Name: `ubuntu@YOUR_EC2_PUBLIC_IP`
4. Connection → SSH → Auth → Browse for your .ppk file
5. Click "Open"

**First Time Connection:**
- You'll see: "Are you sure you want to continue connecting?"
- Type: `yes` and press Enter

✅ **You're in!** You should see:
```
ubuntu@ip-172-31-12-34:~$
```

---

### Phase 2: Install Required Software

#### Step 2.1: Update System

```bash
# Update package list
sudo apt update

# Upgrade existing packages
sudo apt upgrade -y

# This takes 2-5 minutes
```

**What this does:**
- `apt update`: Downloads list of available software versions
- `apt upgrade`: Installs latest security patches and updates
- `-y`: Automatically answers "yes" to prompts

#### Step 2.2: Install Node.js 18 LTS

```bash
# Add NodeSource repository for Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# Install Node.js and npm
sudo apt install -y nodejs

# Verify installation
node --version    # Should show: v18.x.x
npm --version     # Should show: 9.x.x or 10.x.x
```

**What is Node.js?**
- JavaScript runtime that runs on the server
- Required to run your Express backend
- npm = Node Package Manager (installs dependencies)

#### Step 2.3: Install PostgreSQL Database

```bash
# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Start PostgreSQL service
sudo systemctl start postgresql

# Enable auto-start on boot
sudo systemctl enable postgresql

# Verify it's running
sudo systemctl status postgresql
# Should show: "active (running)" in green
# Press 'q' to exit
```

**What is PostgreSQL?**
- Open-source relational database (like MySQL)
- Stores all your health measurement data
- Runs as a background service on port 5432

#### Step 2.4: Install Nginx Web Server

```bash
# Install Nginx
sudo apt install -y nginx

# Start Nginx
sudo systemctl start nginx

# Enable auto-start on boot
sudo systemctl enable nginx

# Verify it's running
sudo systemctl status nginx
# Should show: "active (running)"
# Press 'q' to exit
```

**What is Nginx?**
- Web server that serves your frontend files
- Reverse proxy: Forwards `/api/*` requests to backend
- Like a traffic cop directing requests to the right place

**Test Nginx:**
- Open browser
- Go to: `http://YOUR_EC2_PUBLIC_IP`
- You should see "Welcome to nginx!" page

#### Step 2.5: Install PM2 Process Manager

```bash
# Install PM2 globally
sudo npm install -g pm2

# Verify installation
pm2 --version
```

**What is PM2?**
- Keeps your Node.js backend running 24/7
- Automatically restarts if it crashes
- Starts on system boot
- Shows logs and monitoring

---

### Phase 3: Setup Database

#### Step 3.1: Create Database and User

```bash
# Switch to postgres user
sudo -u postgres psql

# You're now in PostgreSQL prompt (postgres=#)
```

**Inside PostgreSQL, run these commands:**
```sql
-- Create database user (replace 'your_strong_password')
CREATE USER bmi_user WITH PASSWORD 'your_strong_password';

-- Create database
CREATE DATABASE bmidb OWNER bmi_user;

-- Grant all privileges
GRANT ALL PRIVILEGES ON DATABASE bmidb TO bmi_user;

-- Exit PostgreSQL
\q
```

**Important:**
- Replace `your_strong_password` with a real password
- Example: `MySecurePass123!`
- Write it down - you'll need it in .env file

#### Step 3.2: Run Database Migrations

```bash
# First, get your project files (we'll do this in Phase 4)
# For now, let's test database connection

# Test connection (replace password)
PGPASSWORD='your_strong_password' psql -U bmi_user -d bmidb -h localhost -c "SELECT NOW();"

# Should show current date/time
```

---

### Phase 4: Deploy Your Application

#### Step 4.1: Transfer Your Code to EC2

**Option A: Using Git (Recommended)**

```bash
# On your EC2 instance
cd ~

# Install git if not already installed
sudo apt install -y git

# Clone your repository
git clone YOUR_REPOSITORY_URL
cd bmi-health-tracker

# If your repo is private, you'll need to authenticate
# GitHub now requires Personal Access Token
```

**Option B: Using SCP (Secure Copy)**

**On your local machine (NOT on EC2):**
```bash
# Navigate to your project folder
cd /path/to/your/project

# Copy entire project to EC2
scp -i ~/.ssh/bmi-tracker-key.pem -r . ubuntu@YOUR_EC2_PUBLIC_IP:~/bmi-health-tracker/
```

#### Step 4.2: Setup Backend

```bash
# On EC2, navigate to backend folder
cd ~/bmi-health-tracker/backend

# Install dependencies
npm install --production

# This installs all packages from package.json:
# - express: Web framework
# - pg: PostgreSQL client
# - cors: Cross-origin request handling
# - dotenv: Environment variable loader
```

#### Step 4.3: Configure Environment Variables

```bash
# Create .env file
nano .env

# Press Ctrl+O to save, Ctrl+X to exit
```

**Paste this configuration:**
```bash
# Server Configuration
NODE_ENV=production
PORT=3000

# Database Connection
DATABASE_URL=postgresql://bmi_user:your_strong_password@localhost:5432/bmidb
#                         ↑ user   ↑ password    ↑ host   ↑ port ↑ database

# Frontend URL (replace with your EC2 IP or domain)
FRONTEND_URL=http://54.123.45.67
# Or if you have a domain:
# FRONTEND_URL=http://bmi-tracker.yourdomain.com
```

**Important:**
- Replace `your_strong_password` with your actual database password
- Replace `54.123.45.67` with your EC2 public IP
- No spaces around the `=` sign
- No quotes around values (unless they contain special characters)

#### Step 4.4: Run Database Migration

```bash
# Still in backend folder
cd ~/bmi-health-tracker

# Run migration script
export PGPASSWORD='your_strong_password'
psql -U bmi_user -d bmidb -h localhost -f backend/migrations/001_create_measurements.sql

# You should see:
# CREATE TABLE
# CREATE INDEX
# CREATE INDEX
# Migration 001 completed successfully
```

**What this does:**
- Creates `measurements` table
- Sets up columns with constraints
- Creates indexes for faster queries

#### Step 4.5: Test Backend Manually (Before PM2)

```bash
cd ~/bmi-health-tracker/backend

# Start server temporarily
node src/server.js

# You should see:
# ✅ Database connected successfully
# 🚀 Server running on port 3000
# 📊 Environment: production
```

**Test in another terminal:**
```bash
# Open new SSH connection
ssh -i ~/.ssh/bmi-tracker-key.pem ubuntu@YOUR_EC2_PUBLIC_IP

# Test health endpoint
curl http://localhost:3000/health

# Should return:
# {"status":"ok","environment":"production"}

# Test database query
curl http://localhost:3000/api/measurements

# Should return:
# {"rows":[]}  (empty array if no data)
```

**If tests pass:**
- Press `Ctrl+C` in first terminal to stop server
- ✅ Backend is working!

**If tests fail:**
- Check logs for errors
- Verify .env file has correct DATABASE_URL
- Verify database was created: `psql -U bmi_user -d bmidb -h localhost -c "\dt"`

#### Step 4.6: Start Backend with PM2

```bash
cd ~/bmi-health-tracker/backend

# Start with PM2
pm2 start src/server.js --name bmi-backend

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup

# PM2 will show you a command like:
# sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu
# Copy and run that exact command

# Verify it's running
pm2 status

# Should show:
# ┌─────┬────────────────┬─────────┬──────┬───────┐
# │ id  │ name           │ status  │ cpu  │ memory│
# ├─────┼────────────────┼─────────┼──────┼───────┤
# │ 0   │ bmi-backend    │ online  │ 0%   │ 45 MB │
# └─────┴────────────────┴─────────┴──────┴───────┘

# View logs
pm2 logs bmi-backend

# Press Ctrl+C to stop viewing logs (app keeps running)
```

**PM2 Commands Cheat Sheet:**
```bash
pm2 status              # Show all running apps
pm2 logs bmi-backend    # View logs
pm2 restart bmi-backend # Restart app
pm2 stop bmi-backend    # Stop app (doesn't delete)
pm2 start bmi-backend   # Start stopped app
pm2 delete bmi-backend  # Remove from PM2
pm2 monit               # Real-time monitoring
```

#### Step 4.7: Build Frontend

```bash
cd ~/bmi-health-tracker/frontend

# Install dependencies
npm install

# Build for production
npm run build

# This creates 'dist' folder with optimized files
# Takes 30-60 seconds
```

**What happens during build:**
- Vite bundles all React components
- Minifies JavaScript (removes whitespace, shortens names)
- Optimizes CSS
- Creates production-ready static files in `dist/` folder

**Verify build:**
```bash
ls dist/

# You should see:
# index.html
# assets/
#   index-abc123.js
#   index-def456.css
```

#### Step 4.8: Deploy Frontend to Nginx

```bash
# Create web directory
sudo mkdir -p /var/www/bmi-health-tracker

# Copy built files
sudo cp -r dist/* /var/www/bmi-health-tracker/

# Set correct permissions
sudo chown -R www-data:www-data /var/www/bmi-health-tracker

# Verify files copied
ls /var/www/bmi-health-tracker/

# Should show index.html and assets/
```

**What these commands do:**
- `/var/www/` = standard directory for web files
- `www-data` = Nginx user (needs to own files to serve them)
- `-R` = recursive (all files and subdirectories)

#### Step 4.9: Configure Nginx

```bash
# Create Nginx configuration file
sudo nano /etc/nginx/sites-available/bmi-health-tracker
```

**Paste this configuration:**
```nginx
server {
    listen 80;
    server_name YOUR_EC2_PUBLIC_IP;  # Replace with: 54.123.45.67
    # Or if you have domain: bmi-tracker.yourdomain.com
    
    # Frontend - Serve static files
    location / {
        root /var/www/bmi-health-tracker;
        index index.html;
        try_files $uri $uri/ /index.html;
        # try_files: If file doesn't exist, serve index.html (for React Router)
    }
    
    # Backend API - Proxy to Node.js
    location /api/ {
        proxy_pass http://localhost:3000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Health check endpoint
    location /health {
        proxy_pass http://localhost:3000/health;
        proxy_http_version 1.1;
    }
}
```

**Important:**
- Replace `YOUR_EC2_PUBLIC_IP` with actual IP
- Or replace with your domain name if you have one

**Save and exit:**
- Press `Ctrl+O` → Enter → `Ctrl+X`

**Enable the site:**
```bash
# Create symbolic link to enable site
sudo ln -s /etc/nginx/sites-available/bmi-health-tracker /etc/nginx/sites-enabled/

# Remove default site (optional but recommended)
sudo rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Should show:
# nginx: configuration file /etc/nginx/nginx.conf test is successful

# Reload Nginx with new configuration
sudo systemctl reload nginx
```

**If nginx -t shows errors:**
- Check for typos in config file
- Verify all semicolons `;` are present
- Check brackets `{}` are balanced

---

### Phase 5: Configure Firewall (Optional but Recommended)

```bash
# Install UFW (Uncomplicated Firewall)
sudo apt install -y ufw

# Allow SSH (IMPORTANT - do this first or you'll lock yourself out!)
sudo ufw allow 22/tcp

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status

# Should show:
# Status: active
# To                         Action      From
# --                         ------      ----
# 22/tcp                     ALLOW       Anywhere
# 80/tcp                     ALLOW       Anywhere
# 443/tcp                    ALLOW       Anywhere
```

---

## ✅ Testing Your Deployment

### Test 1: Check All Services Running

```bash
# Check Nginx
sudo systemctl status nginx
# Should show: active (running)

# Check PostgreSQL
sudo systemctl status postgresql
# Should show: active (running)

# Check PM2/Backend
pm2 status
# Should show: bmi-backend | online

# Check backend logs
pm2 logs bmi-backend --lines 20
# Should NOT show any errors
```

### Test 2: Test Backend API Directly

```bash
# Health check
curl http://localhost:3000/health
# Expected: {"status":"ok","environment":"production"}

# Get measurements
curl http://localhost:3000/api/measurements
# Expected: {"rows":[]} or list of measurements

# Create measurement
curl -X POST http://localhost:3000/api/measurements \
  -H "Content-Type: application/json" \
  -d '{
    "weightKg": 70,
    "heightCm": 175,
    "age": 30,
    "sex": "male",
    "activity": "moderate"
  }'

# Expected: {"measurement":{...}} with calculated BMI, BMR, etc.
```

### Test 3: Test Through Nginx

```bash
# From EC2
curl http://localhost/health
# Expected: {"status":"ok","environment":"production"}

curl http://localhost/api/measurements
# Expected: {"rows":[...]}
```

### Test 4: Test Frontend in Browser

1. **Open Browser**
   - Go to: `http://YOUR_EC2_PUBLIC_IP`
   - Example: `http://54.123.45.67`

2. **Check Frontend Loads**
   - You should see: "BMI & Health Tracker" heading
   - Form with weight, height, age fields
   - Stats dashboard (if data exists)

3. **Test Form Submission**
   - Fill in form:
     - Weight: 70 kg
     - Height: 175 cm
     - Age: 30
     - Sex: Male
     - Activity: Moderate
   - Click "Add Measurement"
   - Should see: Success message
   - Dashboard should update with new stats

4. **Check Browser Console**
   - Press F12 → Console tab
   - Should NOT see any red errors
   - Should see API calls: `GET /api/measurements`

### Test 5: Test Database Directly

```bash
# Connect to database
PGPASSWORD='your_password' psql -U bmi_user -d bmidb -h localhost

# Check if measurements exist
SELECT * FROM measurements ORDER BY created_at DESC LIMIT 5;

# Should show your test data

# Exit
\q
```

### Test 6: Test from External Network

**On your phone/laptop (not on EC2):**
- Open browser
- Go to: `http://YOUR_EC2_PUBLIC_IP`
- Should work exactly like on EC2

**If it doesn't work:**
- Check AWS Security Group allows port 80
- Check EC2 public IP is correct
- Try `http://` not `https://` (we haven't setup SSL yet)

---

## 🔧 Troubleshooting Common Issues

### Issue 1: "Connection refused" when accessing website

**Symptoms:**
- Browser shows "This site can't be reached"
- Error: "ERR_CONNECTION_REFUSED"

**Causes & Solutions:**

```bash
# 1. Check Nginx is running
sudo systemctl status nginx
# If not active: sudo systemctl start nginx

# 2. Check AWS Security Group
# Go to EC2 Console → Security Groups
# Verify port 80 is allowed from 0.0.0.0/0

# 3. Check UFW firewall
sudo ufw status
# If port 80 blocked: sudo ufw allow 80/tcp

# 4. Check if port 80 is listening
sudo netstat -tlnp | grep :80
# Should show: LISTEN on 0.0.0.0:80
```

### Issue 2: Frontend loads but shows errors

**Symptoms:**
- Page loads but shows "Failed to load measurements"
- Browser console: 404 or 500 errors

**Solutions:**

```bash
# 1. Check backend is running
pm2 status
# Should show: bmi-backend | online

# 2. Check backend logs
pm2 logs bmi-backend --lines 50
# Look for errors

# 3. Test API directly
curl http://localhost:3000/health
# Should return {"status":"ok"}

# 4. Check Nginx proxy configuration
sudo nginx -t
# Should show: test is successful

# 5. Check Nginx error logs
sudo tail -f /var/log/nginx/error.log
# Look for errors when you access the page
```

### Issue 3: Database connection errors

**Symptoms:**
- Backend logs show: "Database connection failed"
- Error: "password authentication failed"

**Solutions:**

```bash
# 1. Check PostgreSQL is running
sudo systemctl status postgresql
# If not: sudo systemctl start postgresql

# 2. Verify database exists
sudo -u postgres psql -c "\l" | grep bmidb
# Should show bmidb in list

# 3. Test connection manually
PGPASSWORD='your_password' psql -U bmi_user -d bmidb -h localhost -c "SELECT 1;"
# Should return 1

# 4. Check .env file
cat ~/bmi-health-tracker/backend/.env
# Verify DATABASE_URL is correct

# 5. Check database permissions
sudo -u postgres psql
\c bmidb
\dt  -- Should show measurements table
SELECT * FROM measurements LIMIT 1;
\q

# 6. If password is wrong:
sudo -u postgres psql
ALTER USER bmi_user WITH PASSWORD 'new_password';
\q
# Then update .env file with new password
# Restart backend: pm2 restart bmi-backend
```

### Issue 4: PM2 app keeps crashing

**Symptoms:**
- `pm2 status` shows: errored or stopped
- App restarts continuously

**Solutions:**

```bash
# 1. Check detailed logs
pm2 logs bmi-backend --lines 100
# Look for error messages

# 2. Try running manually to see errors
cd ~/bmi-health-tracker/backend
node src/server.js
# Errors will appear directly

# Common errors and fixes:

# Error: "Cannot find module 'express'"
# Fix: cd ~/bmi-health-tracker/backend && npm install

# Error: "EADDRINUSE :::3000"
# Fix: Port 3000 already in use
# Find process: sudo netstat -tlnp | grep :3000
# Kill it: sudo kill -9 PROCESS_ID
# Or change PORT in .env to 3001

# Error: ".env file not found"
# Fix: Create .env file as in Step 4.3

# 3. Restart PM2 daemon
pm2 kill
pm2 start src/server.js --name bmi-backend
pm2 save
```

### Issue 5: "403 Forbidden" when accessing frontend

**Symptoms:**
- Nginx returns 403 error
- Can't access website files

**Solutions:**

```bash
# 1. Check file permissions
ls -la /var/www/bmi-health-tracker/
# Files should be owned by www-data

# 2. Fix permissions
sudo chown -R www-data:www-data /var/www/bmi-health-tracker/
sudo chmod -R 755 /var/www/bmi-health-tracker/

# 3. Check Nginx configuration
sudo nginx -t

# 4. Check Nginx error log
sudo tail -f /var/log/nginx/error.log
# Access the page and see what error appears
```

### Issue 6: Frontend works but API calls fail (CORS error)

**Symptoms:**
- Browser console: "blocked by CORS policy"
- Frontend loads but can't fetch data

**Solutions:**

```bash
# 1. Check backend .env file
cat ~/bmi-health-tracker/backend/.env | grep FRONTEND_URL
# Should match your EC2 IP or domain

# 2. Update FRONTEND_URL
nano ~/bmi-health-tracker/backend/.env
# Set: FRONTEND_URL=http://YOUR_EC2_IP
# Save and exit

# 3. Restart backend
pm2 restart bmi-backend

# 4. Verify CORS in logs
pm2 logs bmi-backend
# Should NOT show CORS errors

# 5. Test API from browser console
# Open browser console (F12)
fetch('/api/health')
  .then(r => r.json())
  .then(console.log);
// Should return {status: "ok"}
```

### Issue 7: npm install fails

**Symptoms:**
- Error: "EACCES: permission denied"
- Error: "network timeout"

**Solutions:**

```bash
# 1. Check Node.js version
node --version
# Should be v18.x.x or higher

# 2. Clear npm cache
npm cache clean --force

# 3. Remove node_modules and retry
rm -rf node_modules package-lock.json
npm install

# 4. If permission errors:
# DO NOT use sudo npm install!
# Instead, fix npm permissions:
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 5. If network timeout:
npm config set registry https://registry.npmjs.org/
npm install
```

### Issue 8: Changes not reflecting after update

**Symptoms:**
- You updated code but don't see changes
- Old version still running

**Solutions:**

```bash
# For Backend changes:
cd ~/bmi-health-tracker/backend
git pull  # If using git
pm2 restart bmi-backend
pm2 logs bmi-backend  # Verify new version

# For Frontend changes:
cd ~/bmi-health-tracker/frontend
git pull  # If using git
npm install  # If package.json changed
npm run build  # Rebuild
sudo cp -r dist/* /var/www/bmi-health-tracker/
sudo systemctl reload nginx

# Clear browser cache:
# Ctrl+Shift+R (hard refresh)
# Or: Ctrl+Shift+Delete → Clear cache
```

---

## 🔍 Maintenance & Monitoring

### Daily Monitoring

#### Check System Health

```bash
# Connect to EC2
ssh -i ~/.ssh/bmi-tracker-key.pem ubuntu@YOUR_EC2_IP

# Quick health check
pm2 status
sudo systemctl status nginx
sudo systemctl status postgresql

# Check disk space
df -h
# If root (/) is > 80% full, clean up:
sudo apt autoremove
sudo apt autoclean
pm2 flush  # Clear PM2 logs

# Check memory
free -h
# If swap is being heavily used, consider upgrading instance

# Check CPU
top
# Press 'q' to exit
```

#### View Logs

```bash
# Backend application logs
pm2 logs bmi-backend --lines 100

# Nginx access logs
sudo tail -f /var/log/nginx/access.log

# Nginx error logs
sudo tail -f /var/log/nginx/error.log

# PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-14-main.log

# System logs
sudo journalctl -u nginx -f
```

### Weekly Maintenance

```bash
# Update system packages
sudo apt update
sudo apt upgrade -y

# Update npm packages (check for vulnerabilities)
cd ~/bmi-health-tracker/backend
npm audit
npm audit fix  # Fix vulnerabilities

cd ~/bmi-health-tracker/frontend
npm audit
npm audit fix

# Backup database
cd ~
mkdir -p backups
PGPASSWORD='your_password' pg_dump -U bmi_user -h localhost bmidb > backups/bmidb_$(date +%Y%m%d).sql

# Keep only last 7 days of backups
find backups/ -name "bmidb_*.sql" -mtime +7 -delete
```

### Database Maintenance

```bash
# Connect to database
PGPASSWORD='your_password' psql -U bmi_user -d bmidb -h localhost

-- Check table size
SELECT 
  pg_size_pretty(pg_total_relation_size('measurements')) as size;

-- Check number of records
SELECT COUNT(*) FROM measurements;

-- View recent records
SELECT * FROM measurements ORDER BY created_at DESC LIMIT 10;

-- Check for old data (optional cleanup)
-- Delete records older than 1 year
-- DELETE FROM measurements WHERE created_at < now() - interval '1 year';

-- Vacuum database (reclaim space)
-- VACUUM ANALYZE measurements;

-- Exit
\q
```

### Performance Monitoring

```bash
# PM2 monitoring
pm2 monit
# Shows CPU, memory in real-time
# Press Ctrl+C to exit

# Detailed PM2 info
pm2 show bmi-backend

# Save PM2 logs to file
pm2 logs bmi-backend > ~/logs/backend_$(date +%Y%m%d).log

# Check Nginx connections
sudo netstat -an | grep :80 | wc -l
# Shows number of active connections

# Check backend response time
time curl -s http://localhost:3000/api/measurements > /dev/null
# Should be < 1 second
```

### Setting Up Monitoring Alerts

**Option 1: CloudWatch (AWS Native)**
1. Go to CloudWatch in AWS Console
2. Create alarms for:
   - CPU > 80%
   - Disk usage > 80%
   - Network errors

**Option 2: PM2 Plus (Free tier)**
```bash
# Sign up at https://pm2.io
pm2 link YOUR_SECRET_KEY YOUR_PUBLIC_KEY
# Now monitor from web dashboard
```

### Automated Backups

Create backup script:
```bash
nano ~/backup-db.sh
```

Paste:
```bash
#!/bin/bash
BACKUP_DIR="$HOME/backups"
mkdir -p $BACKUP_DIR

# Backup database
PGPASSWORD='your_password' pg_dump -U bmi_user -h localhost bmidb > $BACKUP_DIR/bmidb_$(date +%Y%m%d_%H%M%S).sql

# Delete backups older than 7 days
find $BACKUP_DIR -name "bmidb_*.sql" -mtime +7 -delete

echo "Backup completed: $(date)"
```

Make executable:
```bash
chmod +x ~/backup-db.sh
```

Schedule with cron:
```bash
crontab -e

# Add this line (daily at 2 AM):
0 2 * * * /home/ubuntu/backup-db.sh >> /home/ubuntu/backup.log 2>&1
```

---

## 🎓 Understanding Your Production Architecture

### Request Flow Diagram

```
USER'S BROWSER
     │
     │ (1) User visits http://your-ip
     ↓
┌─────────────────────────────┐
│   NGINX (Port 80)          │
│   - Static file server      │
│   - Reverse proxy           │
└─────────────────────────────┘
     │                    │
     │ (2a)              │ (2b)
     │ /*.html, *.js     │ /api/*
     │ (static files)    │ (API calls)
     ↓                    ↓
┌──────────────────┐   ┌──────────────────────┐
│   FRONTEND       │   │   BACKEND            │
│   React App      │   │   Node.js + Express  │
│   (Static Files) │   │   (Port 3000)        │
│                  │   │   Managed by PM2     │
└──────────────────┘   └──────────────────────┘
                              │
                              │ (3) SQL Query
                              ↓
                       ┌──────────────────┐
                       │   DATABASE       │
                       │   PostgreSQL     │
                       │   (Port 5432)    │
                       └──────────────────┘
```

### Port Usage

| Service    | Port | Access       | Purpose                         |
|------------|------|--------------|---------------------------------|
| Nginx      | 80   | Public       | Serves frontend, proxies API    |
| Nginx      | 443  | Public       | HTTPS (after SSL setup)         |
| Backend    | 3000 | Internal     | Express API server              |
| PostgreSQL | 5432 | Internal     | Database server                 |
| SSH        | 22   | Your IP Only | Remote server access            |

### Process Management

```bash
# What's running?
sudo systemctl status nginx     # Nginx web server
sudo systemctl status postgresql # Database
pm2 status                       # Backend app

# Start services
sudo systemctl start nginx
sudo systemctl start postgresql
pm2 start bmi-backend

# Stop services
sudo systemctl stop nginx
sudo systemctl stop postgresql
pm2 stop bmi-backend

# Restart services
sudo systemctl restart nginx
sudo systemctl restart postgresql
pm2 restart bmi-backend

# Auto-start on boot
sudo systemctl enable nginx
sudo systemctl enable postgresql
pm2 startup  # Then run the command it shows
pm2 save
```

### File Locations Reference

| Item                | Location                                          |
|---------------------|---------------------------------------------------|
| Application Code    | `~/bmi-health-tracker/`                           |
| Backend Source      | `~/bmi-health-tracker/backend/src/`               |
| Frontend Build      | `/var/www/bmi-health-tracker/`                    |
| Nginx Config        | `/etc/nginx/sites-available/bmi-health-tracker`   |
| Nginx Logs          | `/var/log/nginx/`                                 |
| Backend .env        | `~/bmi-health-tracker/backend/.env`               |
| Database Backups    | `~/backups/`                                      |
| PM2 Logs            | `~/.pm2/logs/`                                    |

---

## 🔒 Security Best Practices

### 1. Change Default Passwords

```bash
# Change database password
sudo -u postgres psql
ALTER USER bmi_user WITH PASSWORD 'NewStrongPassword123!';
\q

# Update .env file
nano ~/bmi-health-tracker/backend/.env
# Change DATABASE_URL password
pm2 restart bmi-backend
```

### 2. Setup SSH Key-Only Access

```bash
# Disable password authentication
sudo nano /etc/ssh/sshd_config

# Find and change:
PasswordAuthentication no
PubkeyAuthentication yes

# Save and restart SSH
sudo systemctl restart sshd
```

### 3. Configure Fail2Ban (Brute Force Protection)

```bash
# Install fail2ban
sudo apt install -y fail2ban

# Create local config
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Edit config
sudo nano /etc/fail2ban/jail.local

# Find [sshd] section, ensure:
enabled = true
maxretry = 3
bantime = 3600

# Start fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Check status
sudo fail2ban-client status sshd
```

### 4. Setup SSL/HTTPS with Let's Encrypt (FREE)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate (REQUIRES DOMAIN NAME)
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Follow prompts:
# - Enter email
# - Agree to terms
# - Choose: Redirect HTTP to HTTPS (option 2)

# Auto-renewal is configured
# Test renewal:
sudo certbot renew --dry-run
```

### 5. Database Security

```bash
# Limit PostgreSQL to localhost only
sudo nano /etc/postgresql/14/main/postgresql.conf

# Find and set:
listen_addresses = 'localhost'

# Restart PostgreSQL
sudo systemctl restart postgresql
```

### 6. Rate Limiting (Prevent API Abuse)

Add to backend/src/server.js:
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});

app.use('/api/', limiter);
```

Install package:
```bash
cd ~/bmi-health-tracker/backend
npm install express-rate-limit
pm2 restart bmi-backend
```

---

## 📊 Monitoring Dashboard

### View Application Metrics

```bash
# Create monitoring script
nano ~/monitor.sh
```

Paste:
```bash
#!/bin/bash

echo "========================================"
echo "BMI Health Tracker - System Status"
echo "========================================"
echo ""

echo "📊 Services Status:"
echo "-------------------"
systemctl is-active nginx && echo "✅ Nginx: Running" || echo "❌ Nginx: Stopped"
systemctl is-active postgresql && echo "✅ PostgreSQL: Running" || echo "❌ PostgreSQL: Stopped"
pm2 describe bmi-backend &> /dev/null && echo "✅ Backend: Running" || echo "❌ Backend: Stopped"

echo ""
echo "💾 Disk Usage:"
df -h / | tail -1 | awk '{print $5 " used (" $3 " / " $2 ")"}'

echo ""
echo "🧠 Memory Usage:"
free -h | grep Mem | awk '{print $3 " / " $2 " (" int($3/$2*100) "%)"}'

echo ""
echo "📈 Database Stats:"
PGPASSWORD='your_password' psql -U bmi_user -d bmidb -h localhost -t -c "SELECT COUNT(*) FROM measurements;" | xargs echo "Total Measurements:"

echo ""
echo "🌐 Last 5 API Calls:"
sudo tail -5 /var/log/nginx/access.log | grep "/api/"

echo ""
echo "========================================"
```

Make executable and run:
```bash
chmod +x ~/monitor.sh
./monitor.sh
```

---

## 🆘 Getting Help

### Community Resources
- **AWS Forums:** https://forums.aws.amazon.com/
- **Stack Overflow:** Tag questions with `aws-ec2`, `nginx`, `node.js`, `postgresql`
- **Node.js Docs:** https://nodejs.org/docs
- **PostgreSQL Docs:** https://www.postgresql.org/docs/
- **PM2 Docs:** https://pm2.keymetrics.io/docs/

### Common Search Terms
- "nginx reverse proxy nodejs"
- "pm2 process keep stopping"
- "postgresql connection refused"
- "aws ec2 security group"
- "react vite production build"

---

## 📝 Next Steps After Deployment

1. **Setup Domain Name**
   - Purchase domain from GoDaddy/Namecheap
   - Point A record to your EC2 IP
   - Update Nginx config with domain

2. **Enable HTTPS/SSL**
   - Use Let's Encrypt (free)
   - Follow SSL setup section above

3. **Setup Monitoring**
   - Use PM2 Plus or CloudWatch
   - Setup email alerts

4. **Implement Backups**
   - Schedule automated database backups
   - Store backups in S3 bucket

5. **Add Authentication**
   - Implement user login
   - Use JWT tokens

6. **Setup CI/CD**
   - GitHub Actions to auto-deploy
   - Run tests before deployment

7. **Performance Optimization**
   - Enable Nginx caching
   - Add database indexes
   - Implement CDN for static files

---

## 🎉 Congratulations!

You've successfully deployed a full-stack 3-tier web application to AWS EC2!

**What you've learned:**
- ✅ AWS EC2 instance management
- ✅ Linux server administration
- ✅ Node.js backend deployment
- ✅ React frontend build and deployment
- ✅ PostgreSQL database setup
- ✅ Nginx web server configuration
- ✅ Reverse proxy setup
- ✅ Process management with PM2
- ✅ Security hardening
- ✅ Troubleshooting production issues

**Your application is now:**
- 🌐 Accessible to anyone on the internet
- 🔄 Running 24/7 with automatic restarts
- 💾 Storing data persistently in PostgreSQL
- ⚡ Optimized for production
- 🔒 Secured with best practices

---

## 📞 Need Help?

If you encounter issues not covered in this guide:

1. Check the logs (most errors appear there)
2. Search for the specific error message
3. Post on Stack Overflow with relevant logs
4. Check AWS documentation

**Remember:** The key to troubleshooting is:
1. Identify which tier has the problem (frontend/backend/database)
2. Check logs for that tier
3. Test each tier independently
4. Fix one issue at a time

Good luck with your deployment! 🚀
