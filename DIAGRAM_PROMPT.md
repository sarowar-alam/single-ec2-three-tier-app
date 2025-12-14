# Flow Diagram Prompt for BMI Health Tracker

## Prompt for Nano Banana Pro (or any Diagram Tool)

```
Create a comprehensive flow diagram for a 3-tier web application called "BMI Health Tracker" deployed on AWS EC2. Show all components, API endpoints, communication flows, and data flow with the following specifications:

## ARCHITECTURE OVERVIEW

Create three distinct horizontal tiers with clear separation:

### TIER 1 - PRESENTATION LAYER (Top)
- Component: "React Frontend (Vite Build)"
- Location: "/var/www/bmi-health-tracker"
- Technology: React 18, Axios, Chart.js, Vite
- Access: Public via browser (Port 80/443)
- Static files served by Nginx

### TIER 2 - APPLICATION LAYER (Middle)
- Component: "Node.js + Express Backend"
- Location: "~/bmi-health-tracker/backend"
- Port: 3000 (Internal)
- Process Manager: PM2
- Technology: Express.js, CORS, body-parser
- Modules:
  * server.js (main entry point)
  * routes.js (API endpoints)
  * db.js (PostgreSQL connection pool)
  * calculations.js (BMI/BMR formulas)

### TIER 3 - DATA LAYER (Bottom)
- Component: "PostgreSQL Database"
- Database Name: "bmidb"
- User: "bmi_user"
- Port: 5432 (Internal)
- Table: "measurements" (with 11 columns)

### INFRASTRUCTURE COMPONENT (Left Side)
- Component: "Nginx Web Server"
- Port: 80 (HTTP), 443 (HTTPS)
- Roles:
  * Static file server for frontend
  * Reverse proxy for API calls
  * Load balancer

## API ENDPOINTS & DATA FLOWS

Create 4 distinct endpoint flows with different colors:

### ENDPOINT 1: Health Check (Green)
**Route:** GET /health
**Flow:**
1. Browser → Nginx (Port 80)
2. Nginx → Backend (localhost:3000/health)
3. Backend checks status
4. Backend → Nginx: {"status": "ok", "environment": "production"}
5. Nginx → Browser

**Label:** "Health Check Endpoint - System Status"

### ENDPOINT 2: Create Measurement (Blue)
**Route:** POST /api/measurements
**Flow:**
1. User fills form in React component (MeasurementForm.jsx)
2. Frontend validates: weightKg > 0, heightCm > 0, age > 0, sex in ['male','female']
3. axios.post('/api/measurements', data) → Nginx (Port 80)
4. Nginx proxy_pass → Backend (localhost:3000/api/measurements)
5. Backend receives request → routes.js handler
6. Backend validates required fields
7. Backend calls calculations.js:
   - Calculate BMI = weightKg / (heightCm/100)²
   - Calculate BMR using Mifflin-St Jeor equation
   - Calculate dailyCalories = BMR × activity multiplier
8. Backend → Database: INSERT INTO measurements (...) RETURNING *
9. Database validates constraints, inserts row, returns new record
10. Database → Backend: Complete measurement object with ID
11. Backend → Nginx → Frontend: {"measurement": {...}}
12. Frontend updates UI, shows success message, refreshes list

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

**Response:**
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

**Label:** "Create New Measurement - POST Endpoint"

### ENDPOINT 3: Get All Measurements (Orange)
**Route:** GET /api/measurements
**Flow:**
1. Frontend component mounts (App.jsx useEffect)
2. axios.get('/api/measurements') → Nginx
3. Nginx proxy_pass → Backend (localhost:3000/api/measurements)
4. Backend → routes.js: GET handler
5. Backend → Database: SELECT * FROM measurements ORDER BY created_at DESC
6. Database queries table, returns all rows
7. Database → Backend: Array of measurement objects
8. Backend → Nginx → Frontend: {"rows": [...]}
9. Frontend processes data:
   - Extract latest measurement for dashboard stats
   - Display first 10 in recent list
   - Calculate total count

**Response:**
```json
{
  "rows": [
    {
      "id": 3,
      "bmi": "23.5",
      "bmr": 1705,
      "daily_calories": 2643,
      "created_at": "2025-12-14T10:30:00Z"
    },
    {
      "id": 2,
      "bmi": "23.2",
      "bmr": 1698,
      "created_at": "2025-12-13T08:15:00Z"
    }
  ]
}
```

**Label:** "Get All Measurements - Retrieve Historical Data"

### ENDPOINT 4: Get 30-Day Trends (Purple)
**Route:** GET /api/measurements/trends
**Flow:**
1. TrendChart component mounts (TrendChart.jsx useEffect)
2. axios.get('/api/measurements/trends') → Nginx
3. Nginx proxy_pass → Backend (localhost:3000/api/measurements/trends)
4. Backend → routes.js: GET trends handler
5. Backend → Database: Complex SQL query:
   ```sql
   SELECT 
     date_trunc('day', created_at) AS day,
     AVG(bmi) AS avg_bmi
   FROM measurements
   WHERE created_at > now() - interval '30 days'
   GROUP BY day
   ORDER BY day
   ```
6. Database aggregates data by day, calculates averages
7. Database → Backend: Array of {day, avg_bmi}
8. Backend → Nginx → Frontend: {"rows": [...]}
9. Frontend formats for Chart.js:
   - Extract dates for x-axis labels
   - Extract BMI values for y-axis data
   - Render line chart with gradient

**Response:**
```json
{
  "rows": [
    {"day": "2025-11-14T00:00:00Z", "avg_bmi": "22.5"},
    {"day": "2025-11-15T00:00:00Z", "avg_bmi": "22.7"},
    {"day": "2025-12-14T00:00:00Z", "avg_bmi": "23.1"}
  ]
}
```

**Label:** "Get BMI Trends - Chart Data for 30 Days"

## COMMUNICATION PROTOCOLS

Show these connections with labeled arrows:

### Frontend ↔ Backend Communication
**Protocol:** HTTP/HTTPS
**Method:** RESTful API calls via Axios
**Headers:**
- Content-Type: application/json
- Accept: application/json
- Origin: (for CORS validation)

**CORS Configuration:**
- Development: Vite proxy (vite.config.js) forwards /api → localhost:3000
- Production: Nginx proxy_pass forwards /api → localhost:3000
- Backend validates origin via CORS middleware

**Connection:** 
- Request: Frontend → Nginx (Port 80) → Backend (Port 3000)
- Response: Backend → Nginx → Frontend

### Backend ↔ Database Communication
**Protocol:** PostgreSQL Wire Protocol (TCP)
**Library:** node-pg (PostgreSQL client for Node.js)
**Connection String:** 
```
postgresql://bmi_user:password@localhost:5432/bmidb
```

**Connection Pool:**
- Max connections: 20
- Idle timeout: 30 seconds
- Connection timeout: 2 seconds

**Query Types:**
- Parameterized queries (SQL injection protection)
- Prepared statements: $1, $2, $3, etc.

**Connection:**
- Backend creates connection pool on startup
- Each API request borrows connection from pool
- Connection returns to pool after query completes

### User ↔ Frontend Communication
**Protocol:** HTTP/HTTPS
**Access:** Web Browser → Public IP or Domain
**Port:** 80 (HTTP) or 443 (HTTPS)
**Files Served:** index.html, bundled JS, CSS, assets

## NGINX ROUTING LOGIC

Show Nginx as a central hub with two routing paths:

### Path 1: Static File Requests
**Pattern:** /, /*.html, /*.js, /*.css, /assets/*
**Action:** Serve from /var/www/bmi-health-tracker
**Example:** GET / → serve index.html

### Path 2: API Requests
**Pattern:** /api/*, /health
**Action:** proxy_pass to http://localhost:3000
**Headers Added:**
- X-Real-IP
- X-Forwarded-For
- X-Forwarded-Proto
- Host
**Timeouts:** 60 seconds

## DATABASE SCHEMA

Show the measurements table structure in a box:

**Table:** measurements
**Columns:**
1. id (SERIAL PRIMARY KEY)
2. weight_kg (NUMERIC(5,2) NOT NULL)
3. height_cm (NUMERIC(5,2) NOT NULL)
4. age (INTEGER NOT NULL)
5. sex (VARCHAR(10) NOT NULL)
6. activity_level (VARCHAR(30))
7. bmi (NUMERIC(4,1) NOT NULL)
8. bmi_category (VARCHAR(30))
9. bmr (INTEGER)
10. daily_calories (INTEGER)
11. created_at (TIMESTAMPTZ DEFAULT now())

**Indexes:**
- idx_measurements_created_at (created_at DESC)
- idx_measurements_bmi (bmi)

**Constraints:**
- CHECK weight_kg > 0 AND weight_kg < 1000
- CHECK height_cm > 0 AND height_cm < 300
- CHECK age > 0 AND age < 150
- CHECK sex IN ('male', 'female')
- CHECK activity_level IN ('sedentary', 'light', 'moderate', 'active', 'very_active')

## COMPONENT INTERACTIONS

Create swim lanes for each tier showing:

### Frontend Components (React)
- App.jsx (main container, state management)
- MeasurementForm.jsx (user input, validation)
- TrendChart.jsx (Chart.js visualization)
- api.js (axios instance with interceptors)

**Interactions:**
- Form submission → api.post('/measurements')
- Component mount → api.get('/measurements')
- Chart load → api.get('/measurements/trends')
- Success → state update → UI refresh

### Backend Components (Node.js)
- server.js (Express app, middleware, error handling)
- routes.js (endpoint handlers, validation)
- db.js (connection pool, query execution)
- calculations.js (BMI/BMR formulas)

**Middleware Chain:**
1. CORS validation
2. Body parsing (JSON)
3. Route matching
4. Request handler
5. Error handler

### Database Operations (PostgreSQL)
- INSERT: Create new measurement
- SELECT: Retrieve measurements
- SELECT with GROUP BY: Aggregate trends
- Date functions: date_trunc, interval
- Aggregate functions: AVG, COUNT

## ERROR FLOWS

Show error handling paths with red dashed lines:

### Frontend Validation Errors
- Invalid input → Show error message → Don't send request

### Backend Validation Errors
- Missing fields → 400 Bad Request → {"error": "Missing required fields"}
- Invalid values → 400 Bad Request → {"error": "Invalid values"}

### Database Errors
- Connection failed → 500 Internal Server Error
- Constraint violation → 400 Bad Request
- Query timeout → 500 Internal Server Error

### Network Errors
- Backend unreachable → Connection refused → Show error in UI
- CORS blocked → Browser console error → Check CORS config
- Timeout → Request timed out → Show retry option

## DEPLOYMENT ENVIRONMENT

Show EC2 instance as container with:
- **Instance Type:** t2.micro (AWS Free Tier)
- **OS:** Ubuntu 22.04 LTS
- **IP:** Public IPv4 address (e.g., 54.123.45.67)
- **Security Group Rules:**
  * Port 22 (SSH) - Admin access only
  * Port 80 (HTTP) - Public access
  * Port 443 (HTTPS) - Public access
- **Running Processes:**
  * Nginx (systemd service)
  * PostgreSQL (systemd service)
  * PM2 (Node.js process manager)
  * Backend (managed by PM2)

## VISUAL STYLING REQUIREMENTS

**Color Coding:**
- Frontend tier: Light Blue (#E3F2FD)
- Backend tier: Light Orange (#FFF3E0)
- Database tier: Light Green (#E8F5E9)
- Nginx: Light Purple (#F3E5F5)
- GET requests: Green arrows
- POST requests: Blue arrows
- Database queries: Dark green arrows
- Error flows: Red dashed arrows

**Labels:**
- Show HTTP methods (GET, POST)
- Show ports (80, 3000, 5432)
- Show protocols (HTTP, PostgreSQL)
- Show file paths where relevant
- Show response codes (200, 201, 400, 500)

**Icons (if supported):**
- 🌐 for Browser/User
- 🖥️ for Nginx server
- ⚙️ for Backend server
- 💾 for Database
- ☁️ for AWS EC2
- 📊 for Chart component
- 📝 for Form component

**Layout:**
- Horizontal swim lanes for each tier
- Vertical flow from top (user) to bottom (database)
- Nginx on the left as routing gateway
- Group related components in boxes
- Number the steps in each flow (1, 2, 3...)

**Legend:**
Include a legend showing:
- Solid arrow = Request
- Dashed arrow = Response
- Red dashed = Error
- Different colors for different endpoint types

## TECHNOLOGY STACK SUMMARY (Add as sidebar)

**Frontend:**
- React 18.2.0
- Vite 5.0.0
- Axios 1.4.0
- Chart.js 4.4.0
- React-ChartJS-2 5.2.0

**Backend:**
- Node.js 18.x
- Express 4.18.2
- pg (node-postgres) 8.10.0
- CORS 2.8.5
- dotenv 16.0.0
- body-parser 1.20.2

**Database:**
- PostgreSQL 14+
- Connection pool size: 20

**Infrastructure:**
- Nginx 1.18+
- PM2 (latest)
- Ubuntu 22.04 LTS
- AWS EC2 t2.micro

**Protocols:**
- HTTP/HTTPS
- PostgreSQL Wire Protocol
- WebSocket (if needed)
- JSON (data format)

Create a clear, professional flow diagram that shows:
1. All 4 API endpoints with complete request/response flows
2. All three tiers with their components
3. Nginx routing logic (static files vs API proxy)
4. Database schema and queries
5. Error handling paths
6. CORS and security layers
7. Port numbers and protocols
8. Technology stack for each component
9. Numbered steps for each flow
10. Color-coded components by tier

Make it suitable for:
- Developer onboarding
- Architecture documentation
- DevOps deployment reference
- Troubleshooting guide
- Stakeholder presentations

The diagram should be detailed enough that a developer can understand the entire system flow just by looking at it.
```

## Alternative Simplified Prompt (If Above Is Too Complex)

```
Create a flow diagram for BMI Health Tracker showing:

**Three Tiers:**
1. Frontend (React) - Port 80 via Nginx
2. Backend (Node.js/Express) - Port 3000 via PM2
3. Database (PostgreSQL) - Port 5432

**Four API Endpoints:**
1. GET /health → Health check
2. POST /api/measurements → Create new BMI measurement
3. GET /api/measurements → Get all measurements
4. GET /api/measurements/trends → Get 30-day BMI trends

**Show:**
- User in browser → Nginx → Backend → Database
- Nginx serves static files (/) and proxies API (/api/*)
- Each endpoint's request/response flow
- Database table: measurements (11 columns)
- Technology: React, Node.js, Express, PostgreSQL, Nginx, PM2
- Deployed on AWS EC2 Ubuntu

**Color code:**
- Frontend: Blue
- Backend: Orange  
- Database: Green
- GET: Green arrows
- POST: Blue arrows
- Errors: Red dashed

**Include:** Ports, protocols, HTTP methods, file locations, and numbered steps for each flow.
```

## How to Use This Prompt

1. **Copy the full prompt** (or simplified version) above
2. **Paste into Nano Banana Pro** or any AI diagram tool like:
   - Mermaid Live Editor (https://mermaid.live)
   - Draw.io / Diagrams.net
   - Lucidchart
   - Excalidraw
   - Claude with diagram plugins
   - ChatGPT with DALL-E for diagrams
   - Microsoft Visio

3. **If using Mermaid.js**, you can use these working diagrams:

### Option 1: Architecture Overview (Simple & Clean)

```mermaid
graph TB
    User["👤 User Browser"]
    
    subgraph AWS["☁️ AWS EC2 Instance - Ubuntu 22.04"]
        direction TB
        Nginx["🖥️ Nginx Web Server<br/>Port: 80/443<br/>Static Files + Reverse Proxy"]
        
        subgraph Tier1["📱 TIER 1: Frontend"]
            FrontendFiles["React App (Built)<br/>Location: /var/www/bmi-health-tracker<br/>Components: App.jsx, Form, Chart"]
        end
        
        subgraph Tier2["⚙️ TIER 2: Backend"]
            Backend["Node.js + Express<br/>Port: 3000<br/>Process Manager: PM2<br/>Files: server.js, routes.js, db.js"]
        end
        
        subgraph Tier3["💾 TIER 3: Database"]
            DB["PostgreSQL<br/>Port: 5432<br/>Database: bmidb<br/>Table: measurements"]
        end
    end
    
    User -->|"HTTP GET /"| Nginx
    Nginx -->|"Serve Static Files"| FrontendFiles
    FrontendFiles -.->|"Renders in Browser"| User
    
    User -->|"HTTP POST/GET /api/*"| Nginx
    Nginx -->|"proxy_pass"| Backend
    Backend -->|"SQL Queries"| DB
    DB -.->|"Query Results"| Backend
    Backend -.->|"JSON Response"| Nginx
    Nginx -.->|"Response"| User
    
    style Tier1 fill:#E3F2FD
    style Tier2 fill:#FFF3E0
    style Tier3 fill:#E8F5E9
    style Nginx fill:#F3E5F5
```

### Option 2: Detailed API Endpoints Flow

```mermaid
graph LR
    User["👤 User"]
    
    subgraph Browser["🌐 Browser"]
        FormComp["MeasurementForm.jsx"]
        AppComp["App.jsx"]
        ChartComp["TrendChart.jsx"]
    end
    
    Nginx["Nginx<br/>:80"]
    Backend["Express API<br/>:3000"]
    DB["PostgreSQL<br/>:5432"]
    
    User -->|"Fills Form"| FormComp
    FormComp -->|"POST /api/measurements"| Nginx
    Nginx -->|"Proxy"| Backend
    Backend -->|"INSERT INTO measurements"| DB
    
    AppComp -->|"GET /api/measurements"| Nginx
    Nginx -->|"Proxy"| Backend
    Backend -->|"SELECT * FROM measurements"| DB
    
    ChartComp -->|"GET /api/measurements/trends"| Nginx
    Nginx -->|"Proxy"| Backend
    Backend -->|"SELECT AVG(bmi) GROUP BY day"| DB
    
    DB -.->|"Returns Data"| Backend
    Backend -.->|"JSON Response"| Nginx
    Nginx -.->|"Response"| Browser
    
    style FormComp fill:#BBDEFB
    style AppComp fill:#BBDEFB
    style ChartComp fill:#BBDEFB
    style Backend fill:#FFE0B2
    style DB fill:#C8E6C9
```

### Option 3: Sequence Diagram (Request/Response Flow)

```mermaid
sequenceDiagram
    participant U as 👤 User
    participant B as 🌐 Browser
    participant N as Nginx :80
    participant API as Backend :3000
    participant DB as PostgreSQL :5432
    
    Note over U,DB: 1️⃣ Health Check Flow
    B->>N: GET /health
    N->>API: Proxy to localhost:3000/health
    API-->>N: {"status": "ok"}
    N-->>B: 200 OK
    
    Note over U,DB: 2️⃣ Create Measurement Flow
    U->>B: Fill form (weight, height, age)
    B->>N: POST /api/measurements
    N->>API: Proxy with JSON body
    API->>API: Validate input
    API->>API: Calculate BMI, BMR, calories
    API->>DB: INSERT INTO measurements(...)
    DB-->>API: Returns new record with ID
    API-->>N: 201 Created + measurement data
    N-->>B: JSON response
    B->>B: Update UI with new stats
    
    Note over U,DB: 3️⃣ Get All Measurements Flow
    B->>N: GET /api/measurements
    N->>API: Proxy request
    API->>DB: SELECT * FROM measurements ORDER BY created_at DESC
    DB-->>API: Array of measurements
    API-->>N: {"rows": [...]}
    N-->>B: 200 OK
    B->>B: Display in UI
    
    Note over U,DB: 4️⃣ Get Trends Flow
    B->>N: GET /api/measurements/trends
    N->>API: Proxy request
    API->>DB: SELECT AVG(bmi), date_trunc('day')...
    DB-->>API: Aggregated 30-day data
    API-->>N: {"rows": [{"day": "...", "avg_bmi": "..."}]}
    N-->>B: 200 OK
    B->>B: Render Chart.js visualization
```

### Option 4: Full System Architecture with All Components

```mermaid
graph TB
    User["👤 User<br/>Web Browser"]
    
    subgraph EC2["☁️ AWS EC2 Instance - t2.micro"]
        subgraph WebServer["Nginx Configuration"]
            NginxStatic["Route: /<br/>Action: Serve Static Files<br/>Location: /var/www/bmi-health-tracker"]
            NginxAPI["Route: /api/*<br/>Action: proxy_pass<br/>Target: localhost:3000"]
        end
        
        subgraph FrontendLayer["📱 Frontend - React + Vite"]
            IndexHTML["index.html"]
            ReactApp["App.jsx<br/>- State Management<br/>- Load measurements<br/>- Display stats"]
            FormComponent["MeasurementForm.jsx<br/>- Input validation<br/>- API calls"]
            ChartComponent["TrendChart.jsx<br/>- Chart.js<br/>- 30-day trends"]
            APIClient["api.js<br/>- Axios instance<br/>- Base URL: /api"]
        end
        
        subgraph BackendLayer["⚙️ Backend - Node.js + Express"]
            Server["server.js<br/>- CORS config<br/>- Middleware<br/>- Port 3000"]
            Routes["routes.js<br/>- POST /api/measurements<br/>- GET /api/measurements<br/>- GET /api/measurements/trends"]
            DBModule["db.js<br/>- Connection Pool (max: 20)<br/>- Query executor"]
            Calculations["calculations.js<br/>- BMI formula<br/>- BMR formula<br/>- Calorie calculation"]
            PM2["PM2 Process Manager<br/>- Auto restart<br/>- Log management"]
        end
        
        subgraph DatabaseLayer["💾 Database - PostgreSQL"]
            PGServer["PostgreSQL Server<br/>Port: 5432<br/>User: bmi_user"]
            MeasurementsTable["measurements table<br/>- id (PK)<br/>- weight_kg, height_cm<br/>- age, sex, activity_level<br/>- bmi, bmi_category<br/>- bmr, daily_calories<br/>- created_at"]
        end
    end
    
    User -->|"1. HTTP Request"| NginxStatic
    User -->|"2. API Request"| NginxAPI
    
    NginxStatic -->|"Serve"| IndexHTML
    IndexHTML -->|"Loads"| ReactApp
    ReactApp -->|"Contains"| FormComponent
    ReactApp -->|"Contains"| ChartComponent
    
    NginxAPI -->|"Proxy"| Server
    FormComponent -->|"axios POST"| APIClient
    ChartComponent -->|"axios GET"| APIClient
    APIClient -->|"HTTP"| Routes
    
    Server -->|"Routes to"| Routes
    Routes -->|"Uses"| Calculations
    Routes -->|"Queries via"| DBModule
    PM2 -->|"Manages"| Server
    
    DBModule -->|"SQL Queries"| PGServer
    PGServer -->|"CRUD Operations"| MeasurementsTable
    
    MeasurementsTable -.->|"Results"| DBModule
    DBModule -.->|"Data"| Routes
    Routes -.->|"JSON"| Server
    Server -.->|"Response"| NginxAPI
    NginxAPI -.->|"Response"| User
    
    style FrontendLayer fill:#E3F2FD
    style BackendLayer fill:#FFF3E0
    style DatabaseLayer fill:#E8F5E9
    style WebServer fill:#F3E5F5
```

### Option 5: POST /api/measurements Detailed Flow

```mermaid
graph TD
    Start["User Submits Form"]
    
    Start --> Validate["Frontend Validation<br/>- Check required fields<br/>- weightKg > 0<br/>- heightCm > 0"]
    
    Validate -->|Valid| SendReq["axios.post('/api/measurements', data)"]
    Validate -->|Invalid| ShowError["Show Error Message"]
    
    SendReq --> Nginx["Nginx receives request<br/>POST /api/measurements"]
    Nginx --> Proxy["proxy_pass to<br/>localhost:3000/api/measurements"]
    
    Proxy --> BackendRecv["Express receives request<br/>routes.js handler"]
    BackendRecv --> BackendValidate["Backend Validation<br/>- Required fields present?<br/>- Values positive?"]
    
    BackendValidate -->|Invalid| Return400["Return 400 Bad Request<br/>{error: 'Missing fields'}"]
    BackendValidate -->|Valid| Calculate["Calculate Metrics<br/>calculations.js"]
    
    Calculate --> CalcBMI["BMI = weight / (height/100)²<br/>Result: 22.9"]
    CalcBMI --> CalcBMR["BMR = 10×weight + 6.25×height - 5×age + s<br/>Result: 1680"]
    CalcBMR --> CalcCal["Daily Calories = BMR × activity<br/>Result: 2604"]
    
    CalcCal --> PrepareSQL["Prepare SQL Query<br/>INSERT INTO measurements<br/>with $1, $2... parameters"]
    PrepareSQL --> ExecuteSQL["db.query(sql, values)"]
    
    ExecuteSQL --> DBCheck["PostgreSQL Validates"]
    DBCheck -->|Constraint Fails| Return500["Return 500 Error"]
    DBCheck -->|Success| DBInsert["Insert row<br/>Generate ID<br/>Set timestamp"]
    
    DBInsert --> DBReturn["RETURNING *<br/>Returns complete record"]
    DBReturn --> BackendResp["Backend formats response<br/>status: 201 Created"]
    BackendResp --> NginxResp["Nginx forwards response"]
    NginxResp --> FrontendRecv["Frontend receives data"]
    
    FrontendRecv --> UpdateUI["Update UI<br/>- Show success message<br/>- Refresh measurement list<br/>- Update dashboard stats"]
    
    Return400 --> FrontendRecv
    Return500 --> FrontendRecv
    ShowError --> End["End"]
    UpdateUI --> End
    
    style Calculate fill:#FFE082
    style DBInsert fill:#AED581
    style UpdateUI fill:#81D4FA
```

4. **Request specific format** if needed:
   - "Create as Mermaid diagram"
   - "Create as flowchart with swim lanes"
   - "Create as sequence diagram"
   - "Create as architecture diagram"

5. **Iterate** - Ask for adjustments:
   - "Add more details to endpoint 2"
   - "Show error flows"
   - "Add database schema"
   - "Make it more colorful"
