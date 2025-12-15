# Session 1: Monitoring Fundamentals & Prometheus

**Duration:** 90 minutes  
**Level:** Beginner to Intermediate  
**Focus:** Understand monitoring, install Prometheus, master PromQL

---

## 🎯 Learning Objectives

By the end of this session, you will be able to:

1. Explain why monitoring is critical for production systems
2. Understand Prometheus architecture and data model
3. Install and configure Prometheus on AWS EC2
4. Set up Node Exporter for system metrics collection
5. Write PromQL queries to analyze metrics
6. Configure Prometheus to scrape multiple targets
7. Use Prometheus web UI for data exploration

---

## 📋 Session Timeline

| Time | Topic | Type | Materials |
|------|-------|------|-----------|
| 0-15 min | Why Monitoring Matters | Lecture | Slides Part 1 |
| 15-25 min | Prometheus Architecture | Lecture | Slides Part 2 |
| 25-50 min | Install Prometheus & Node Exporter | Hands-on | [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) |
| 50-70 min | PromQL Queries | Hands-on | [exercises/](exercises/) |
| 70-85 min | Configure Scraping | Hands-on | [configs/prometheus.yml](configs/prometheus.yml) |
| 85-90 min | Q&A and Homework | Discussion | [homework/assignment.md](homework/assignment.md) |

---

## 📚 Topics Covered

### **1. Why Monitoring Matters (15 minutes)**

#### **The Four Golden Signals:**
- **Latency:** How long requests take to complete
- **Traffic:** How many requests are being served
- **Errors:** Rate of failed requests
- **Saturation:** How "full" your service is

#### **Real-World Scenarios:**
- 🔥 **Scenario 1:** Server runs out of disk space → Application crashes → Users can't access site
- 🔥 **Scenario 2:** Memory leak → Slow response times → Poor user experience
- 🔥 **Scenario 3:** High CPU usage → Service degradation → Customer complaints

#### **Monitoring vs Logging vs Tracing:**
| Type | Purpose | Example |
|------|---------|---------|
| **Metrics** | What's happening over time | CPU at 80% |
| **Logs** | Individual events | "User login failed" |
| **Traces** | Request flow through system | API call → DB query → Response |

### **2. Introduction to Prometheus (10 minutes)**

#### **What is Prometheus?**
- Open-source monitoring and alerting toolkit
- Originally built at SoundCloud (2012)
- Now part of Cloud Native Computing Foundation (CNCF)
- Industry standard for cloud-native monitoring

#### **Key Features:**
- ✅ Time-series database
- ✅ Pull-based metrics collection
- ✅ Powerful query language (PromQL)
- ✅ Service discovery
- ✅ Built-in alerting
- ✅ No external dependencies

#### **Prometheus Architecture:**
```
┌─────────────────────────────────────────────────────┐
│                  Prometheus Server                   │
│                                                       │
│  ┌──────────┐    ┌──────────┐    ┌──────────────┐ │
│  │ Retrieval├───▶│  TSDB    ├───▶│   PromQL     │ │
│  │  (Pull)  │    │ Storage  │    │    Engine    │ │
│  └────┬─────┘    └──────────┘    └──────┬───────┘ │
│       │                                  │          │
└───────┼──────────────────────────────────┼──────────┘
        │                                  │
        ▼                                  ▼
┌───────────────┐                 ┌────────────────┐
│   Exporters   │                 │   Grafana /    │
│               │                 │   Web UI       │
│ - Node Exp    │                 └────────────────┘
│ - App Metrics │
└───────────────┘
```

### **3. Hands-On: Install Prometheus (25 minutes)**

Follow the detailed [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)

**Installation Steps:**
1. Download Prometheus binary
2. Create system user
3. Configure Prometheus
4. Set up SystemD service
5. Verify installation
6. Access web UI

### **4. Node Exporter Deep Dive (Included in Part 3)**

**What is Node Exporter?**
- Exposes hardware and OS metrics
- Runs as a daemon on each monitored host
- Exports 100+ metrics by default

**Key Metrics Exported:**
- CPU usage (`node_cpu_seconds_total`)
- Memory (`node_memory_*`)
- Disk I/O (`node_disk_*`)
- Network (`node_network_*`)
- Filesystem (`node_filesystem_*`)

### **5. PromQL (Prometheus Query Language) (20 minutes)**

**Basic Query Structure:**
```promql
# Instant vector - current value
node_memory_MemAvailable_bytes

# Range vector - values over time
node_memory_MemAvailable_bytes[5m]

# With label filtering
node_memory_MemAvailable_bytes{instance="localhost:9100"}
```

**Common Functions:**
```promql
# Rate of increase over 5 minutes
rate(node_network_receive_bytes_total[5m])

# Average over time
avg_over_time(node_cpu_seconds_total[1h])

# Current CPU usage percentage
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

**Hands-On Exercises:**
- [Exercise 1: Basic Queries](exercises/01-basic-queries.md)
- [Exercise 2: Advanced Queries](exercises/02-advanced-queries.md)
- [Exercise 3: Aggregations](exercises/03-aggregations.md)

### **6. Configure Prometheus Scraping (15 minutes)**

**Scrape Configuration:**
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  # Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  # Node Exporter
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
  
  # BMI Application (future)
  - job_name: 'bmi-app'
    static_configs:
      - targets: ['localhost:3000']
```

---

## 🛠️ Required Tools

### **Installed During Session:**
- Prometheus 2.45+
- Node Exporter 1.6+

### **Pre-installed on EC2:**
- Ubuntu 22.04 LTS
- SystemD
- curl/wget
- tar

---

## 📖 Prerequisites

### **Before Starting:**
- [ ] BMI app running on EC2
- [ ] SSH access to EC2
- [ ] Security group allows:
  - Port 9090 (Prometheus)
  - Port 9100 (Node Exporter)
- [ ] At least 1GB free disk space
- [ ] Sudo privileges

### **Knowledge Prerequisites:**
- Basic Linux commands
- Understanding of ports and services
- Text editor familiarity (nano/vim)

---

## 🎯 Hands-On Activities

### **Activity 1: Install Prometheus**
**Time:** 15 minutes  
**Goal:** Get Prometheus running

1. Download and extract Prometheus
2. Create configuration file
3. Start Prometheus
4. Access web UI at http://YOUR_EC2_IP:9090

### **Activity 2: Install Node Exporter**
**Time:** 10 minutes  
**Goal:** Collect system metrics

1. Download Node Exporter
2. Configure as SystemD service
3. Verify metrics at http://YOUR_EC2_IP:9100/metrics

### **Activity 3: Write PromQL Queries**
**Time:** 20 minutes  
**Goal:** Query and analyze metrics

Complete exercises in the [exercises/](exercises/) folder:
- Basic queries
- Filtering and aggregations
- Rate calculations
- Math operations

### **Activity 4: Configure Multi-Target Scraping**
**Time:** 10 minutes  
**Goal:** Monitor multiple services

1. Edit prometheus.yml
2. Add scrape targets
3. Reload configuration
4. Verify targets in UI

---

## 🔍 Key Concepts

### **Time-Series Data**
```
Metric: node_cpu_seconds_total{cpu="0",mode="idle"}
Timestamp: 1702646400
Value: 12345.67
```

### **Labels**
- Key-value pairs that identify metric dimensions
- Example: `{instance="localhost:9100", job="node"}`
- Used for filtering and aggregation

### **Metric Types**
1. **Counter:** Only increases (e.g., requests_total)
2. **Gauge:** Can go up/down (e.g., memory_usage)
3. **Histogram:** Observations in buckets (e.g., response_time)
4. **Summary:** Similar to histogram with percentiles

### **Scrape Interval**
- How often Prometheus collects metrics
- Default: 15 seconds
- Trade-off: Precision vs storage

---

## 📊 Expected Outcomes

### **After This Session:**

#### **You Can:**
- [ ] Explain the importance of monitoring
- [ ] Install Prometheus from scratch
- [ ] Configure Node Exporter
- [ ] Access Prometheus web UI
- [ ] Write basic PromQL queries
- [ ] Understand metric types and labels
- [ ] Configure scrape targets

#### **You Have:**
- [ ] Prometheus running on EC2 (port 9090)
- [ ] Node Exporter collecting system metrics
- [ ] prometheus.yml configuration file
- [ ] Experience with PromQL queries
- [ ] Understanding of time-series data

---

## 📝 Homework Assignment

**Due:** Before Session 2

See detailed assignment: [homework/assignment.md](homework/assignment.md)

**Tasks:**
1. Write 10 PromQL queries for different scenarios
2. Create recording rules for common queries
3. Monitor your BMI app's resource usage
4. Document 3 interesting metrics discoveries
5. Research alerting rules (prep for Session 2)

**Expected Time:** 60 minutes

---

## 🐛 Troubleshooting

### **Issue: Prometheus Won't Start**
```bash
# Check logs
sudo journalctl -u prometheus -f

# Verify configuration
promtool check config /etc/prometheus/prometheus.yml

# Check port availability
sudo netstat -tlnp | grep 9090
```

### **Issue: Can't Access Web UI**
```bash
# Check if Prometheus is running
sudo systemctl status prometheus

# Check security group allows port 9090
# AWS Console → EC2 → Security Groups

# Check firewall
sudo ufw status
```

### **Issue: Node Exporter Metrics Not Showing**
```bash
# Verify Node Exporter is running
sudo systemctl status node_exporter

# Test endpoint
curl http://localhost:9100/metrics

# Check Prometheus targets
# Go to: http://YOUR_EC2_IP:9090/targets
```

### **Issue: High Memory Usage**
```bash
# Check Prometheus storage
du -sh /var/lib/prometheus/data

# Reduce retention time in prometheus.yml
--storage.tsdb.retention.time=15d

# Restart Prometheus
sudo systemctl restart prometheus
```

---

## 📚 Additional Resources

### **Prometheus Documentation:**
- [Getting Started](https://prometheus.io/docs/prometheus/latest/getting_started/)
- [Configuration](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)
- [PromQL Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)

### **Tutorials:**
- [PromQL Tutorial](https://prometheus.io/docs/prometheus/latest/querying/examples/)
- [Node Exporter Guide](https://github.com/prometheus/node_exporter)

### **Community:**
- [Prometheus Slack](https://prometheus.io/community/)
- [GitHub Discussions](https://github.com/prometheus/prometheus/discussions)

---

## 🎓 For Instructors

### **Preparation:**
- [ ] Test installation scripts on demo EC2
- [ ] Prepare backup slides with screenshots
- [ ] Have prometheus.yml template ready
- [ ] Test all PromQL examples
- [ ] Prepare troubleshooting cheat sheet

### **During Session:**
- [ ] Share screen showing installations
- [ ] Demonstrate queries in real-time
- [ ] Encourage students to follow along
- [ ] Reserve time for Q&A
- [ ] Share homework assignment

### **After Session:**
- [ ] Share recording (if applicable)
- [ ] Post common questions/answers
- [ ] Verify all students have Prometheus running
- [ ] Remind about homework deadline

---

## ✅ Session Completion Checklist

- [ ] Understand why monitoring is critical
- [ ] Prometheus installed and running
- [ ] Node Exporter collecting metrics
- [ ] Can access Prometheus web UI
- [ ] Wrote at least 5 PromQL queries
- [ ] Configured multiple scrape targets
- [ ] Homework assignment downloaded
- [ ] Ready for Session 2 (Grafana)

---

**Next:** [Session 2: Visualization, Alerting & Production Monitoring](../Session-2-Grafana/README.md)

**Detailed Guide:** [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)
