#!/bin/bash

################################################################################
# BMI Health Tracker - Complete Deployment Script for AWS EC2 Ubuntu
#
# This script automates the ENTIRE deployment process based on the
# BMI_Health_Tracker_Deployment_Readme.md manual deployment guide.
#
# Usage: ./deploy.sh [--skip-nginx] [--skip-backup]
#
# Options:
#   --skip-nginx   : Skip Nginx configuration (if already configured)
#   --skip-backup  : Skip creating backup of current deployment
#   --fresh        : Fresh deployment (clean install)
################################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/bmi_deployments_backup"
FRONTEND_DIR="/var/www/bmi-health-tracker"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Parse command line arguments
SKIP_NGINX=false
SKIP_BACKUP=false
FRESH_DEPLOY=false

for arg in "$@"; do
    case $arg in
        --skip-nginx)
            SKIP_NGINX=true
            shift
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --fresh)
            FRESH_DEPLOY=true
            shift
            ;;
        --help)
            echo "Usage: ./deploy.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-nginx    Skip Nginx configuration"
            echo "  --skip-backup   Skip creating backup"
            echo "  --fresh         Fresh deployment (clean install)"
            echo "  --help          Show this help message"
            exit 0
            ;;
    esac
done

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo ""
    echo -e "${BLUE}========================================"
    echo -e "$1"
    echo -e "========================================${NC}"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}


################################################################################
# Prerequisites Check
################################################################################

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local errors=0
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed"
        print_info "Install with: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
        ((errors++))
    else
        print_success "Node.js $(node -v) found"
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed"
        ((errors++))
    else
        print_success "npm $(npm -v) found"
    fi
    
    # Check PostgreSQL
    if ! command -v psql &> /dev/null; then
        print_error "PostgreSQL is not installed"
        print_info "Install with: sudo apt install -y postgresql postgresql-contrib"
        ((errors++))
    else
        print_success "PostgreSQL found"
    fi
    
    # Check PostgreSQL is running
    if ! sudo systemctl is-active --quiet postgresql; then
        print_error "PostgreSQL service is not running"
        print_info "Start with: sudo systemctl start postgresql"
        ((errors++))
    else
        print_success "PostgreSQL service is running"
    fi
    
    # Check Nginx
    if ! command -v nginx &> /dev/null; then
        print_error "Nginx is not installed"
        print_info "Install with: sudo apt install -y nginx"
        ((errors++))
    else
        print_success "Nginx found"
    fi
    
    # Check PM2
    if ! command -v pm2 &> /dev/null; then
        print_warning "PM2 not found. Will install it..."
        npm install -g pm2
        print_success "PM2 installed"
    else
        print_success "PM2 found"
    fi
    
    if [ $errors -gt 0 ]; then
        print_error "Prerequisites check failed. Please install missing components."
        exit 1
    fi
    
    print_success "All prerequisites met"
}

################################################################################
# Backup Current Deployment
################################################################################

backup_current_deployment() {
    if [ "$SKIP_BACKUP" = true ]; then
        print_info "Skipping backup (--skip-backup flag set)"
        return 0
    fi
    
    print_header "Creating Backup of Current Deployment"
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    BACKUP_PATH="$BACKUP_DIR/deployment_$TIMESTAMP"
    mkdir -p "$BACKUP_PATH"
    
    # Backup backend if exists
    if [ -d "$PROJECT_DIR/backend/node_modules" ]; then
        print_info "Backing up backend..."
        cp -r "$PROJECT_DIR/backend/.env" "$BACKUP_PATH/" 2>/dev/null || print_warning "No .env to backup"
        print_success "Backend backed up"
    fi
    
    # Backup frontend deployment if exists
    if [ -d "$FRONTEND_DIR" ]; then
        print_info "Backing up deployed frontend..."
        sudo cp -r "$FRONTEND_DIR" "$BACKUP_PATH/frontend_deployed"
        print_success "Frontend backed up"
    fi
    
    # Backup Nginx config if exists
    if [ -f "/etc/nginx/sites-available/bmi-health-tracker" ]; then
        print_info "Backing up Nginx configuration..."
        sudo cp /etc/nginx/sites-available/bmi-health-tracker "$BACKUP_PATH/"
        print_success "Nginx config backed up"
    fi
    
    # Backup database
    print_info "Backing up database..."
    if [ -f "$PROJECT_DIR/backend/.env" ]; then
        source "$PROJECT_DIR/backend/.env"
        PGPASSWORD=$DB_PASSWORD pg_dump -U ${DB_USER:-bmi_user} -h localhost ${DB_NAME:-bmidb} > "$BACKUP_PATH/database_backup.sql" 2>/dev/null || print_warning "Database backup skipped"
    fi
    
    print_success "Backup created at: $BACKUP_PATH"
    
    # Keep only last 5 backups
    cd "$BACKUP_DIR"
    ls -t | tail -n +6 | xargs -r rm -rf
    print_info "Kept last 5 backups, removed older ones"
}

################################################################################
# Backend Deployment
################################################################################

deploy_backend() {
    print_header "Deploying Backend"
    
    cd "$PROJECT_DIR/backend"
    
    # Check .env file
    if [ ! -f .env ]; then
        print_error ".env file not found in backend directory"
        
        if [ -f .env.example ]; then
            print_info "Found .env.example. Creating .env from example..."
            cp .env.example .env
            print_warning "Please edit backend/.env with your database credentials"
            print_info "Edit with: nano $PROJECT_DIR/backend/.env"
            read -p "Press Enter after editing .env file..."
        else
            print_error "No .env or .env.example found"
            exit 1
        fi
    fi
    print_success ".env file exists"
    
    # Source .env for later use
    set -a
    source .env
    set +a
    
    # Clean install if fresh deployment
    if [ "$FRESH_DEPLOY" = true ]; then
        print_info "Fresh deployment: removing node_modules..."
        rm -rf node_modules package-lock.json
    fi
    
    # Install dependencies
    print_info "Installing backend dependencies..."
    npm install --production
    print_success "Backend dependencies installed"
    
    # Run database migrations
    print_info "Running database migrations..."
    if [ -d "migrations" ]; then
        for migration in migrations/*.sql; do
            if [ -f "$migration" ]; then
                print_info "Applying migration: $(basename $migration)"
                PGPASSWORD=$DB_PASSWORD psql -U ${DB_USER:-bmi_user} -d ${DB_NAME:-bmidb} -h localhost -f "$migration" || print_warning "Migration may have already been applied"
            fi
        done
        print_success "Migrations completed"
    else
        print_warning "No migrations directory found"
    fi
    
    # Test database connection
    print_info "Testing database connection..."
    if PGPASSWORD=$DB_PASSWORD psql -U ${DB_USER:-bmi_user} -d ${DB_NAME:-bmidb} -h localhost -c "SELECT 1;" > /dev/null 2>&1; then
        print_success "Database connection successful"
    else
        print_error "Database connection failed"
        print_info "Check your .env file credentials"
        exit 1
    fi
}

################################################################################
# Frontend Deployment
################################################################################

deploy_frontend() {
    print_header "Deploying Frontend"
    
    cd "$PROJECT_DIR/frontend"
    
    # Clean install if fresh deployment
    if [ "$FRESH_DEPLOY" = true ]; then
        print_info "Fresh deployment: removing node_modules..."
        rm -rf node_modules package-lock.json dist
    fi
    
    # Install dependencies
    print_info "Installing frontend dependencies..."
    npm install
    print_success "Frontend dependencies installed"
    
    # Build for production
    print_info "Building frontend for production..."
    npm run build
    
    if [ ! -d "dist" ]; then
        print_error "Build failed: dist directory not created"
        exit 1
    fi
    print_success "Frontend built successfully"
    
    # Deploy to Nginx directory
    print_info "Deploying frontend to $FRONTEND_DIR..."
    sudo mkdir -p "$FRONTEND_DIR"
    sudo rm -rf "$FRONTEND_DIR"/*
    sudo cp -r dist/* "$FRONTEND_DIR/"
    sudo chown -R www-data:www-data "$FRONTEND_DIR"
    sudo chmod -R 755 "$FRONTEND_DIR"
    print_success "Frontend deployed to $FRONTEND_DIR"
    
    # Verify deployment
    if [ -f "$FRONTEND_DIR/index.html" ]; then
        print_success "Verified: index.html exists in deployment directory"
    else
        print_error "Deployment verification failed: index.html not found"
        exit 1
    fi
}

################################################################################
# PM2 Process Management
################################################################################

setup_pm2() {
    print_header "Configuring PM2 Process Manager"
    
    cd "$PROJECT_DIR/backend"
    
    # Stop existing process
    if pm2 describe bmi-backend > /dev/null 2>&1; then
        print_info "Stopping existing bmi-backend process..."
        pm2 stop bmi-backend
        pm2 delete bmi-backend
        print_success "Existing process stopped"
    fi
    
    # Start backend with PM2
    print_info "Starting backend with PM2..."
    pm2 start src/server.js --name bmi-backend --env production
    
    # Save PM2 process list
    pm2 save
    print_success "Backend started and saved to PM2"
    
    # Setup auto-start on reboot
    print_info "Configuring PM2 auto-start on reboot..."
    pm2 startup systemd -u $USER --hp $HOME > /tmp/pm2_startup_cmd.txt 2>&1 || true
    
    # Extract and run the command
    if grep -q "sudo" /tmp/pm2_startup_cmd.txt; then
        STARTUP_CMD=$(grep "sudo env" /tmp/pm2_startup_cmd.txt | head -1)
        if [ -n "$STARTUP_CMD" ]; then
            print_info "Executing PM2 startup command..."
            eval "$STARTUP_CMD" || print_warning "PM2 startup command may have already been configured"
        fi
    fi
    
    print_success "PM2 configured for auto-start"
    
    # Display PM2 status
    echo ""
    pm2 status
}

################################################################################
# Nginx Configuration
################################################################################

configure_nginx() {
    if [ "$SKIP_NGINX" = true ]; then
        print_info "Skipping Nginx configuration (--skip-nginx flag set)"
        return 0
    fi
    
    print_header "Configuring Nginx"
    
    NGINX_CONFIG="/etc/nginx/sites-available/bmi-health-tracker"
    
    # Get server name
    print_info "Detecting server name..."
    SERVER_NAME=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "YOUR_DOMAIN_OR_IP")
    
    if [ "$SERVER_NAME" != "YOUR_DOMAIN_OR_IP" ]; then
        print_success "Detected EC2 public IP: $SERVER_NAME"
    else
        print_warning "Could not detect EC2 IP"
        read -p "Enter your domain or EC2 public IP: " SERVER_NAME
    fi
    
    # Create Nginx configuration
    print_info "Creating Nginx configuration..."
    sudo tee "$NGINX_CONFIG" > /dev/null << EOF
server {
    listen 80;
    listen [::]:80;
    
    server_name $SERVER_NAME;

    # Frontend static files
    root $FRONTEND_DIR;
    index index.html;

    # Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript 
               application/x-javascript application/xml+rss 
               application/javascript application/json;

    # Frontend routing (React Router)
    location / {
        try_files \$uri \$uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # Backend API proxy
    location /api/ {
        proxy_pass http://127.0.0.1:3000/api/;
        proxy_http_version 1.1;
        
        # WebSocket support
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        
        # Standard proxy headers
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Disable caching for API
        proxy_cache_bypass \$http_upgrade;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Hide nginx version
    server_tokens off;

    # Logs
    access_log /var/log/nginx/bmi-access.log;
    error_log /var/log/nginx/bmi-error.log;
}
EOF
    
    print_success "Nginx configuration created"
    
    # Enable site
    print_info "Enabling site..."
    sudo ln -sf "$NGINX_CONFIG" /etc/nginx/sites-enabled/bmi-health-tracker
    
    # Remove default site if exists
    if [ -f /etc/nginx/sites-enabled/default ]; then
        print_info "Removing default Nginx site..."
        sudo rm /etc/nginx/sites-enabled/default
    fi
    
    # Test Nginx configuration
    print_info "Testing Nginx configuration..."
    if sudo nginx -t; then
        print_success "Nginx configuration is valid"
    else
        print_error "Nginx configuration test failed"
        exit 1
    fi
    
    # Restart Nginx
    print_info "Restarting Nginx..."
    sudo systemctl restart nginx
    
    # Verify Nginx is running
    if sudo systemctl is-active --quiet nginx; then
        print_success "Nginx is running"
    else
        print_error "Nginx failed to start"
        sudo systemctl status nginx
        exit 1
    fi
    
    # Enable Nginx on boot
    sudo systemctl enable nginx
    print_success "Nginx enabled on boot"
}

################################################################################
# Health Checks
################################################################################

run_health_checks() {
    print_header "Running Health Checks"
    
    sleep 3  # Give services time to stabilize
    
    # Check backend
    print_info "Checking backend health..."
    if curl -f http://localhost:3000/api/measurements > /dev/null 2>&1; then
        print_success "Backend API is responding"
    else
        print_warning "Backend API check failed (might be normal if endpoint requires setup)"
    fi
    
    # Check frontend
    print_info "Checking frontend..."
    if curl -f http://localhost > /dev/null 2>&1; then
        print_success "Frontend is serving correctly"
    else
        print_warning "Frontend check failed"
    fi
    
    # Check PM2 status
    print_info "Checking PM2 process..."
    if pm2 describe bmi-backend | grep -q "online"; then
        print_success "Backend process is online"
    else
        print_error "Backend process is not running properly"
        pm2 logs bmi-backend --lines 20 --nostream
    fi
    
    # Check database connection
    print_info "Checking database connection..."
    cd "$PROJECT_DIR/backend"
    source .env
    if PGPASSWORD=$DB_PASSWORD psql -U ${DB_USER:-bmi_user} -d ${DB_NAME:-bmidb} -h localhost -c "SELECT COUNT(*) FROM measurements;" > /dev/null 2>&1; then
        MEASUREMENT_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -U ${DB_USER:-bmi_user} -d ${DB_NAME:-bmidb} -h localhost -tAc "SELECT COUNT(*) FROM measurements;")
        print_success "Database connection OK (Measurements: $MEASUREMENT_COUNT)"
    else
        print_warning "Database connection check failed"
    fi
}

################################################################################
# Display Summary
################################################################################

display_summary() {
    print_header "Deployment Complete!"
    
    # Get server IP
    SERVER_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "YOUR_IP")
    
    echo ""
    echo -e "${GREEN}✓ Backend deployed and running with PM2${NC}"
    echo -e "${GREEN}✓ Frontend built and deployed to Nginx${NC}"
    echo -e "${GREEN}✓ Database migrations applied${NC}"
    echo -e "${GREEN}✓ Nginx configured and running${NC}"
    echo -e "${GREEN}✓ Health checks completed${NC}"
    echo ""
    
    print_info "Application Access:"
    echo "  URL: http://$SERVER_IP"
    echo ""
    
    print_info "Useful Commands:"
    echo "  View backend logs:       pm2 logs bmi-backend"
    echo "  Restart backend:         pm2 restart bmi-backend"
    echo "  View PM2 status:         pm2 status"
    echo "  View Nginx logs:         sudo tail -f /var/log/nginx/bmi-*.log"
    echo "  Test Nginx config:       sudo nginx -t"
    echo "  Restart Nginx:           sudo systemctl restart nginx"
    echo "  Connect to database:     psql -U bmi_user -d bmidb -h localhost"
    echo ""
    
    print_info "Backup Location:"
    echo "  $BACKUP_PATH"
    echo ""
    
    print_warning "Next Steps:"
    echo "  1. Test the application in your browser"
    echo "  2. Configure SSL with: sudo certbot --nginx -d YOUR_DOMAIN"
    echo "  3. Monitor logs for any issues"
    echo "  4. Set up regular database backups"
    echo ""
}

################################################################################
# Main Execution
################################################################################

main() {
    print_header "BMI Health Tracker - Deployment Script"
    
    echo "This script will deploy the BMI Health Tracker application"
    echo ""
    echo "Options:"
    [ "$SKIP_NGINX" = true ] && echo "  - Skipping Nginx configuration"
    [ "$SKIP_BACKUP" = true ] && echo "  - Skipping backup"
    [ "$FRESH_DEPLOY" = true ] && echo "  - Fresh deployment (clean install)"
    echo ""
    
    read -p "Continue with deployment? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Deployment cancelled"
        exit 1
    fi
    
    # Run deployment steps
    check_prerequisites
    backup_current_deployment
    deploy_backend
    deploy_frontend
    setup_pm2
    configure_nginx
    run_health_checks
    display_summary
    
    print_success "Deployment completed successfully!"
}

# Run main function
main "$@"
