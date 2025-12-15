# Prometheus & Grafana Monitoring Course

**Complete Hands-On Training for Application Monitoring & Alerting**

![Prometheus](https://img.shields.io/badge/Prometheus-Enabled-orange?logo=prometheus)
![Grafana](https://img.shields.io/badge/Grafana-Enabled-blue?logo=grafana)
![Duration](https://img.shields.io/badge/Duration-180%20minutes-green)
![Level](https://img.shields.io/badge/Level-Beginner%20to%20Intermediate-yellow)

---

## 📚 Course Overview

This comprehensive 2-session course teaches you how to implement production-grade monitoring for your three-tier BMI Health Tracker application using Prometheus and Grafana. You'll learn to collect metrics, create dashboards, and set up alerting for proactive incident response.

### **What You'll Build:**
A complete monitoring solution that:
- ✅ Collects system metrics (CPU, memory, disk, network)
- ✅ Monitors application performance (response times, errors)
- ✅ Visualizes metrics in real-time dashboards
- ✅ Alerts on critical issues before users notice
- ✅ Tracks database performance and connections
- ✅ Provides historical data analysis

---

## 🎯 Learning Objectives

### **Session 1: Monitoring Fundamentals & Prometheus (90 minutes)**
- Understand why monitoring is critical in production
- Learn Prometheus architecture and components
- Install and configure Prometheus on AWS EC2
- Set up Node Exporter for system metrics
- Master PromQL (Prometheus Query Language)
- Configure service discovery and scraping
- Query and analyze metrics data

### **Session 2: Visualization, Alerting & Production Monitoring (90 minutes)**
- Install and configure Grafana
- Connect Grafana to Prometheus data source
- Create custom dashboards from scratch
- Import and customize community dashboards
- Build BMI application-specific monitoring panels
- Configure alerting rules and notifications
- Implement production best practices

---

## 🎓 Who This Course Is For

- ✅ **DevOps Students** learning monitoring and observability
- ✅ **Developers** wanting to monitor their applications
- ✅ **System Administrators** implementing production monitoring
- ✅ **Students** with BMI Health Tracker already deployed
- ✅ **Anyone** wanting to learn Prometheus and Grafana

---

## 📋 Prerequisites

### **Required:**
- BMI Health Tracker app deployed on AWS EC2
- CI/CD pipeline configured (from GitHub Actions course)
- SSH access to EC2 instance
- Basic Linux command line knowledge
- Understanding of web application architecture

### **Helpful But Not Required:**
- Docker knowledge
- Basic understanding of metrics and monitoring
- SQL query experience (helps with PromQL)

---

## 📁 Course Structure

```
Monitoring/
├── README.md                              # ← YOU ARE HERE
├── AGENT.md                               # Master tracking document
│
├── Session-1-Prometheus/                  # Session 1 (90 mins)
│   ├── README.md                          # Lesson plan
│   ├── IMPLEMENTATION_GUIDE.md            # Step-by-step guide
│   ├── configs/
│   │   ├── prometheus.yml                 # Prometheus configuration
│   │   └── node-exporter.service          # SystemD service file
│   ├── scripts/
│   │   ├── install-prometheus.sh          # Installation script
│   │   └── install-node-exporter.sh       # Node Exporter setup
│   ├── exercises/
│   │   ├── 01-basic-queries.md            # PromQL basics
│   │   ├── 02-advanced-queries.md         # Advanced PromQL
│   │   └── 03-aggregations.md             # Aggregations & functions
│   └── homework/
│       └── assignment.md                  # Take-home exercises
│
└── Session-2-Grafana/                     # Session 2 (90 mins)
    ├── README.md                          # Lesson plan
    ├── IMPLEMENTATION_GUIDE.md            # Step-by-step guide
    ├── configs/
    │   ├── grafana.ini                    # Grafana configuration
    │   └── datasource.yml                 # Prometheus datasource
    ├── dashboards/
    │   ├── node-exporter-dashboard.json   # System metrics dashboard
    │   ├── bmi-app-dashboard.json         # Application dashboard
    │   └── postgres-dashboard.json        # Database dashboard
    ├── alerts/
    │   ├── prometheus-rules.yml           # Alert rules
    │   └── grafana-alerts.json            # Grafana alerting
    ├── scripts/
    │   ├── install-grafana.sh             # Installation script
    │   └── setup-monitoring.sh            # Complete setup
    └── homework/
        └── assignment.md                  # Enhancement tasks

```

---

## 🚀 Quick Start

### **For Students:**

1. **Verify Prerequisites:**
   ```bash
   # Check BMI app is running
   curl http://YOUR_EC2_IP
   
   # Verify SSH access
   ssh -i your-key.pem ubuntu@YOUR_EC2_IP
   
   # Check available ports (9090 for Prometheus, 3000 for Grafana)
   sudo netstat -tlnp
   ```

2. **Start with Session 1:**
   - Read [Session-1-Prometheus/README.md](Session-1-Prometheus/README.md)
   - Follow [Session-1-Prometheus/IMPLEMENTATION_GUIDE.md](Session-1-Prometheus/IMPLEMENTATION_GUIDE.md)
   - Complete all exercises
   - Finish homework assignment

3. **Continue to Session 2:**
   - Read [Session-2-Grafana/README.md](Session-2-Grafana/README.md)
   - Follow [Session-2-Grafana/IMPLEMENTATION_GUIDE.md](Session-2-Grafana/IMPLEMENTATION_GUIDE.md)
   - Build custom dashboards
   - Configure alerting

### **For Instructors:**

1. **Review master file:** [AGENT.md](AGENT.md)
2. **Prepare for Session 1:** [Session-1-Prometheus/](Session-1-Prometheus/)
3. **Prepare for Session 2:** [Session-2-Grafana/](Session-2-Grafana/)
4. **Test all installations on demo EC2 before teaching**
5. **Have backup screenshots in case of connectivity issues**

---

## 📊 What You'll Monitor

### **System Metrics (via Node Exporter):**
- CPU usage and load average
- Memory utilization
- Disk I/O and space
- Network traffic
- System uptime

### **Application Metrics (BMI Health Tracker):**
- HTTP request rate and latency
- Error rates (4xx, 5xx)
- Active users and sessions
- BMI calculation performance
- API endpoint response times

### **Database Metrics (PostgreSQL):**
- Connection pool status
- Query performance
- Database size and growth
- Transaction rates
- Cache hit ratios

---

## 🎯 Learning Outcomes

### **After Session 1:**
- ✅ Understand monitoring fundamentals
- ✅ Install and configure Prometheus
- ✅ Set up Node Exporter for system metrics
- ✅ Write PromQL queries
- ✅ Configure scraping and targets
- ✅ Analyze time-series data

### **After Session 2:**
- ✅ Install and configure Grafana
- ✅ Create custom dashboards
- ✅ Use dashboard variables and templating
- ✅ Import community dashboards
- ✅ Configure alerting rules
- ✅ Set up notification channels
- ✅ Implement production monitoring

### **Overall Course Completion:**
- ✅ Production-ready monitoring stack
- ✅ Comprehensive application visibility
- ✅ Proactive alerting system
- ✅ Beautiful, informative dashboards
- ✅ Skills to monitor any application
- ✅ Understanding of observability best practices

---

## ⏱️ Time Investment

| Component | Time Required |
|-----------|--------------|
| Session 1 (Prometheus) | 90 minutes |
| Session 1 Homework | 60 minutes |
| Session 2 (Grafana) | 90 minutes |
| Session 2 Homework | 60 minutes |
| **Total Course Time** | **5 hours** |

---

## 🛠️ Tools & Technologies

### **Monitoring Stack:**
- **Prometheus** v2.45+ - Metrics collection and storage
- **Node Exporter** v1.6+ - System metrics exporter
- **Grafana** v10.0+ - Visualization and dashboards
- **Alertmanager** v0.25+ - Alert routing and notifications

### **Infrastructure:**
- **AWS EC2** - Ubuntu 22.04 LTS
- **Docker** (optional) - For containerized deployment
- **Nginx** - Reverse proxy for Grafana
- **SystemD** - Service management

---

## 📚 Course Materials Included

### **Session 1 Materials:**
- ✅ Prometheus installation scripts
- ✅ Node Exporter configuration
- ✅ PromQL exercise workbook
- ✅ Configuration templates
- ✅ Troubleshooting guide
- ✅ Homework assignments

### **Session 2 Materials:**
- ✅ Grafana installation scripts
- ✅ Pre-built dashboard templates
- ✅ Alert rule examples
- ✅ Notification channel configs
- ✅ Best practices guide
- ✅ Enhancement assignments

---

## 🚦 Getting Started Checklist

### **Before Session 1:**
- [ ] BMI Health Tracker deployed and running
- [ ] SSH access to EC2 configured
- [ ] EC2 security group allows ports 9090 (Prometheus) and 9100 (Node Exporter)
- [ ] At least 2GB free disk space
- [ ] Sudo access on EC2

### **Before Session 2:**
- [ ] Completed Session 1
- [ ] Prometheus running and collecting metrics
- [ ] Node Exporter installed
- [ ] EC2 security group allows port 3000 (Grafana)
- [ ] Completed Session 1 homework

---

## 🎓 Course Goals Alignment

### **1. Monitoring Fundamentals**
**Goal:** Understand the "why" and "what" of monitoring

**Covered:**
- Four golden signals (latency, traffic, errors, saturation)
- Metrics vs logs vs traces
- Push vs pull monitoring models
- Time-series databases

### **2. Prometheus Mastery**
**Goal:** Become proficient in Prometheus configuration and querying

**Covered:**
- Architecture and components
- Service discovery and scraping
- PromQL query language
- Recording and alerting rules
- Data retention and storage

### **3. Grafana Proficiency**
**Goal:** Create informative, beautiful dashboards

**Covered:**
- Dashboard design principles
- Panel types and visualizations
- Variables and templating
- Community dashboard ecosystem
- Sharing and exporting

### **4. Application Monitoring**
**Goal:** Monitor real-world three-tier application

**Covered:**
- Frontend monitoring (React app)
- Backend API monitoring (Node.js/Express)
- Database monitoring (PostgreSQL)
- Nginx metrics
- Custom application metrics

### **5. Alerting & Incident Response**
**Goal:** Proactive problem detection and notification

**Covered:**
- Alert rule configuration
- Alertmanager setup
- Notification channels (email, Slack)
- Alert fatigue prevention
- On-call best practices

---

## 📈 Deployment Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      AWS EC2 Instance                    │
│                                                           │
│  ┌──────────────┐    ┌──────────────┐    ┌───────────┐ │
│  │   BMI App    │───▶│  Prometheus  │───▶│  Grafana  │ │
│  │ (Port 3000)  │    │ (Port 9090)  │    │(Port 3000)│ │
│  └──────────────┘    └──────────────┘    └───────────┘ │
│         │                    │                           │
│         ▼                    ▼                           │
│  ┌──────────────┐    ┌──────────────┐                  │
│  │  PostgreSQL  │    │Node Exporter │                  │
│  │ (Port 5432)  │    │ (Port 9100)  │                  │
│  └──────────────┘    └──────────────┘                  │
│                                                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │              Nginx (Reverse Proxy)                │  │
│  │         Port 80 → Routes to services              │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 🔗 External Resources

### **Documentation:**
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Node Exporter](https://github.com/prometheus/node_exporter)
- [PromQL Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)

### **Community:**
- [Prometheus Community Dashboards](https://grafana.com/grafana/dashboards/)
- [Awesome Prometheus](https://github.com/roaldnefs/awesome-prometheus)
- [Grafana Community Forums](https://community.grafana.com/)

### **Learning:**
- [PromQL Tutorial](https://prometheus.io/docs/prometheus/latest/querying/examples/)
- [Grafana Tutorials](https://grafana.com/tutorials/)
- [Monitoring Best Practices](https://sre.google/sre-book/monitoring-distributed-systems/)

---

## 🎯 Success Criteria

After completing this course, you should be able to:

- [ ] Explain the importance of monitoring in production
- [ ] Install and configure Prometheus from scratch
- [ ] Write complex PromQL queries
- [ ] Set up multiple exporters (Node, custom)
- [ ] Install and configure Grafana
- [ ] Create dashboards with 10+ panels
- [ ] Import and customize community dashboards
- [ ] Configure alerting rules
- [ ] Set up notification channels
- [ ] Monitor a three-tier web application
- [ ] Troubleshoot monitoring issues
- [ ] Apply monitoring best practices

---

## 📞 Support

### **For Students:**
- Questions during sessions: Ask instructor
- Technical issues: Check troubleshooting guides in each session folder
- Community help: Prometheus/Grafana Slack communities

### **For Instructors:**
- Complete setup instructions in AGENT.md
- Pre-tested scripts in scripts/ directories
- Backup slides and screenshots available
- Common issue solutions documented

---

## 🚀 Next Steps

### **After Course Completion:**
1. **Enhance Monitoring:**
   - Add custom application metrics
   - Set up log aggregation (ELK Stack)
   - Implement distributed tracing (Jaeger)
   - Add synthetic monitoring

2. **Advanced Topics:**
   - High availability Prometheus setup
   - Long-term storage (Thanos, Cortex)
   - Advanced PromQL (subqueries, aggregations)
   - SLO/SLI monitoring
   - Cost optimization

3. **Real-World Practice:**
   - Monitor your own projects
   - Contribute to community dashboards
   - Set up on-call rotations
   - Create runbooks for alerts

---

## 📝 Course Feedback

After completing the course, please provide feedback:
- What worked well?
- What could be improved?
- Additional topics to cover?
- Difficulty level appropriate?

---

**Let's Build Production-Grade Monitoring! 🚀**

Start with [Session 1: Prometheus Fundamentals](Session-1-Prometheus/README.md)
