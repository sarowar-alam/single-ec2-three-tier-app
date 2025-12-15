# GitHub Actions CI/CD Course - Master Project File

**Project:** Complete GitHub Actions CI/CD Training Course  
**Created:** December 15, 2025  
**Purpose:** Teach students to automate deployments using GitHub Actions  
**Target Application:** BMI Health Tracker (Three-Tier Application)

---

## 📁 Project Structure

```
GitHubActions-CICD/
├── AGENT.md                           # THIS FILE - Master tracking document
├── README.md                          # Course overview and syllabus
│
├── GitHub-Actions-Fundamentals/       # Session 1 Materials (90 mins)
│   ├── README.md                      # Session 1 lesson plan
│   ├── exercises/
│   │   ├── 01-hello-world/
│   │   │   ├── .github/workflows/hello.yml
│   │   │   └── README.md
│   │   ├── 02-nodejs-testing/
│   │   │   ├── .github/workflows/test.yml
│   │   │   ├── calculator.js
│   │   │   ├── calculator.test.js
│   │   │   ├── package.json
│   │   │   └── README.md
│   │   └── 03-multi-job-pipeline/
│   │       ├── .github/workflows/multi-job.yml
│   │       └── README.md
│   ├── slides/
│   │   └── session1-slides.md
│   └── homework/
│       └── assignment.md
│
└── Automate-BMI-Deployment/           # Session 2 Materials (90 mins)
    ├── README.md                      # Session 2 lesson plan
    ├── workflows/
    │   ├── deploy.yml                 # Main deployment workflow
    │   ├── deploy-with-tests.yml      # Enhanced with testing
    │   └── deploy-staging-prod.yml    # Multi-environment
    ├── scripts/
    │   ├── deploy-from-ci.sh          # EC2 deployment script
    │   ├── health-check.sh            # Health check script
    │   └── rollback.sh                # Rollback script
    ├── configs/
    │   ├── secrets-setup.md           # GitHub Secrets configuration
    │   └── nginx-config.conf          # Reference Nginx config
    ├── slides/
    │   └── session2-slides.md
    └── homework/
        └── assignment.md
```

---

## 🎯 Course Objectives

### **Session 1: GitHub Actions Fundamentals**
Students will learn:
- ✅ CI/CD concepts and benefits
- ✅ GitHub Actions architecture
- ✅ YAML syntax basics
- ✅ Creating workflows, jobs, and steps
- ✅ Using marketplace actions
- ✅ PromQL basics for queries
- ✅ Managing secrets securely
- ✅ Debugging pipelines

**Deliverables:**
- Hello World workflow running
- Node.js test pipeline functional
- Multi-job pipeline with artifacts
- Understanding of triggers and events

---

### **Session 2: Automate Full BMI Deployment**
Students will learn:
- ✅ Automating three-tier app deployment
- ✅ SSH actions for EC2 deployment
- ✅ Build and artifact management
- ✅ Zero-downtime deployments
- ✅ Health checks and verification
- ✅ Environment-specific deployments
- ✅ Rollback strategies
- ✅ Production best practices

**Deliverables:**
- Fully automated deployment pipeline
- Push to GitHub → Auto-deploy to EC2
- Working health checks
- Notification system
- Understanding of production deployments

---

## 📊 Project Status

### ✅ Completed Components

#### **Structure:**
- [x] Main folder created
- [x] Master AGENT.md created
- [x] README.md course overview
- [x] Session 1 subfolder structure
- [x] Session 2 subfolder structure

#### **Session 1 Materials:**
- [x] Exercise 1: Hello World workflow
- [x] Exercise 2: Node.js testing pipeline
- [x] Exercise 3: Multi-job pipeline
- [x] Session lesson plan
- [x] Homework assignment
- [x] Slide materials

#### **Session 2 Materials:**
- [x] Main deployment workflow (deploy.yml)
- [x] Enhanced workflow with tests
- [x] Multi-environment workflow
- [x] EC2 deployment script
- [x] Health check script
- [x] Rollback script
- [x] Secrets setup guide
- [x] Session lesson plan
- [x] Homework assignment
- [x] Slide materials

---

## 📝 File Inventory

### **Root Level (GitHubActions-CICD/)**
| File | Purpose | Status |
|------|---------|--------|
| AGENT.md | Master tracking document | ✅ Created |
| README.md | Course overview | ✅ Created |

---

### **Session 1: GitHub-Actions-Fundamentals/**

| File | Purpose | Lines | Status |
|------|---------|-------|--------|
| README.md | Session lesson plan | ~400 | ✅ Created |
| exercises/01-hello-world/.github/workflows/hello.yml | First workflow | 25 | ✅ Created |
| exercises/01-hello-world/README.md | Exercise instructions | ~50 | ✅ Created |
| exercises/02-nodejs-testing/.github/workflows/test.yml | Test pipeline | 35 | ✅ Created |
| exercises/02-nodejs-testing/calculator.js | Sample app code | 10 | ✅ Created |
| exercises/02-nodejs-testing/calculator.test.js | Unit tests | 15 | ✅ Created |
| exercises/02-nodejs-testing/package.json | Node.js config | 15 | ✅ Created |
| exercises/02-nodejs-testing/README.md | Exercise instructions | ~60 | ✅ Created |
| exercises/03-multi-job-pipeline/.github/workflows/multi-job.yml | Multi-job workflow | 65 | ✅ Created |
| exercises/03-multi-job-pipeline/README.md | Exercise instructions | ~70 | ✅ Created |
| slides/session1-slides.md | Presentation slides | ~300 | ✅ Created |
| homework/assignment.md | Homework tasks | ~100 | ✅ Created |

**Total Session 1 Files:** 12 files

---

### **Session 2: Automate-BMI-Deployment/**

| File | Purpose | Lines | Status |
|------|---------|-------|--------|
| README.md | Session lesson plan | ~450 | ✅ Created |
| workflows/deploy.yml | Main deployment workflow | ~120 | ✅ Created |
| workflows/deploy-with-tests.yml | Enhanced with tests | ~180 | ✅ Created |
| workflows/deploy-staging-prod.yml | Multi-environment | ~200 | ✅ Created |
| scripts/deploy-from-ci.sh | EC2 deployment script | ~80 | ✅ Created |
| scripts/health-check.sh | Health check script | ~40 | ✅ Created |
| scripts/rollback.sh | Rollback script | ~60 | ✅ Created |
| configs/secrets-setup.md | GitHub Secrets guide | ~120 | ✅ Created |
| configs/nginx-config.conf | Reference Nginx config | ~40 | ✅ Created |
| slides/session2-slides.md | Presentation slides | ~350 | ✅ Created |
| homework/assignment.md | Homework tasks | ~150 | ✅ Created |

**Total Session 2 Files:** 11 files

---

## 🎓 Teaching Flow

### **Session 1 Timeline (90 minutes)**

| Time | Section | Materials Used |
|------|---------|---------------|
| 0-15 min | Introduction to CI/CD | slides/session1-slides.md (Part 1) |
| 15-35 min | GitHub Actions Architecture | slides/session1-slides.md (Part 2) |
| 35-75 min | Hands-on Exercises | exercises/01-hello-world/<br>exercises/02-nodejs-testing/<br>exercises/03-multi-job-pipeline/ |
| 75-85 min | Debugging & Secrets | slides/session1-slides.md (Part 5) |
| 85-90 min | Q&A + Homework | homework/assignment.md |

**Key Files for Session 1:**
1. `slides/session1-slides.md` - Instructor presentation
2. `exercises/01-hello-world/` - First hands-on
3. `exercises/02-nodejs-testing/` - Second hands-on
4. `exercises/03-multi-job-pipeline/` - Third hands-on
5. `homework/assignment.md` - Take-home work

---

### **Session 2 Timeline (90 minutes)**

| Time | Section | Materials Used |
|------|---------|---------------|
| 0-10 min | Review Manual Process | slides/session2-slides.md (Part 1) |
| 10-25 min | Automation Strategy | slides/session2-slides.md (Part 2) |
| 25-40 min | Prerequisites Setup | configs/secrets-setup.md<br>scripts/deploy-from-ci.sh |
| 40-70 min | Create & Test Workflow | workflows/deploy.yml<br>workflows/deploy-with-tests.yml |
| 70-80 min | Live Deployment Demo | All workflow files |
| 80-85 min | Best Practices | slides/session2-slides.md (Part 8) |
| 85-90 min | Q&A + Homework | homework/assignment.md |

**Key Files for Session 2:**
1. `slides/session2-slides.md` - Instructor presentation
2. `workflows/deploy.yml` - Main deployment workflow
3. `scripts/deploy-from-ci.sh` - EC2 script
4. `configs/secrets-setup.md` - Secrets configuration
5. `homework/assignment.md` - Enhancement tasks

---

## 🔧 Prerequisites

### **For Students:**
- ✅ GitHub account
- ✅ Git installed locally
- ✅ Text editor (VS Code recommended)
- ✅ BMI app deployed manually on EC2 (from previous sessions)
- ✅ Basic understanding of Git (commit, push, pull)
- ✅ SSH access to EC2 instance

### **For Instructor:**
- ✅ Demo GitHub repository
- ✅ Demo EC2 instance with BMI app
- ✅ Screen sharing setup
- ✅ All materials in this folder structure
- ✅ Backup examples if live demos fail

---

## 📚 Additional Resources

### **Referenced Documentation:**
- GitHub Actions Documentation: https://docs.github.com/en/actions
- YAML Syntax: https://yaml.org/
- GitHub Actions Marketplace: https://github.com/marketplace?type=actions
- SSH Action: https://github.com/appleboy/ssh-action
- SCP Action: https://github.com/appleboy/scp-action

### **Sample Repositories:**
- GitHub Actions Samples: https://github.com/actions/starter-workflows
- Real-world CI/CD Examples: https://github.com/topics/github-actions

---

## 🎯 Learning Outcomes

### **After Session 1, Students Can:**
- [ ] Explain CI/CD benefits
- [ ] Understand GitHub Actions architecture
- [ ] Write YAML configuration files
- [ ] Create workflows with jobs and steps
- [ ] Use marketplace actions
- [ ] Manage GitHub Secrets
- [ ] Debug workflow failures
- [ ] Implement basic test automation

### **After Session 2, Students Can:**
- [ ] Automate full application deployment
- [ ] Configure SSH-based deployments
- [ ] Implement build artifact transfer
- [ ] Set up health checks
- [ ] Configure multi-environment deployments
- [ ] Implement rollback strategies
- [ ] Follow production deployment best practices
- [ ] Reduce deployment time from 10 min to 3 min

---

## 🚀 Deployment Workflow Summary

### **Current State (Manual):**
```bash
1. Developer writes code
2. Commit and push to GitHub
3. SSH into EC2
4. git pull origin main
5. cd backend && npm install
6. cd ../frontend && npm install && npm run build
7. sudo cp -r dist/* /var/www/bmi-health-tracker/
8. pm2 restart bmi-backend
9. Check logs manually
⏰ Time: 5-10 minutes
```

### **After Course (Automated):**
```bash
1. Developer writes code
2. git push origin main
   ↓ (GitHub Actions automatically does everything)
   ✓ Run tests
   ✓ Build frontend
   ✓ Deploy to EC2
   ✓ Health check
   ✓ Notify team
⏰ Time: 2-3 minutes (hands-off)
```

---

## 📊 Metrics & Success Criteria

### **Course Effectiveness:**
- ✅ 90%+ students complete both sessions
- ✅ 80%+ successfully deploy automated pipeline
- ✅ 70%+ complete homework assignments
- ✅ Average deployment time reduced from 10 min → 3 min
- ✅ 100% understand CI/CD concepts

### **Technical Metrics:**
- ✅ Workflow runs successfully on first try: 60%+
- ✅ Zero-downtime deployments: 100%
- ✅ Health check pass rate: 95%+
- ✅ Average build time: 2-3 minutes
- ✅ Test pass rate: 90%+

---

## 🐛 Known Issues & Solutions

### **Issue 1: SSH Connection Fails**
**Symptom:** `Permission denied (publickey)`  
**Solution:** Check EC2_SSH_KEY secret has correct private key format  
**File:** `configs/secrets-setup.md` (section 3)

### **Issue 2: Permission Denied Copying to /var/www/**
**Symptom:** `cp: cannot create regular file`  
**Solution:** Use `sudo` in deployment script  
**File:** `scripts/deploy-from-ci.sh` (line 20)

### **Issue 3: PM2 Command Not Found**
**Symptom:** `pm2: command not found`  
**Solution:** Add PM2 to PATH  
**File:** `scripts/deploy-from-ci.sh` (line 5)

### **Issue 4: Health Check Fails After Deployment**
**Symptom:** Backend not responding immediately  
**Solution:** Increase sleep time from 3s to 10s  
**File:** `scripts/health-check.sh` (line 8)

---

## 🔄 Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | Dec 15, 2025 | Initial course structure created | DevOps Team |
| 1.0 | Dec 15, 2025 | All Session 1 materials completed | DevOps Team |
| 1.0 | Dec 15, 2025 | All Session 2 materials completed | DevOps Team |

---

## 📞 Support & Contact

### **For Students:**
- Questions during sessions: Ask instructor
- Technical issues: Check troubleshooting sections in README files
- Homework help: Course discussion forum / Slack channel

### **For Instructors:**
- Material updates: Submit PR to this repository
- Bug reports: Open GitHub issue
- Suggestions: Contact course coordinator

---

## 🎓 Next Steps After Course

### **Immediate (Week 1):**
1. Complete both homework assignments
2. Deploy BMI app with automated pipeline
3. Add tests to backend and frontend
4. Set up Slack/Discord notifications

### **Short-term (Week 2-4):**
1. Add staging environment
2. Implement manual approval for production
3. Add database backup before deployment
4. Create rollback workflow
5. Add deployment badges to README

### **Long-term (Month 2-3):**
1. Implement blue-green deployments
2. Add canary releases
3. Create custom GitHub Actions
4. Implement GitOps with ArgoCD
5. Move to Kubernetes with CI/CD

---

## 📈 Course Roadmap

### **Current Coverage:**
✅ GitHub Actions basics  
✅ CI/CD fundamentals  
✅ Automated testing  
✅ SSH-based deployment  
✅ Health checks  
✅ Multi-environment deployment  

### **Future Additions (Optional):**
⬜ Docker container deployments  
⬜ Kubernetes deployments  
⬜ Integration testing  
⬜ Performance testing  
⬜ Security scanning (SAST/DAST)  
⬜ Dependency vulnerability scanning  
⬜ Infrastructure as Code (Terraform)  
⬜ GitOps practices  

---

## 🏆 Certification Path

After completing this course, students are prepared for:
- ✅ GitHub Actions Certification (unofficial)
- ✅ Entry-level DevOps Engineer roles
- ✅ Junior CI/CD Engineer positions
- ✅ Understanding foundation for AWS DevOps certification
- ✅ Understanding foundation for Kubernetes certifications (CKA/CKAD)

---

## 📝 Instructor Notes

### **Preparation Checklist:**

**Before Session 1:**
- [ ] Ensure all students have GitHub accounts
- [ ] Test hello-world workflow yourself
- [ ] Prepare demo repository
- [ ] Set up screen sharing
- [ ] Print/share homework assignments

**Before Session 2:**
- [ ] Verify students completed Session 1 homework
- [ ] Ensure EC2 instance is running
- [ ] Test deployment workflow end-to-end
- [ ] Prepare backup examples
- [ ] Have troubleshooting guide ready

### **Live Demo Tips:**
1. Always have a backup prepared workflow
2. Commit your workflow changes beforehand
3. Use `workflow_dispatch` for manual triggers during demo
4. Keep GitHub Actions tab open to show real-time progress
5. Have EC2 logs ready in another terminal
6. Prepare intentional errors to show debugging

### **Common Student Questions:**
1. "Why use GitHub Actions vs Jenkins?"
   - Answer in slides/session1-slides.md (Part 2)
2. "How do secrets work securely?"
   - Answer in slides/session1-slides.md (Part 6)
3. "What if deployment fails?"
   - Answer in scripts/rollback.sh + slides/session2-slides.md (Part 7)
4. "How to deploy to multiple environments?"
   - Answer in workflows/deploy-staging-prod.yml

---

## 🎯 Success Story

**After completing this course, students can say:**

> "I implemented a complete CI/CD pipeline using GitHub Actions for a three-tier web application. Every push to the main branch automatically runs tests, builds the frontend, deploys to AWS EC2, and performs health checks. This reduced our deployment time from 10 minutes of manual work to 3 minutes of automated deployment, with zero downtime. I configured multi-environment deployments with separate staging and production workflows, implemented rollback capabilities, and integrated Slack notifications for the team."

**Portfolio Impact:**
- ✅ GitHub repository with `.github/workflows/` folder
- ✅ README with CI/CD badge showing build status
- ✅ Live application URL deployed via CI/CD
- ✅ Documentation of automation strategy
- ✅ Demonstrates modern DevOps practices

---

## 📂 Quick Navigation

### **For Instructors:**
- [Session 1 Lesson Plan](GitHub-Actions-Fundamentals/README.md)
- [Session 1 Slides](GitHub-Actions-Fundamentals/slides/session1-slides.md)
- [Session 2 Lesson Plan](Automate-BMI-Deployment/README.md)
- [Session 2 Slides](Automate-BMI-Deployment/slides/session2-slides.md)

### **For Students:**
- [Course Overview](README.md)
- [Session 1 Exercises](GitHub-Actions-Fundamentals/exercises/)
- [Session 1 Homework](GitHub-Actions-Fundamentals/homework/assignment.md)
- [Session 2 Workflows](Automate-BMI-Deployment/workflows/)
- [Session 2 Homework](Automate-BMI-Deployment/homework/assignment.md)

### **For Reference:**
- [Deployment Script](Automate-BMI-Deployment/scripts/deploy-from-ci.sh)
- [Secrets Setup Guide](Automate-BMI-Deployment/configs/secrets-setup.md)
- [Main Deployment Workflow](Automate-BMI-Deployment/workflows/deploy.yml)

---

## ✅ Final Checklist

### **Course Delivery:**
- [x] All materials created
- [x] All code tested and working
- [x] All documentation complete
- [x] Homework assignments ready
- [x] Troubleshooting guides prepared
- [x] Next steps defined

### **Student Readiness:**
- [ ] GitHub accounts created
- [ ] BMI app deployed manually
- [ ] EC2 access confirmed
- [ ] Basic Git knowledge verified
- [ ] Development environment set up

---

**Course Status: ✅ READY FOR DELIVERY**

**Total Materials:** 23 files across 2 sessions  
**Estimated Preparation Time:** 30 minutes (review materials)  
**Estimated Teaching Time:** 180 minutes (2 x 90-minute sessions)  
**Student Practice Time:** 4-6 hours (homework + exploration)

**Last Updated:** December 15, 2025  
**Next Review:** After first course delivery
