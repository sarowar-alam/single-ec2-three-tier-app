# Session 2: Visualization, Alerting & Production Monitoring

**Duration:** 90 minutes  
**Level:** Intermediate  
**Focus:** Install Grafana, create dashboards, configure alerting

---

## 🎯 Learning Objectives

By the end of this session, you will be able to:

1. Install and configure Grafana on AWS EC2
2. Connect Grafana to Prometheus data source
3. Create custom dashboards from scratch
4. Import and customize community dashboards
5. Build BMI application-specific monitoring panels
6. Configure alerting rules in Prometheus and Grafana
7. Set up notification channels
8. Apply production monitoring best practices

---

## 📋 Session Timeline

| Time | Topic | Type | Materials |
|------|-------|------|-----------|
| 0-10 min | Grafana Introduction | Lecture | Slides Part 1 |
| 10-30 min | Install Grafana | Hands-on | [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) |
| 30-40 min | Add Prometheus Datasource | Hands-on | Section 2 |
| 40-65 min | Create Dashboards | Hands-on | Section 3-4 |
| 65-80 min | Configure Alerting | Hands-on | Section 5 |
| 80-90 min | Best Practices & Q&A | Discussion | Slides Part 8 |

---

## 📚 Topics Covered

### **1. Introduction to Grafana (10 minutes)**

#### **What is Grafana?**
- Open-source analytics and visualization platform
- Founded in 2014 by Torkel Ödegaard
- Industry standard for metric visualization
- Used by over 1 million active installations

#### **Key Features:**
- ✅ Beautiful, flexible dashboards
- ✅ Support for 50+ data sources
- ✅ Alerting and notifications
- ✅ User management and teams
- ✅ Templating and variables
- ✅ Community dashboard marketplace

#### **Grafana Architecture:**
```
┌────────────────────────────────────────────────┐
│              Grafana Server                     │
│                                                  │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐ │
│  │Dashboard │───▶│  Query   │───▶│  Data    │ │
│  │  Engine  │    │  Engine  │    │  Source  │ │
│  └──────────┘    └──────────┘    └─────┬────┘ │
│                                         │      │
└─────────────────────────────────────────┼──────┘
                                          │
                                          ▼
                                   ┌──────────────┐
                                   │  Prometheus  │
                                   └──────────────┘
```

### **2. Install & Configure Grafana (20 minutes)**

Follow detailed steps in [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)

**Installation Methods:**
1. **APT Package** (Recommended - easier updates)
2. **Binary Download** (Similar to Prometheus)
3. **Docker** (For containerized deployment)

**We'll use:** APT Package method

### **3. Add Prometheus Data Source (10 minutes)**

**Steps:**
1. Access Grafana UI
2. Navigate to Data Sources
3. Add Prometheus
4. Configure connection
5. Test and save

### **4. Creating Dashboards (25 minutes)**

#### **Dashboard Components:**
- **Panels:** Individual visualizations
- **Rows:** Groups of panels
- **Variables:** Dynamic dashboard elements
- **Annotations:** Event markers

#### **Panel Types:**
- Time series (line graphs)
- Gauge (current value)
- Stat (single number)
- Bar gauge (horizontal bars)
- Table (tabular data)
- Heatmap (density visualization)

### **5. Three-Tier Application Dashboard (Included in Part 4)**

Build custom panels for:

**Frontend Metrics:**
- User sessions
- Page load times
- Client-side errors

**Backend Metrics:**
- Request rate
- Response times
- Error rates
- API endpoint performance

**Database Metrics:**
- Connection count
- Query performance
- Database size
- Transaction rate

### **6. Alerting Configuration (15 minutes)**

**Alert Types:**
1. **Prometheus Alerts:** Query-based, evaluated by Prometheus
2. **Grafana Alerts:** Dashboard panel-based

**Notification Channels:**
- Email
- Slack
- PagerDuty
- Webhook
- Discord
- Microsoft Teams

### **7. Production Best Practices (10 minutes)**

- Dashboard organization
- Naming conventions
- Alert fatigue prevention
- SLO/SLI monitoring
- Documentation
- Access control

---

## 🛠️ Required Tools

### **Installed During Session:**
- Grafana 10.0+

### **Already Installed:**
- Prometheus (from Session 1)
- Node Exporter (from Session 1)

---

## 📖 Prerequisites

### **Before Starting:**
- [ ] Completed Session 1
- [ ] Prometheus running and collecting metrics
- [ ] Node Exporter operational
- [ ] Security group allows port 3000 (Grafana)
- [ ] At least 500MB free disk space

### **Knowledge Prerequisites:**
- PromQL basics (from Session 1)
- Understanding of metrics and time-series data
- Basic dashboard concepts

---

## 🎯 Hands-On Activities

### **Activity 1: Install Grafana**
**Time:** 15 minutes  
**Goal:** Get Grafana running

1. Add Grafana APT repository
2. Install Grafana package
3. Start Grafana service
4. Access web UI at http://YOUR_EC2_IP:3000
5. Login (default: admin/admin)

### **Activity 2: Add Data Source**
**Time:** 5 minutes  
**Goal:** Connect to Prometheus

1. Navigate to Configuration → Data Sources
2. Add Prometheus
3. URL: http://localhost:9090
4. Test connection
5. Save & Test

### **Activity 3: Import Community Dashboard**
**Time:** 10 minutes  
**Goal:** Quick visualization with pre-built dashboard

1. Go to + → Import
2. Enter dashboard ID: 1860 (Node Exporter Full)
3. Select Prometheus data source
4. Import
5. Explore the dashboard

### **Activity 4: Create Custom Dashboard**
**Time:** 25 minutes  
**Goal:** Build BMI application dashboard

Create panels for:
1. System Overview (CPU, Memory, Disk)
2. Network Traffic
3. Application Health
4. Database Metrics
5. Custom BMI calculations

### **Activity 5: Configure Alerting**
**Time:** 15 minutes  
**Goal:** Set up alerts for critical metrics

1. Create alert rule: High CPU usage
2. Create alert rule: Low disk space
3. Configure notification channel
4. Test alert

---

## 📊 Dashboard Examples

### **System Monitoring Dashboard**
Panels to include:
- CPU Usage % (Gauge)
- Memory Usage % (Gauge)
- Disk Space Used % (Gauge)
- Network Traffic (Time Series)
- System Load (Time Series)
- Disk I/O (Time Series)

### **BMI Application Dashboard**
Panels to include:
- Total BMI Calculations (Stat)
- Calculations per Minute (Time Series)
- Average Response Time (Gauge)
- Error Rate % (Time Series)
- Active Users (Stat)
- Database Connection Pool (Gauge)

### **Database Dashboard**
Panels to include:
- Active Connections (Time Series)
- Queries per Second (Stat)
- Slow Queries (Table)
- Database Size (Gauge)
- Transaction Rate (Time Series)
- Cache Hit Ratio (Gauge)

---

## 📝 Key Concepts

### **Dashboard Variables**
Dynamic elements that make dashboards reusable:
```
$instance - Select which server to monitor
$interval - Time range for queries
$datasource - Switch between Prometheus instances
```

### **Panel Queries**
Each panel uses PromQL to fetch data:
```promql
# CPU Usage Panel
100 - (avg(rate(node_cpu_seconds_total{instance="$instance",mode="idle"}[5m])) * 100)
```

### **Alert Rules**
Condition-based notifications:
```yaml
alert: HighCPUUsage
expr: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
for: 5m
labels:
  severity: warning
annotations:
  summary: "High CPU usage detected"
```

---

## 📈 Expected Outcomes

### **After This Session:**

#### **You Can:**
- [ ] Install Grafana on Linux
- [ ] Connect Grafana to Prometheus
- [ ] Navigate Grafana UI
- [ ] Create custom dashboards
- [ ] Add various panel types
- [ ] Use dashboard variables
- [ ] Import community dashboards
- [ ] Configure alert rules
- [ ] Set up notification channels
- [ ] Apply visualization best practices

#### **You Have:**
- [ ] Grafana running on EC2
- [ ] At least 3 custom dashboards
- [ ] BMI application monitoring dashboard
- [ ] Alert rules configured
- [ ] Notification channel set up
- [ ] Production-ready monitoring stack

---

## 📝 Homework Assignment

**Due:** 1 week after session

See detailed assignment: [homework/assignment.md](homework/assignment.md)

**Tasks:**
1. Create 5 additional custom panels
2. Set up email alerting
3. Create team dashboard for stakeholders
4. Document your monitoring strategy
5. Export and share dashboard JSON

**Expected Time:** 90 minutes

---

## 🐛 Troubleshooting

### **Issue: Grafana Won't Start**
```bash
# Check logs
sudo journalctl -u grafana-server -f

# Verify service
sudo systemctl status grafana-server

# Check port
sudo netstat -tlnp | grep 3000
```

### **Issue: Can't Access Grafana UI**
```bash
# Check Grafana is running
sudo systemctl status grafana-server

# Check security group allows port 3000
# Verify firewall
sudo ufw status

# Test local access
curl http://localhost:3000
```

### **Issue: Can't Connect to Prometheus**
```bash
# Test Prometheus from Grafana server
curl http://localhost:9090/api/v1/query?query=up

# Check Prometheus is running
sudo systemctl status prometheus

# Verify URL in datasource settings
# Should be: http://localhost:9090
```

### **Issue: No Data in Panels**
```bash
# Verify Prometheus has data
curl "http://localhost:9090/api/v1/query?query=up"

# Check time range in dashboard
# Check PromQL query syntax
# Verify data source is selected
```

---

## 📚 Additional Resources

### **Grafana Documentation:**
- [Getting Started](https://grafana.com/docs/grafana/latest/getting-started/)
- [Dashboard Guide](https://grafana.com/docs/grafana/latest/dashboards/)
- [Alerting](https://grafana.com/docs/grafana/latest/alerting/)

### **Community Dashboards:**
- [Grafana Dashboard Marketplace](https://grafana.com/grafana/dashboards/)
- [Node Exporter Full (1860)](https://grafana.com/grafana/dashboards/1860)
- [Prometheus Stats (2)](https://grafana.com/grafana/dashboards/2)

### **Tutorials:**
- [Building Your First Dashboard](https://grafana.com/docs/grafana/latest/getting-started/build-first-dashboard/)
- [Dashboard Best Practices](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/best-practices/)

---

## 🎓 For Instructors

### **Preparation:**
- [ ] Test Grafana installation
- [ ] Prepare dashboard templates
- [ ] Have example alerts ready
- [ ] Test notification channels
- [ ] Prepare screenshots/recordings

### **During Session:**
- [ ] Demonstrate dashboard creation live
- [ ] Show multiple visualization types
- [ ] Explain query editor
- [ ] Demo alert triggering
- [ ] Share dashboard JSON files

### **After Session:**
- [ ] Share all dashboard JSON files
- [ ] Post video recording
- [ ] Answer follow-up questions
- [ ] Share additional resources

---

## ✅ Session Completion Checklist

- [ ] Grafana installed and running
- [ ] Prometheus datasource configured
- [ ] Imported at least 1 community dashboard
- [ ] Created custom BMI app dashboard
- [ ] At least 5 panels created
- [ ] Alert rules configured
- [ ] Notification channel set up
- [ ] Tested alert triggering
- [ ] Exported dashboard JSON
- [ ] Homework assignment understood

---

**You've Completed the Monitoring Course! 🎉**

You now have a production-grade monitoring stack with:
- ✅ Metrics collection (Prometheus)
- ✅ System monitoring (Node Exporter)
- ✅ Visualization (Grafana)
- ✅ Alerting (Prometheus + Grafana)
- ✅ Application monitoring (BMI App)

**Next Steps:** Continue learning about advanced topics like SLO monitoring, distributed tracing, and log aggregation!

**Detailed Guide:** [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)
