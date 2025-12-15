#!/bin/bash
set -e  # Exit on any error

echo "Starting deployment..."

# Navigate to project
cd /home/ubuntu/single-ec2-three-tier-app

# Pull latest code
echo "Pulling latest code..."
git pull origin main

# Install backend dependencies
echo "Installing backend dependencies..."
cd backend
npm install --production

# Copy pre-built frontend from CI
echo "Deploying frontend..."
cd /home/ubuntu
if [ -d "frontend-build" ]; then
  sudo cp -r frontend-build/* /var/www/bmi-health-tracker/
  rm -rf frontend-build
  echo "Frontend deployed"
fi

# Restart backend
echo "Restarting backend..."
export PATH=$PATH:/home/ubuntu/.npm-global/bin
pm2 restart bmi-backend

# Wait for backend to be ready
echo "Waiting for backend to start..."
sleep 5

# Health check
echo "Running health check..."
HEALTH=$(curl -s http://localhost:3000/health || echo "failed")
if [[ $HEALTH == *"ok"* ]]; then
  echo "Deployment successful!"
  pm2 logs bmi-backend --lines 10 --nostream
  exit 0
else
  echo "ERROR: Health check failed!"
  pm2 logs bmi-backend --lines 50 --nostream
  exit 1
fi
