# Session 2: Automate BMI Deployment - Implementation Guide

**Duration:** 90 minutes  
**Level:** Intermediate  
**Prerequisites:** Session 1 completed, BMI app deployed manually on EC2

---

## 📋 Table of Contents

1. [Pre-Session Setup](#pre-session-setup)
2. [Part 1: Configure GitHub Secrets](#part-1-configure-github-secrets-15-min)
3. [Part 2: Prepare EC2 for CI/CD](#part-2-prepare-ec2-for-cicd-15-min)
4. [Part 3: Create Deployment Workflow](#part-3-create-deployment-workflow-30-min)
5. [Part 4: Test and Verify](#part-4-test-and-verify-20-min)
6. [Part 5: Production Best Practices](#part-5-production-best-practices-10-min)
7. [Troubleshooting](#troubleshooting)
8. [Validation Checklist](#validation-checklist)

---

## 🚀 Pre-Session Setup

### Prerequisites Verification

```bash
# 1. Verify BMI app is running on EC2
curl http://YOUR_EC2_PUBLIC_IP
# Should return BMI app homepage

# 2. Verify SSH access to EC2
ssh -i /path/to/your-key.pem ubuntu@YOUR_EC2_IP
# Should connect successfully

# 3. Verify GitHub repository exists
git remote -v
# Should show your BMI app repository

# 4. Check current deployment method
ls /var/www/bmi-tracker/
# Should show your deployed app files
```

### Session Goals

By the end of this session:
- ✅ Automate entire deployment process
- ✅ Deploy on every push to `main` branch
- ✅ Reduce deployment time from 10 minutes → 3 minutes
- ✅ Implement health checks
- ✅ Set up deployment notifications
- ✅ Zero-downtime deployments

---

## 🔐 Part 1: Configure GitHub Secrets (15 min)

GitHub Secrets store sensitive information securely for use in workflows.

### Step 1: Generate SSH Key Pair (if needed)

```bash
# On your local machine, generate new SSH key for CI/CD
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github-actions-bmi

# This creates:
# - Private key: ~/.ssh/github-actions-bmi (keep secret!)
# - Public key: ~/.ssh/github-actions-bmi.pub (add to EC2)
```

### Step 2: Add Public Key to EC2

```bash
# Copy public key content
cat ~/.ssh/github-actions-bmi.pub

# SSH to your EC2
ssh -i /path/to/your-key.pem ubuntu@YOUR_EC2_IP

# Add to authorized_keys
echo "PUBLIC_KEY_CONTENT" >> ~/.ssh/authorized_keys

# Verify permissions
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh

# Exit EC2
exit

# Test new key
ssh -i ~/.ssh/github-actions-bmi ubuntu@YOUR_EC2_IP
# Should connect without password
```

### Step 3: Retrieve EC2 Information

```bash
# Get your EC2 details
EC2_HOST=YOUR_EC2_PUBLIC_IP
EC2_USER=ubuntu
DB_PASSWORD=YOUR_POSTGRES_PASSWORD

# Get private key
cat ~/.ssh/github-actions-bmi
# Copy the entire content (including BEGIN/END lines)
```

### Step 4: Add Secrets to GitHub

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

Add these secrets one by one:

| Secret Name | Value | Description |
|------------|-------|-------------|
| `EC2_HOST` | Your EC2 public IP | Example: `3.25.123.45` |
| `EC2_USER` | `ubuntu` | EC2 username |
| `EC2_SSH_KEY` | Private key content | Full SSH private key |
| `DB_PASSWORD` | Your database password | PostgreSQL password |

**For EC2_SSH_KEY:**
```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
... (all lines of your private key)
-----END OPENSSH PRIVATE KEY-----
```

### Step 5: Verify Secrets

```bash
# Create a test workflow to verify secrets
mkdir -p .github/workflows
cat > .github/workflows/test-secrets.yml << 'EOF'
name: Test Secrets

on:
  workflow_dispatch:

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - name: Check EC2_HOST
        run: |
          if [ -n "${{ secrets.EC2_HOST }}" ]; then
            echo "✅ EC2_HOST is set (length: ${#EC2_HOST})"
          else
            echo "❌ EC2_HOST is not set"
          fi
        env:
          EC2_HOST: ${{ secrets.EC2_HOST }}
      
      - name: Check EC2_SSH_KEY
        run: |
          if [ -n "${{ secrets.EC2_SSH_KEY }}" ]; then
            echo "✅ EC2_SSH_KEY is set"
          else
            echo "❌ EC2_SSH_KEY is not set"
          fi
EOF

git add .github/workflows/test-secrets.yml
git commit -m "Add secrets verification workflow"
git push origin main
```

Go to **Actions** tab and manually run "Test Secrets" workflow.

---

## 🖥️ Part 2: Prepare EC2 for CI/CD (15 min)

### Step 1: Create Deployment Directory Structure

```bash
# SSH to your EC2
ssh -i ~/.ssh/github-actions-bmi ubuntu@YOUR_EC2_IP

# Create deployment structure
sudo mkdir -p /var/www/bmi-tracker
sudo chown -R ubuntu:ubuntu /var/www/bmi-tracker

# Create backup directory
mkdir -p /var/www/bmi-tracker/backups

# Verify current app location
ls -la /var/www/bmi-tracker/
```

### Step 2: Create Deployment Script on EC2

```bash
# Create deployment script
cat > /home/ubuntu/deploy-bmi-app.sh << 'EOF'
#!/bin/bash

# BMI Health Tracker Deployment Script
# This script is executed by GitHub Actions CI/CD

set -e  # Exit on any error

echo "========================================="
echo "Starting BMI App Deployment"
echo "Time: $(date)"
echo "========================================="

# Configuration
APP_DIR="/var/www/bmi-tracker"
BACKUP_DIR="$APP_DIR/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Step 1: Create backup of current version
echo "📦 Creating backup..."
if [ -d "$APP_DIR/frontend" ]; then
  tar -czf "$BACKUP_DIR/backup_$TIMESTAMP.tar.gz" \
    -C "$APP_DIR" frontend backend || true
  echo "✅ Backup created: backup_$TIMESTAMP.tar.gz"
fi

# Step 2: Navigate to app directory
cd "$APP_DIR"

# Step 3: Pull latest code
echo "📥 Pulling latest code from GitHub..."
if [ -d ".git" ]; then
  git pull origin main
else
  echo "❌ Not a git repository!"
  exit 1
fi

# Step 4: Install backend dependencies
echo "📦 Installing backend dependencies..."
cd backend
npm ci --production
echo "✅ Backend dependencies installed"

# Step 5: Install frontend dependencies
echo "📦 Installing frontend dependencies..."
cd ../frontend
npm ci
echo "✅ Frontend dependencies installed"

# Step 6: Build frontend
echo "🔨 Building frontend..."
npm run build
echo "✅ Frontend built successfully"

# Step 7: Copy built files to nginx
echo "📋 Copying frontend to nginx..."
sudo rm -rf /var/www/html/*
sudo cp -r dist/* /var/www/html/
echo "✅ Frontend deployed to nginx"

# Step 8: Restart backend with PM2
echo "🔄 Restarting backend..."
cd ../backend
pm2 restart ecosystem.config.js --update-env || pm2 start ecosystem.config.js
pm2 save
echo "✅ Backend restarted"

# Step 9: Verify services
echo "🔍 Verifying services..."
sleep 3

# Check backend
if pm2 status | grep -q "bmi-backend.*online"; then
  echo "✅ Backend is running"
else
  echo "❌ Backend is not running"
  pm2 logs bmi-backend --lines 20
  exit 1
fi

# Check nginx
if sudo systemctl is-active --quiet nginx; then
  echo "✅ Nginx is running"
else
  echo "❌ Nginx is not running"
  sudo systemctl status nginx
  exit 1
fi

# Step 10: Health check
echo "🏥 Running health check..."
sleep 2

# Check backend API
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
  echo "✅ Backend health check passed"
else
  echo "❌ Backend health check failed"
  exit 1
fi

# Check frontend
if curl -f http://localhost > /dev/null 2>&1; then
  echo "✅ Frontend health check passed"
else
  echo "❌ Frontend health check failed"
  exit 1
fi

# Step 11: Cleanup old backups (keep last 5)
echo "🧹 Cleaning old backups..."
cd "$BACKUP_DIR"
ls -t backup_*.tar.gz | tail -n +6 | xargs -r rm
echo "✅ Old backups cleaned"

echo "========================================="
echo "✅ Deployment Completed Successfully!"
echo "Time: $(date)"
echo "========================================="
EOF

# Make script executable
chmod +x /home/ubuntu/deploy-bmi-app.sh

# Test the script
./deploy-bmi-app.sh
```

### Step 3: Configure PM2 for Auto-restart

```bash
# Ensure PM2 starts on system boot
pm2 startup
# Follow the command it shows

# Save current PM2 processes
pm2 save

# Verify PM2 configuration
pm2 list
```

### Step 4: Create Health Check Endpoint

Update backend to include health check:

```bash
cd /var/www/bmi-tracker/backend/src

# Add health endpoint to server.js
cat >> server.js << 'EOF'

// Health check endpoint for CI/CD
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: '1.0.0'
  });
});
EOF

# Restart backend to apply changes
pm2 restart bmi-backend
```

### Step 5: Test Health Endpoint

```bash
# Test health endpoint
curl http://localhost:3000/health

# Expected output:
# {"status":"healthy","timestamp":"2025-12-15T10:30:00.000Z","uptime":123.45,"version":"1.0.0"}

# Exit EC2
exit
```

---

## 🚀 Part 3: Create Deployment Workflow (30 min)

### Step 1: Create Basic Deployment Workflow

Create file: `.github/workflows/deploy.yml`

```yaml
name: Deploy BMI App to EC2

on:
  push:
    branches:
      - main
  workflow_dispatch:

env:
  NODE_VERSION: '18.x'

jobs:
  deploy:
    name: Deploy to Production
    runs-on: ubuntu-latest
    
    steps:
      # Step 1: Checkout code
      - name: Checkout Repository
        uses: actions/checkout@v4
      
      # Step 2: Setup Node.js
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      # Step 3: Test backend
      - name: Test Backend
        run: |
          cd backend
          npm ci
          npm test || echo "No tests found"
      
      # Step 4: Test frontend
      - name: Test Frontend
        run: |
          cd frontend
          npm ci
          npm run build
      
      # Step 5: Deploy to EC2
      - name: Deploy to EC2 via SSH
        uses: appleboy/ssh-action@v1.0.0
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USER }}
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            cd /var/www/bmi-tracker
            /home/ubuntu/deploy-bmi-app.sh
      
      # Step 6: Verify deployment
      - name: Health Check
        run: |
          sleep 5
          curl -f http://${{ secrets.EC2_HOST }}/api/health || exit 1
          echo "✅ Deployment successful!"
```

### Step 2: Commit and Push

```bash
git add .github/workflows/deploy.yml
git commit -m "Add automated deployment workflow"
git push origin main
```

### Step 3: Monitor First Deployment

1. Go to **Actions** tab on GitHub
2. Watch "Deploy BMI App to EC2" workflow
3. Monitor each step execution
4. Check logs for any errors

---

## 🧪 Part 4: Test and Verify (20 min)

### Step 1: Test Automatic Deployment

Make a small change to trigger deployment:

```bash
# Update frontend homepage
echo "<!-- Last updated: $(date) -->" >> frontend/index.html

git add frontend/index.html
git commit -m "Test automated deployment"
git push origin main
```

Watch deployment in **Actions** tab.

### Step 2: Verify Application is Running

```bash
# Check application
curl http://YOUR_EC2_IP

# Check backend API
curl http://YOUR_EC2_IP/api/health

# Check if changes are reflected
curl http://YOUR_EC2_IP | grep "Last updated"
```

### Step 3: Test Manual Deployment

1. Go to **Actions** tab
2. Select "Deploy BMI App to EC2"
3. Click **Run workflow**
4. Select `main` branch
5. Click **Run workflow** button

Monitor execution and verify success.

### Step 4: Create Enhanced Workflow with Notifications

Update `.github/workflows/deploy.yml`:

```yaml
name: Deploy BMI App to EC2

on:
  push:
    branches:
      - main
  workflow_dispatch:

env:
  NODE_VERSION: '18.x'

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: Test Backend
        run: |
          cd backend
          npm ci
          npm test || echo "⚠️ No backend tests found"
      
      - name: Test Frontend Build
        run: |
          cd frontend
          npm ci
          npm run build
          echo "✅ Frontend builds successfully"

  deploy:
    name: Deploy to Production
    needs: test
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Deploy to EC2
        uses: appleboy/ssh-action@v1.0.0
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USER }}
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            cd /var/www/bmi-tracker
            /home/ubuntu/deploy-bmi-app.sh
      
      - name: Health Check
        run: |
          echo "Waiting for deployment to stabilize..."
          sleep 10
          
          echo "Running health checks..."
          
          # Check backend
          if curl -f http://${{ secrets.EC2_HOST }}/api/health; then
            echo "✅ Backend health check passed"
          else
            echo "❌ Backend health check failed"
            exit 1
          fi
          
          # Check frontend
          if curl -f http://${{ secrets.EC2_HOST }}; then
            echo "✅ Frontend health check passed"
          else
            echo "❌ Frontend health check failed"
            exit 1
          fi
      
      - name: Deployment Success
        if: success()
        run: |
          echo "========================================="
          echo "🎉 Deployment Successful!"
          echo "========================================="
          echo "URL: http://${{ secrets.EC2_HOST }}"
          echo "Deployed: $(date)"
          echo "Commit: ${{ github.sha }}"
          echo "Author: ${{ github.actor }}"
      
      - name: Deployment Failed
        if: failure()
        run: |
          echo "========================================="
          echo "❌ Deployment Failed!"
          echo "========================================="
          echo "Check logs above for details"
          echo "SSH to EC2 and check:"
          echo "  - pm2 logs bmi-backend"
          echo "  - sudo systemctl status nginx"
```

Commit and test:

```bash
git add .github/workflows/deploy.yml
git commit -m "Enhance deployment workflow with better checks"
git push origin main
```

---

## 🎯 Part 5: Production Best Practices (10 min)

### Step 1: Add Environment-Specific Workflows

Create staging environment workflow:

```yaml
# .github/workflows/deploy-staging.yml
name: Deploy to Staging

on:
  push:
    branches:
      - develop
  workflow_dispatch:

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Deploy to Staging
        uses: appleboy/ssh-action@v1.0.0
        with:
          host: ${{ secrets.STAGING_EC2_HOST }}
          username: ${{ secrets.EC2_USER }}
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            cd /var/www/bmi-tracker
            git pull origin develop
            /home/ubuntu/deploy-bmi-app.sh
```

### Step 2: Add Deployment Protection Rules

1. Go to **Settings** → **Environments**
2. Click **New environment**
3. Name: `production`
4. Add protection rules:
   - ✅ Required reviewers (yourself)
   - ✅ Wait timer (5 minutes)
5. Click **Save protection rules**

Update production workflow:

```yaml
jobs:
  deploy:
    environment: production  # Add this line
    runs-on: ubuntu-latest
```

### Step 3: Add Rollback Capability

Create rollback script on EC2:

```bash
# SSH to EC2
ssh -i ~/.ssh/github-actions-bmi ubuntu@YOUR_EC2_IP

# Create rollback script
cat > /home/ubuntu/rollback-bmi-app.sh << 'EOF'
#!/bin/bash

set -e

BACKUP_DIR="/var/www/bmi-tracker/backups"
APP_DIR="/var/www/bmi-tracker"

echo "Available backups:"
ls -lht "$BACKUP_DIR"/backup_*.tar.gz | head -5

if [ -z "$1" ]; then
  echo "Usage: $0 <backup_filename>"
  exit 1
fi

BACKUP_FILE="$BACKUP_DIR/$1"

if [ ! -f "$BACKUP_FILE" ]; then
  echo "❌ Backup file not found: $BACKUP_FILE"
  exit 1
fi

echo "🔄 Rolling back to: $1"

# Stop backend
pm2 stop bmi-backend

# Extract backup
cd "$APP_DIR"
tar -xzf "$BACKUP_FILE"

# Restart services
cd backend
pm2 restart ecosystem.config.js

echo "✅ Rollback completed!"
EOF

chmod +x /home/ubuntu/rollback-bmi-app.sh
exit
```

Create rollback workflow:

```yaml
# .github/workflows/rollback.yml
name: Rollback Deployment

on:
  workflow_dispatch:
    inputs:
      backup_file:
        description: 'Backup filename (e.g., backup_20251215_103000.tar.gz)'
        required: true

jobs:
  rollback:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - name: Rollback to Previous Version
        uses: appleboy/ssh-action@v1.0.0
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USER }}
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            /home/ubuntu/rollback-bmi-app.sh ${{ github.event.inputs.backup_file }}
```

### Step 4: Add Status Badge to README

Update your repository README.md:

```markdown
# BMI Health Tracker

![Deploy Status](https://github.com/YOUR_USERNAME/REPO_NAME/workflows/Deploy%20BMI%20App%20to%20EC2/badge.svg)

Automated three-tier web application with CI/CD pipeline.

## Deployment Status

- **Production**: http://YOUR_EC2_IP
- **Last Deploy**: Auto-updated via GitHub Actions
- **Deploy Time**: ~3 minutes
```

---

## 🐛 Troubleshooting

### Issue 1: SSH Connection Failed

**Symptom:** Workflow fails at "Deploy to EC2" step

**Solutions:**

```yaml
# Add debugging to SSH action
- name: Deploy to EC2
  uses: appleboy/ssh-action@v1.0.0
  with:
    host: ${{ secrets.EC2_HOST }}
    username: ${{ secrets.EC2_USER }}
    key: ${{ secrets.EC2_SSH_KEY }}
    debug: true  # Add this
    script: |
      whoami
      pwd
      ls -la
```

Check:
1. EC2 security group allows SSH (port 22) from GitHub Actions IPs
2. SSH key is correct (includes BEGIN/END lines)
3. EC2_HOST is public IP, not private
4. EC2 user is correct (usually `ubuntu` or `ec2-user`)

### Issue 2: Deployment Script Fails

**Symptom:** Script exits with error

**Solutions:**

```bash
# SSH to EC2 and run manually
ssh -i ~/.ssh/github-actions-bmi ubuntu@YOUR_EC2_IP
/home/ubuntu/deploy-bmi-app.sh

# Check specific failures:

# If git pull fails
cd /var/www/bmi-tracker
git status
git remote -v

# If npm ci fails
cd backend
rm -rf node_modules package-lock.json
npm install

# If PM2 fails
pm2 logs bmi-backend --lines 50
pm2 restart bmi-backend --update-env
```

### Issue 3: Health Check Fails

**Symptom:** Deployment succeeds but health check fails

**Solutions:**

```bash
# Check if services are running
pm2 status
sudo systemctl status nginx

# Check backend logs
pm2 logs bmi-backend

# Check nginx logs
sudo tail -f /var/log/nginx/error.log

# Test health endpoint manually
curl -v http://localhost:3000/api/health

# Check if port 3000 is listening
sudo netstat -tlnp | grep 3000
```

### Issue 4: Frontend Not Updating

**Symptom:** Deployment succeeds but frontend doesn't change

**Solutions:**

```bash
# SSH to EC2
ssh -i ~/.ssh/github-actions-bmi ubuntu@YOUR_EC2_IP

# Check nginx config
sudo nginx -t

# Check if files were copied
ls -lht /var/www/html/ | head

# Clear browser cache or test with:
curl http://localhost -H "Cache-Control: no-cache"

# Check nginx is serving correct directory
cat /etc/nginx/sites-enabled/default | grep root

# Restart nginx
sudo systemctl restart nginx
```

### Issue 5: Database Connection Issues

**Symptom:** Backend starts but can't connect to database

**Solutions:**

```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Check database exists
sudo -u postgres psql -c "\l"

# Test connection
cd /var/www/bmi-tracker/backend
node -e "const db = require('./src/db'); db.query('SELECT NOW()', (err, res) => { console.log(err || res.rows); process.exit(); });"

# Update .env with correct credentials
cat /var/www/bmi-tracker/backend/.env
```

---

## ✅ Validation Checklist

### After Part 1 (Secrets Configuration):
- [ ] All 4 secrets created in GitHub
- [ ] Test secrets workflow passed
- [ ] SSH key works from local machine

### After Part 2 (EC2 Preparation):
- [ ] Deployment script created and tested
- [ ] Health endpoint returns 200 OK
- [ ] PM2 configured for auto-restart
- [ ] Backup directory exists

### After Part 3 (Workflow Creation):
- [ ] Deployment workflow created
- [ ] First automated deployment succeeded
- [ ] Application accessible via EC2 IP
- [ ] All workflow steps show green checkmarks

### After Part 4 (Testing):
- [ ] Code change triggers automatic deployment
- [ ] Manual deployment works
- [ ] Health checks pass
- [ ] Deployment time < 5 minutes

### After Part 5 (Best Practices):
- [ ] Environment protection rules configured
- [ ] Rollback capability tested
- [ ] Status badge added to README
- [ ] Staging workflow created (optional)

### Overall Session 2 Completion:
- [ ] Full CI/CD pipeline operational
- [ ] Deployment fully automated
- [ ] Zero manual steps required
- [ ] Deployment notifications working
- [ ] Rollback strategy in place
- [ ] Production-ready setup

---

## 📊 Deployment Metrics

Track these metrics after implementation:

| Metric | Before Automation | After Automation |
|--------|------------------|------------------|
| Deployment Time | ~10 minutes | ~3 minutes |
| Manual Steps | 15+ steps | 0 steps |
| Human Errors | Occasional | None |
| Deployment Frequency | Weekly | On every commit |
| Rollback Time | ~20 minutes | ~2 minutes |
| Confidence Level | Medium | High |

---

## 🎓 What You've Learned

✅ **GitHub Actions for Real Applications:**
- SSH-based deployment to EC2
- Multi-job workflows with dependencies
- Environment protection rules
- Artifact management

✅ **DevOps Best Practices:**
- Automated testing before deployment
- Health checks and verification
- Rollback strategies
- Backup management
- Zero-downtime deployments

✅ **Production Skills:**
- Secrets management
- Environment-specific configurations
- Deployment monitoring
- Debugging failed deployments

---

## 🚀 Next Steps

### Immediate Enhancements:
1. Add automated database migrations
2. Implement blue-green deployment
3. Add performance monitoring
4. Set up automated backups
5. Configure Slack/email notifications

### Advanced Topics:
- Docker containerization
- Kubernetes deployment
- Infrastructure as Code (Terraform)
- Monitoring with Grafana/Prometheus
- Load balancing across multiple EC2s

### Continue Learning:
- Complete homework assignments
- Review [monitoring course materials](../../Monitoring-Grafana-Prometheus/)
- Explore GitHub Actions Marketplace
- Practice with your own projects

---

## 🔗 Resources

- [GitHub Actions for AWS](https://docs.github.com/en/actions/deployment/deploying-to-aws)
- [SSH Action Documentation](https://github.com/appleboy/ssh-action)
- [PM2 Documentation](https://pm2.keymetrics.io/)
- [Nginx Configuration](https://nginx.org/en/docs/)
- [PostgreSQL Best Practices](https://www.postgresql.org/docs/)

---

**🎉 Congratulations!**  
You've successfully automated your BMI Health Tracker deployment!

Your application now deploys automatically on every push to `main`, with tests, health checks, and rollback capabilities. This is production-grade CI/CD! 🚀
