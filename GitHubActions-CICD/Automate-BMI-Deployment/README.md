# Session 2: Automate Full BMI Deployment

**Duration:** 90 minutes  
**Level:** Intermediate  
**Prerequisites:** Completed Session 1, BMI app deployed manually on EC2

---

## 🎯 Learning Objectives

By the end of this session, you will:
- ✅ Automate complete three-tier application deployment
- ✅ Use SSH actions to deploy to AWS EC2
- ✅ Implement build artifact management
- ✅ Set up health checks post-deployment
- ✅ Configure secrets securely
- ✅ Understand zero-downtime deployments
- ✅ Implement rollback strategies
- ✅ Apply production best practices

---

## 📅 Session Timeline

| Time | Topic | Type | Materials |
|------|-------|------|-----------|
| 0-10 min | Review Manual Process | Discussion | slides/session2-slides.md |
| 10-25 min | Automation Strategy | Lecture | slides/session2-slides.md |
| 25-40 min | Prerequisites Setup | Hands-on | configs/secrets-setup.md |
| 40-70 min | Create Deployment Workflow | Hands-on | workflows/deploy.yml |
| 70-80 min | Live Deployment & Testing | Demo | All workflows |
| 80-85 min | Best Practices | Lecture | slides/session2-slides.md |
| 85-90 min | Q&A + Homework | Discussion | homework/assignment.md |

---

## 🎓 What You'll Achieve

### **Before (Manual Deployment):**
```
⏰ Time: 5-10 minutes of manual work
🐛 Error-prone: Typos, forgotten steps
😰 Stressful: Fear of breaking production
```

### **After (Automated Deployment):**
```
⏰ Time: 2-3 minutes (hands-off)
✅ Reliable: Same process every time
😊 Confident: Automated verification
```

---

## 📋 Prerequisites

### **Required:**
- ✅ Completed Session 1
- ✅ BMI app deployed manually on EC2
- ✅ EC2 instance running and accessible
- ✅ SSH private key for EC2
- ✅ GitHub repository with BMI app code

### **Verify Before Starting:**

```bash
# 1. Can SSH into EC2?
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# 2. Is BMI app running?
pm2 status
# Should show: bmi-backend | online

# 3. Is frontend accessible?
curl http://localhost
# Should return HTML

# 4. Is backend responding?
curl http://localhost:3000/health
# Should return: {"status":"ok"}
```

---

## 🗂️ Course Materials

### **Workflows:**
- [deploy.yml](workflows/deploy.yml) - Main deployment workflow
- [deploy-with-tests.yml](workflows/deploy-with-tests.yml) - Enhanced with testing
- [deploy-staging-prod.yml](workflows/deploy-staging-prod.yml) - Multi-environment

### **Scripts:**
- [deploy-from-ci.sh](scripts/deploy-from-ci.sh) - EC2 deployment script
- [health-check.sh](scripts/health-check.sh) - Post-deployment verification
- [rollback.sh](scripts/rollback.sh) - Rollback to previous version

### **Configuration:**
- [secrets-setup.md](configs/secrets-setup.md) - GitHub Secrets guide
- [nginx-config.conf](configs/nginx-config.conf) - Reference configuration

---

## 🚀 Deployment Architecture

```
┌──────────────────────────────────────────────────────────┐
│  Developer                                                │
│  └─ git push origin main                                 │
└────────────────┬─────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────┐
│  GitHub Actions (Automated)                              │
│  ┌────────────────────────────────────────────────────┐  │
│  │  JOB 1: Test                                       │  │
│  │  - Checkout code                                   │  │
│  │  - Install dependencies                            │  │
│  │  - Run backend tests                               │  │
│  │  - Run frontend tests                              │  │
│  └────────────────────────────────────────────────────┘  │
│                         │                                 │
│                         ▼                                 │
│  ┌────────────────────────────────────────────────────┐  │
│  │  JOB 2: Build                                      │  │
│  │  - Checkout code                                   │  │
│  │  - Install dependencies                            │  │
│  │  - Build frontend (npm run build)                  │  │
│  │  - Upload artifacts                                │  │
│  └────────────────────────────────────────────────────┘  │
│                         │                                 │
│                         ▼                                 │
│  ┌────────────────────────────────────────────────────┐  │
│  │  JOB 3: Deploy to EC2                              │  │
│  │  - Download artifacts                              │  │
│  │  - SSH into EC2                                    │  │
│  │  - Pull latest code                                │  │
│  │  - Install backend dependencies                    │  │
│  │  - Copy frontend build                             │  │
│  │  - Restart PM2                                     │  │
│  │  - Health check                                    │  │
│  └────────────────────────────────────────────────────┘  │
└────────────────┬─────────────────────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────────────────────┐
│  AWS EC2 Instance                                        │
│  └─ Application Updated and Running                     │
└──────────────────────────────────────────────────────────┘
```

---

## 📚 Key Concepts

### **1. SSH-Based Deployment**
- GitHub Actions connects to EC2 via SSH
- Uses appleboy/ssh-action
- Runs deployment commands remotely
- Secure with SSH keys (not passwords)

### **2. Build Artifacts**
- Frontend built in GitHub Actions
- Transferred to EC2
- Nginx serves static files
- Separation of build and deploy

### **3. Zero-Downtime Deployment**
- PM2 restarts quickly (~1-2 seconds)
- Nginx continues serving during restart
- Health checks verify success
- Rollback if health check fails

### **4. Secrets Management**
- SSH keys stored as GitHub Secrets
- Never committed to repository
- Encrypted and secure
- Available in workflows as `${{ secrets.NAME }}`

---

## 🛠️ Setup Instructions

### **Step 1: Prepare EC2 Deployment Script**

SSH into EC2 and create `/home/ubuntu/deploy-from-ci.sh`:

```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# Create script
nano /home/ubuntu/deploy-from-ci.sh
```

**Paste the content from:** [scripts/deploy-from-ci.sh](scripts/deploy-from-ci.sh)

**Make it executable:**
```bash
chmod +x /home/ubuntu/deploy-from-ci.sh
```

---

### **Step 2: Configure GitHub Secrets**

Follow the detailed guide: [configs/secrets-setup.md](configs/secrets-setup.md)

**Secrets to add:**
1. `EC2_HOST` - Your EC2 IP address
2. `EC2_USERNAME` - `ubuntu`
3. `EC2_SSH_KEY` - Your private SSH key
4. `EC2_PORT` - `22`

---

### **Step 3: Create Deployment Workflow**

In your BMI app repository, create:
`.github/workflows/deploy.yml`

**Copy content from:** [workflows/deploy.yml](workflows/deploy.yml)

---

### **Step 4: Commit and Deploy**

```bash
git add .github/workflows/deploy.yml
git commit -m "Add CI/CD deployment pipeline"
git push origin main
```

**Watch it deploy automatically!**

---

## ✅ Success Criteria

### **Workflow Completes Successfully:**
- ✅ All jobs show green checkmarks
- ✅ Tests pass
- ✅ Frontend builds
- ✅ Deployment to EC2 succeeds
- ✅ Health check passes

### **Application Works:**
- ✅ Visit `http://YOUR_EC2_IP`
- ✅ Frontend loads correctly
- ✅ Can create new measurements
- ✅ Chart displays data
- ✅ No console errors

---

## 🧪 Testing the Pipeline

### **Test 1: Update Frontend**

Edit `frontend/src/App.jsx`:
```jsx
<h1>BMI Health Tracker v2.0</h1>
```

```bash
git add frontend/src/App.jsx
git commit -m "Update version to 2.0"
git push origin main
```

**Watch:** Automatic deployment → Refresh browser → See v2.0!

---

### **Test 2: Update Backend**

Edit `backend/src/routes.js`:
```javascript
// Add new endpoint
app.get('/api/version', (req, res) => {
  res.json({ version: '2.0.0' });
});
```

Push and verify:
```bash
curl http://YOUR_EC2_IP/api/version
# Should return: {"version":"2.0.0"}
```

---

## 🐛 Troubleshooting

### **SSH Connection Fails**
**Error:** `Permission denied (publickey)`

**Solutions:**
1. Check `EC2_SSH_KEY` secret has complete private key
2. Verify key includes `-----BEGIN` and `-----END` lines
3. Ensure no extra spaces or line breaks
4. Test SSH manually first

---

### **Permission Denied on /var/www/**
**Error:** `cp: cannot create regular file`

**Solution:** Add `sudo` to copy command in deploy script

---

### **PM2 Command Not Found**
**Error:** `pm2: command not found`

**Solution:** Add to deploy script:
```bash
export PATH=$PATH:/home/ubuntu/.npm-global/bin
```

---

### **Health Check Fails**
**Error:** Backend not responding

**Solutions:**
1. Increase wait time before health check (3s → 10s)
2. Check PM2 logs: `pm2 logs bmi-backend`
3. Verify database connection
4. Check backend port (3000)

---

## 📊 Monitoring Deployment

### **View Workflow Progress:**
1. GitHub → Actions tab
2. Click running workflow
3. Expand each job to see steps
4. View real-time logs

### **Check EC2 Status:**
```bash
# SSH into EC2
ssh -i key.pem ubuntu@YOUR_EC2_IP

# Check PM2
pm2 status
pm2 logs bmi-backend --lines 50

# Check Nginx
sudo nginx -t
sudo systemctl status nginx

# Check disk space
df -h
```

---

## 🎓 Learning Outcomes

After this session, you can:
- ✅ Automate three-tier app deployments
- ✅ Use GitHub Actions for production deployments
- ✅ Implement CI/CD best practices
- ✅ Manage secrets securely
- ✅ Set up health checks
- ✅ Troubleshoot deployment issues
- ✅ Reduce deployment time by 70%+

---

## 📚 Additional Resources

- [appleboy/ssh-action Documentation](https://github.com/appleboy/ssh-action)
- [GitHub Actions Security Best Practices](https://docs.github.com/en/actions/security-guides)
- [PM2 Documentation](https://pm2.keymetrics.io/)

---

## 🚀 Next Steps

1. ✅ Complete homework assignment
2. ✅ Add more tests to your pipeline
3. ✅ Implement staging environment
4. ✅ Add Slack/Discord notifications
5. ✅ Create rollback workflow
6. ✅ Add monitoring integration

---

**Homework:** [homework/assignment.md](homework/assignment.md)

**Questions?** Ask your instructor or post in the course forum!
