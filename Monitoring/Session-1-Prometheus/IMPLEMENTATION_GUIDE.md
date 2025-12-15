# Session 1: Prometheus - Implementation Guide

**Duration:** 90 minutes  
**Level:** Beginner to Intermediate  
**Prerequisites:** AWS EC2 with BMI app deployed, SSH access

---

## 📋 Table of Contents

1. [Pre-Session Setup](#pre-session-setup)
2. [Part 1: Install Prometheus](#part-1-install-prometheus-25-min)
3. [Part 2: Install Node Exporter](#part-2-install-node-exporter-15-min)
4. [Part 3: PromQL Queries](#part-3-promql-queries-30-min)
5. [Part 4: Configure Scraping](#part-4-configure-scraping-15-min)
6. [Troubleshooting](#troubleshooting)
7. [Validation Checklist](#validation-checklist)

---

## 🚀 Pre-Session Setup

### Step 1: Verify Prerequisites

```bash
# SSH to your EC2 instance
ssh -i /path/to/your-key.pem ubuntu@YOUR_EC2_IP

# Check system resources
free -h
df -h
uname -a

# Should show:
# - At least 1GB free memory
# - At least 2GB free disk space
# - Ubuntu 22.04 or similar
```

### Step 2: Update Security Group

1. Go to AWS Console → EC2 → Security Groups
2. Find your EC2's security group
3. Add inbound rules:
   - **Type:** Custom TCP
   - **Port:** 9090
   - **Source:** Your IP or 0.0.0.0/0 (for learning)
   - **Description:** Prometheus
   
4. Add another rule:
   - **Port:** 9100
   - **Description:** Node Exporter

### Step 3: Update System

```bash
# Update package lists
sudo apt update

# Install required packages
sudo apt install -y wget curl tar

# Verify installations
wget --version
curl --version
```

---

## 🔧 Part 1: Install Prometheus (25 min)

### Step 1: Create Prometheus User

```bash
# Create system user (no login shell)
sudo useradd --no-create-home --shell /bin/false prometheus

# Verify user created
id prometheus
# Output: uid=... gid=... groups=...
```

### Step 2: Create Directories

```bash
# Create directories
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus

# Set ownership
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Verify permissions
ls -ld /etc/prometheus /var/lib/prometheus
```

### Step 3: Download Prometheus

```bash
# Check latest version at: https://prometheus.io/download/
# Using version 2.45.0 (or latest stable)

cd /tmp

# Download Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz

# Verify download
ls -lh prometheus-2.45.0.linux-amd64.tar.gz

# Extract
tar -xzf prometheus-2.45.0.linux-amd64.tar.gz

# Navigate to extracted directory
cd prometheus-2.45.0.linux-amd64

# List contents
ls -la
```

### Step 4: Install Binaries

```bash
# Copy binaries to /usr/local/bin
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/

# Set ownership
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

# Verify installation
prometheus --version
promtool --version

# Expected output:
# prometheus, version 2.45.0
# promtool, version 2.45.0
```

### Step 5: Copy Console Files

```bash
# Still in /tmp/prometheus-2.45.0.linux-amd64

# Copy console libraries
sudo cp -r consoles /etc/prometheus
sudo cp -r console_libraries /etc/prometheus

# Set ownership
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

# Verify
ls -l /etc/prometheus/
```

### Step 6: Create Prometheus Configuration

```bash
# Create configuration file
sudo nano /etc/prometheus/prometheus.yml
```

Paste this configuration:

```yaml
# Prometheus Configuration File

global:
  scrape_interval: 15s          # How often to scrape targets
  evaluation_interval: 15s      # How often to evaluate rules
  external_labels:
    cluster: 'bmi-monitoring'
    environment: 'production'

# Alertmanager configuration (for later)
alerting:
  alertmanagers:
    - static_configs:
        - targets: []
          # - 'localhost:9093'

# Load rules once and periodically evaluate them
rule_files:
  # - "alerts.yml"
  # - "recording_rules.yml"

# Scrape configurations
scrape_configs:
  # Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
        labels:
          service: 'prometheus'
          env: 'prod'

  # Node Exporter (will install next)
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
        labels:
          service: 'node-exporter'
          hostname: 'bmi-server'

  # BMI Backend API
  - job_name: 'bmi-backend'
    static_configs:
      - targets: ['localhost:3000']
        labels:
          service: 'bmi-backend'
          tier: 'backend'
    metrics_path: '/metrics'  # If you expose metrics endpoint

  # PostgreSQL (future - with postgres_exporter)
  # - job_name: 'postgresql'
  #   static_configs:
  #     - targets: ['localhost:9187']
```

Save and exit (Ctrl+X, Y, Enter)

### Step 7: Validate Configuration

```bash
# Check configuration syntax
sudo promtool check config /etc/prometheus/prometheus.yml

# Expected output:
# Checking /etc/prometheus/prometheus.yml
# SUCCESS: 0 rule files found
```

### Step 8: Set Ownership

```bash
# Set ownership of config file
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Verify
ls -l /etc/prometheus/prometheus.yml
```

### Step 9: Create SystemD Service

```bash
# Create service file
sudo nano /etc/systemd/system/prometheus.service
```

Paste this content:

```ini
[Unit]
Description=Prometheus Monitoring System
Documentation=https://prometheus.io/docs/introduction/overview/
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle \
  --storage.tsdb.retention.time=15d

SyslogIdentifier=prometheus
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Save and exit

### Step 10: Start Prometheus

```bash
# Reload SystemD daemon
sudo systemctl daemon-reload

# Enable Prometheus to start on boot
sudo systemctl enable prometheus

# Start Prometheus
sudo systemctl start prometheus

# Check status
sudo systemctl status prometheus

# Should show: Active: active (running)
```

### Step 11: Verify Prometheus is Running

```bash
# Check if Prometheus is listening on port 9090
sudo netstat -tlnp | grep 9090

# Test endpoint locally
curl http://localhost:9090/metrics | head -20

# View logs
sudo journalctl -u prometheus -f
# Press Ctrl+C to exit
```

### Step 12: Access Prometheus Web UI

Open in your browser:
```
http://YOUR_EC2_PUBLIC_IP:9090
```

You should see the Prometheus web interface.

**Test queries:**
1. Click "Graph"
2. Enter: `up`
3. Click "Execute"
4. You should see `up{instance="localhost:9090",job="prometheus"} 1`

---

## 📊 Part 2: Install Node Exporter (15 min)

### Step 1: Download Node Exporter

```bash
cd /tmp

# Download Node Exporter (check latest: https://prometheus.io/download/)
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz

# Extract
tar -xzf node_exporter-1.6.1.linux-amd64.tar.gz

cd node_exporter-1.6.1.linux-amd64

# Check contents
ls -l
```

### Step 2: Install Node Exporter Binary

```bash
# Copy to /usr/local/bin
sudo cp node_exporter /usr/local/bin/

# Create user
sudo useradd --no-create-home --shell /bin/false node_exporter

# Set ownership
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Verify
node_exporter --version
```

### Step 3: Create SystemD Service

```bash
# Create service file
sudo nano /etc/systemd/system/node_exporter.service
```

Paste:

```ini
[Unit]
Description=Node Exporter
Documentation=https://github.com/prometheus/node_exporter
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=node_exporter
Group=node_exporter
ExecStart=/usr/local/bin/node_exporter \
  --collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/) \
  --collector.netclass.ignored-devices=^(veth.*|docker.*|br-.*)$$ \
  --collector.netdev.device-exclude=^(veth.*|docker.*|br-.*)$$

SyslogIdentifier=node_exporter
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Save and exit

### Step 4: Start Node Exporter

```bash
# Reload daemon
sudo systemctl daemon-reload

# Enable and start
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Check status
sudo systemctl status node_exporter
```

### Step 5: Verify Node Exporter

```bash
# Check port 9100
sudo netstat -tlnp | grep 9100

# Test metrics endpoint
curl http://localhost:9100/metrics | head -30

# Should see many metrics like:
# node_cpu_seconds_total
# node_memory_MemTotal_bytes
# node_filesystem_size_bytes
```

### Step 6: Verify in Prometheus

1. Go to: `http://YOUR_EC2_IP:9090/targets`
2. You should see two targets:
   - `prometheus` (UP)
   - `node_exporter` (UP)

3. Both should show status "UP" in green

If showing "DOWN", wait 15 seconds (scrape interval) and refresh.

---

## 📈 Part 3: PromQL Queries (30 min)

### Exercise 1: Basic Queries

Open Prometheus UI: `http://YOUR_EC2_IP:9090/graph`

**Query 1: Check All Targets Are Up**
```promql
up
```
Expected: Shows 1 for all targets

**Query 2: Total Memory**
```promql
node_memory_MemTotal_bytes
```
Expected: Shows your EC2's total memory in bytes

**Query 3: Available Memory**
```promql
node_memory_MemAvailable_bytes
```

**Query 4: CPU Cores**
```promql
count(node_cpu_seconds_total{mode="idle"})
```

**Query 5: Disk Space**
```promql
node_filesystem_size_bytes{mountpoint="/"}
```

### Exercise 2: Memory Usage Percentage

**Query: Memory Usage %**
```promql
100 - (
  node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100
)
```

Switch to "Graph" tab to see visualization over time.

### Exercise 3: CPU Usage

**Query: CPU Usage % (5min average)**
```promql
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

**Query: CPU Usage by Core**
```promql
100 - (rate(node_cpu_seconds_total{mode="idle"}[5m]) * 100)
```

### Exercise 4: Disk I/O

**Query: Disk Read Rate (bytes/sec)**
```promql
rate(node_disk_read_bytes_total[5m])
```

**Query: Disk Write Rate (bytes/sec)**
```promql
rate(node_disk_written_bytes_total[5m])
```

### Exercise 5: Network Traffic

**Query: Network Receive Rate (bytes/sec)**
```promql
rate(node_network_receive_bytes_total{device!~"lo|docker.*|veth.*"}[5m])
```

**Query: Network Transmit Rate (bytes/sec)**
```promql
rate(node_network_transmit_bytes_total{device!~"lo|docker.*|veth.*"}[5m])
```

### Exercise 6: Aggregations

**Query: Total Network Traffic**
```promql
sum(rate(node_network_receive_bytes_total[5m])) + 
sum(rate(node_network_transmit_bytes_total[5m]))
```

**Query: Average CPU Across All Cores**
```promql
avg(rate(node_cpu_seconds_total{mode!="idle"}[5m]))
```

### Exercise 7: Advanced Queries

**Query: Disk Space Usage %**
```promql
100 - (
  node_filesystem_avail_bytes{mountpoint="/"} / 
  node_filesystem_size_bytes{mountpoint="/"} * 100
)
```

**Query: Load Average (1min)**
```promql
node_load1
```

**Query: Number of Running Processes**
```promql
node_procs_running
```

**Query: System Uptime (in days)**
```promql
(time() - node_boot_time_seconds) / 86400
```

### Practice: Create Your Own Queries

Try to write queries for:
1. Available disk space on root partition
2. Number of network errors
3. Context switches per second
4. File descriptor usage

---

## ⚙️ Part 4: Configure Scraping (15 min)

### Step 1: Add PostgreSQL Exporter (Optional)

```bash
# Install postgres_exporter
wget https://github.com/prometheus-community/postgres_exporter/releases/download/v0.13.2/postgres_exporter-0.13.2.linux-amd64.tar.gz

tar -xzf postgres_exporter-0.13.2.linux-amd64.tar.gz

sudo cp postgres_exporter-0.13.2.linux-amd64/postgres_exporter /usr/local/bin/

# Create .pgpass file for authentication
echo "localhost:5432:bmi_tracker:postgres:YOUR_DB_PASSWORD" > ~/.pgpass
chmod 600 ~/.pgpass
```

### Step 2: Update Prometheus Configuration

```bash
# Edit config
sudo nano /etc/prometheus/prometheus.yml
```

Add to `scrape_configs`:

```yaml
  # PostgreSQL Database
  - job_name: 'postgresql'
    static_configs:
      - targets: ['localhost:9187']
        labels:
          service: 'postgresql'
          database: 'bmi_tracker'
```

### Step 3: Reload Prometheus Configuration

```bash
# Option 1: Using API (if --web.enable-lifecycle is set)
curl -X POST http://localhost:9090/-/reload

# Option 2: Restart service
sudo systemctl restart prometheus

# Verify no errors
sudo journalctl -u prometheus -n 50
```

### Step 4: Add Custom Labels

Edit prometheus.yml to add custom labels:

```yaml
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
        labels:
          service: 'node-exporter'
          hostname: 'bmi-server'
          region: 'us-east-1'  # Your AWS region
          instance_type: 't2.medium'  # Your EC2 type
          env: 'production'
```

Reload configuration after changes.

### Step 5: Verify All Targets

Visit: `http://YOUR_EC2_IP:9090/targets`

Should see all configured targets with status.

---

## 🐛 Troubleshooting

### Issue 1: Prometheus Won't Start

**Check logs:**
```bash
sudo journalctl -u prometheus -n 100 --no-pager
```

**Common causes:**
```bash
# Config syntax error
sudo promtool check config /etc/prometheus/prometheus.yml

# Port already in use
sudo netstat -tlnp | grep 9090
sudo lsof -i :9090

# Permission issues
ls -la /var/lib/prometheus/
sudo chown -R prometheus:prometheus /var/lib/prometheus/
```

### Issue 2: Can't Access Web UI

**Check firewall:**
```bash
# Check if Prometheus is listening
sudo netstat -tlnp | grep 9090

# Check local access
curl http://localhost:9090

# Check AWS Security Group allows port 9090
# Check UFW if enabled
sudo ufw status
```

### Issue 3: Target Shows as DOWN

**Check target is running:**
```bash
# For Node Exporter
sudo systemctl status node_exporter
curl http://localhost:9100/metrics

# Check Prometheus can reach it
curl http://localhost:9100/metrics | head
```

**Check scrape configuration:**
```bash
# Verify target in config
cat /etc/prometheus/prometheus.yml | grep -A 5 node_exporter

# Check Prometheus logs
sudo journalctl -u prometheus -f
```

### Issue 4: No Data in Graphs

**Verify metrics exist:**
```bash
# Check metrics endpoint
curl http://localhost:9100/metrics | grep "node_memory"

# Query in Prometheus
# Go to: http://YOUR_EC2_IP:9090/graph
# Enter: node_memory_MemTotal_bytes
# Click Execute
```

**Check time range:**
- In Prometheus UI, adjust time range
- Default shows last 1 hour
- For new installation, use last 5 minutes

### Issue 5: High Disk Usage

```bash
# Check Prometheus data size
du -sh /var/lib/prometheus/data

# Reduce retention (edit prometheus.service)
sudo nano /etc/systemd/system/prometheus.service

# Change to:
--storage.tsdb.retention.time=7d

# Restart
sudo systemctl daemon-reload
sudo systemctl restart prometheus
```

---

## ✅ Validation Checklist

### After Part 1 (Prometheus):
- [ ] Prometheus binary installed
- [ ] Configuration file created
- [ ] SystemD service running
- [ ] Web UI accessible
- [ ] Can query `up` metric

### After Part 2 (Node Exporter):
- [ ] Node Exporter installed
- [ ] Service running
- [ ] Metrics accessible at :9100/metrics
- [ ] Prometheus scraping successfully
- [ ] Target shows "UP" in Prometheus UI

### After Part 3 (PromQL):
- [ ] Can query memory metrics
- [ ] Can query CPU metrics
- [ ] Can calculate percentages
- [ ] Can use rate() function
- [ ] Can aggregate with sum/avg
- [ ] Understand instant vs range vectors

### After Part 4 (Configuration):
- [ ] Multiple targets configured
- [ ] Custom labels added
- [ ] Configuration reloaded successfully
- [ ] All targets showing UP
- [ ] No errors in logs

### Overall Session 1 Completion:
- [ ] Prometheus monitoring stack operational
- [ ] System metrics being collected
- [ ] Comfortable with PromQL basics
- [ ] Can write useful queries
- [ ] Ready for Grafana (Session 2)

---

## 📚 Next Steps

**Before Session 2:**
1. Complete homework assignment
2. Explore more PromQL queries
3. Monitor your system for 24 hours
4. Note any interesting patterns
5. Prepare questions for Session 2

**Additional Practice:**
- Try different PromQL functions
- Experiment with label filters
- Create recording rules
- Read about alerting rules

---

## 🔗 Quick Reference

### **Service Commands:**
```bash
# Prometheus
sudo systemctl status prometheus
sudo systemctl restart prometheus
sudo journalctl -u prometheus -f

# Node Exporter
sudo systemctl status node_exporter
sudo systemctl restart node_exporter
sudo journalctl -u node_exporter -f
```

### **Important Paths:**
```bash
/etc/prometheus/prometheus.yml          # Config
/var/lib/prometheus/data/               # Data storage
/usr/local/bin/prometheus               # Binary
/usr/local/bin/promtool                 # Config checker
```

### **Useful URLs:**
```
http://YOUR_EC2_IP:9090                 # Prometheus UI
http://YOUR_EC2_IP:9090/targets         # Targets status
http://YOUR_EC2_IP:9090/config          # Current config
http://YOUR_EC2_IP:9090/metrics         # Prometheus metrics
http://YOUR_EC2_IP:9100/metrics         # Node Exporter metrics
```

---

**Session 1 Complete! 🎉**

You now have a working Prometheus monitoring system collecting system metrics!

**Next:** [Session 2: Grafana Visualization & Alerting](../Session-2-Grafana/README.md)
