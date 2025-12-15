# Session 1: GitHub Actions Fundamentals

**Duration:** 90 minutes  
**Level:** Beginner  
**Prerequisites:** GitHub account, basic Git knowledge

---

## 🎯 Learning Objectives

By the end of this session, you will be able to:
- ✅ Explain CI/CD concepts and benefits
- ✅ Understand GitHub Actions architecture
- ✅ Write YAML configuration files
- ✅ Create workflows with jobs and steps
- ✅ Use marketplace actions
- ✅ Manage GitHub Secrets
- ✅ Debug workflow failures
- ✅ Implement automated testing

---

## 📅 Session Timeline

| Time | Topic | Type | Materials |
|------|-------|------|-----------|
| 0-15 min | Introduction to CI/CD | Lecture | [slides/session1-slides.md](slides/session1-slides.md) Part 1 |
| 15-20 min | GitHub Actions Architecture | Lecture | [slides/session1-slides.md](slides/session1-slides.md) Part 2 |
| 20-25 min | YAML Basics | Lecture | [slides/session1-slides.md](slides/session1-slides.md) Part 3 |
| 25-35 min | **Exercise 1:** Hello World | Hands-on | [exercises/01-hello-world/](exercises/01-hello-world/) |
| 35-55 min | **Exercise 2:** Node.js Testing | Hands-on | [exercises/02-nodejs-testing/](exercises/02-nodejs-testing/) |
| 55-75 min | **Exercise 3:** Multi-Job Pipeline | Hands-on | [exercises/03-multi-job-pipeline/](exercises/03-multi-job-pipeline/) |
| 75-80 min | Triggers & Debugging | Lecture | [slides/session1-slides.md](slides/session1-slides.md) Part 4-5 |
| 80-85 min | Secrets Management | Lecture | [slides/session1-slides.md](slides/session1-slides.md) Part 6 |
| 85-90 min | Q&A + Homework | Discussion | [homework/assignment.md](homework/assignment.md) |

---

## 📚 Topics Covered

### **1. Introduction to CI/CD (15 minutes)**
- What is Continuous Integration?
- What is Continuous Deployment?
- Real-world examples and benefits
- CI/CD without vs with automation
- Industry adoption and importance

### **2. GitHub Actions Architecture (5 minutes)**
- Workflows, Jobs, Steps, Actions, Runners
- Event triggers
- GitHub-hosted vs self-hosted runners
- Marketplace actions

### **3. YAML Syntax Basics (5 minutes)**
- Comments, strings, numbers
- Lists and dictionaries
- Multi-line strings
- Common pitfalls

### **4. Hands-On Exercises (50 minutes)**

#### **Exercise 1: Hello World Workflow (10 min)**
- Create first workflow
- Understand workflow structure
- Push and watch execution
- View logs

#### **Exercise 2: Node.js Test Pipeline (20 min)**
- Set up Node.js environment
- Install dependencies
- Run automated tests
- Use marketplace actions

#### **Exercise 3: Multi-Job Pipeline (20 min)**
- Create parallel jobs
- Use job dependencies (`needs`)
- Upload/download artifacts
- Understand job execution flow

### **5. Triggers, Debugging & Secrets (10 minutes)**
- Different trigger types
- Manual workflow dispatch
- Debugging failed workflows
- Secrets management
- Environment variables

---

## 🛠️ Required Tools

### **For Students:**
- ✅ GitHub account (free)
- ✅ Web browser
- ✅ Text editor (VS Code recommended)
- ✅ Git installed locally
- ✅ Node.js installed (for local testing - optional)

### **Setup Before Session:**
```bash
# Verify Git is installed
git --version

# Verify Node.js is installed (optional)
node --version
npm --version

# Configure Git if not already done
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

---

## 📝 Learning Activities

### **Activity 1: Create GitHub Repository**
**Time:** 5 minutes (during Exercise 1)

```bash
# 1. Go to GitHub.com
# 2. Click "+" → "New repository"
# 3. Name: "github-actions-demo"
# 4. Public repository
# 5. Initialize with README
# 6. Clone locally:

git clone https://github.com/YOUR_USERNAME/github-actions-demo.git
cd github-actions-demo
```

---

### **Activity 2: Hello World Workflow**
**Time:** 10 minutes

**Goal:** Create and run your first GitHub Actions workflow

**Steps:**
1. Create workflow directory
2. Write simple workflow YAML
3. Commit and push
4. Watch workflow execute
5. View logs

**Location:** [exercises/01-hello-world/](exercises/01-hello-world/)

**Expected Output:**
- ✅ Workflow runs successfully
- ✅ "Hello from GitHub Actions!" message in logs
- ✅ System information displayed
- ✅ Green checkmark on GitHub

---

### **Activity 3: Node.js Test Pipeline**
**Time:** 20 minutes

**Goal:** Create a pipeline that tests a Node.js application

**Steps:**
1. Create simple calculator app
2. Write unit tests with Jest
3. Create workflow that runs tests
4. Push code and watch tests run
5. Fix failing test
6. Watch re-run with green status

**Location:** [exercises/02-nodejs-testing/](exercises/02-nodejs-testing/)

**Expected Output:**
- ✅ Node.js environment set up
- ✅ Dependencies installed
- ✅ Tests execute automatically
- ✅ Pass/fail status visible
- ✅ Understanding of test automation

---

### **Activity 4: Multi-Job Pipeline**
**Time:** 20 minutes

**Goal:** Create a pipeline with parallel jobs and dependencies

**Steps:**
1. Create workflow with 3 jobs
2. Run test and lint in parallel
3. Build only after tests pass
4. Upload build artifacts
5. Understand job orchestration

**Location:** [exercises/03-multi-job-pipeline/](exercises/03-multi-job-pipeline/)

**Expected Output:**
- ✅ Parallel job execution
- ✅ Job dependencies working (`needs`)
- ✅ Artifacts uploaded successfully
- ✅ Understanding of job flow

---

## 🎓 Learning Checkpoints

### **After Exercise 1, Students Should Know:**
- [ ] What a GitHub Actions workflow is
- [ ] How to create `.github/workflows/` directory
- [ ] Basic YAML syntax
- [ ] How to trigger a workflow
- [ ] Where to view workflow logs

### **After Exercise 2, Students Should Know:**
- [ ] How to use marketplace actions
- [ ] How to set up programming language environments
- [ ] How to run automated tests
- [ ] How to interpret test results
- [ ] Importance of automated testing in CI/CD

### **After Exercise 3, Students Should Know:**
- [ ] How to create multiple jobs
- [ ] How to make jobs run in parallel
- [ ] How to create job dependencies
- [ ] How to use artifacts
- [ ] Real-world pipeline structure

---

## 🐛 Common Issues & Solutions

### **Issue 1: Workflow File Not Found**
**Symptom:** Workflow doesn't appear in Actions tab  
**Cause:** File not in `.github/workflows/` or wrong extension  
**Solution:** Ensure path is `.github/workflows/filename.yml`

### **Issue 2: YAML Syntax Error**
**Symptom:** Workflow fails with "Invalid workflow file"  
**Cause:** Incorrect indentation or syntax  
**Solution:** Use YAML validator: https://www.yamllint.com/

### **Issue 3: Workflow Not Triggering**
**Symptom:** Push doesn't start workflow  
**Cause:** Wrong branch or trigger configuration  
**Solution:** Check `on:` section matches your branch

### **Issue 4: Permission Denied**
**Symptom:** Can't write to repository  
**Cause:** No write permissions  
**Solution:** Check repository permissions settings

### **Issue 5: Test Failures**
**Symptom:** Tests fail in CI but pass locally  
**Cause:** Environment differences  
**Solution:** Check Node.js version, dependencies

---

## 📖 Key Concepts

### **Workflow**
A configurable automated process made up of one or more jobs. Defined in YAML file in `.github/workflows/`.

### **Event**
Specific activity that triggers a workflow (push, pull_request, schedule, etc.)

### **Job**
A set of steps that execute on the same runner. Multiple jobs run in parallel by default.

### **Step**
Individual task within a job. Can run commands or actions.

### **Action**
Reusable unit of code. Can be from marketplace or custom-built.

### **Runner**
Server that runs your workflows. GitHub provides hosted runners (Ubuntu, Windows, macOS).

### **Artifact**
Files produced by a workflow that you want to keep (build outputs, test reports, etc.)

---

## 💡 Best Practices Introduced

### **1. Naming Conventions**
```yaml
name: Descriptive Workflow Name  # Use clear names
jobs:
  job-name:                      # Use kebab-case
    name: Human Readable Name    # Add display names
```

### **2. Use Specific Versions**
```yaml
- uses: actions/checkout@v3       # ✅ Good: Specific version
- uses: actions/checkout@latest   # ❌ Bad: Unpredictable
```

### **3. Cache Dependencies**
```yaml
- name: Setup Node.js
  uses: actions/setup-node@v3
  with:
    node-version: '18'
    cache: 'npm'                  # ✅ Caches node_modules
```

### **4. Fail Fast**
```yaml
jobs:
  build:
    needs: [test]                 # ✅ Don't build if tests fail
```

### **5. Use Secrets**
```yaml
- name: Deploy
  env:
    API_KEY: ${{ secrets.API_KEY }}  # ✅ Never hardcode secrets
```

---

## 📋 Homework Assignment

**Due:** Before Session 2

**Tasks:**
1. Complete all 3 exercises if not finished during the session
2. Create a workflow that:
   - Triggers on push to main
   - Runs on Ubuntu
   - Checks out code
   - Installs Node.js 18
   - Runs `npm install`
   - Runs `npm test`
   - Only runs build if tests pass
   - Uploads build artifacts
3. Add a status badge to your README
4. Write 3 PromQL queries for monitoring (prep for monitoring session)

**Detailed Instructions:** [homework/assignment.md](homework/assignment.md)

---

## 🎯 Success Criteria

### **Successfully Complete This Session When You:**
- ✅ Have 3 working workflows in their repository
- ✅ Can explain CI/CD benefits
- ✅ Understand workflow → job → step hierarchy
- ✅ Can read and write basic YAML
- ✅ Know how to find and use marketplace actions
- ✅ Can debug basic workflow issues
- ✅ Understand how to use secrets

---

## 📚 Additional Resources

### **Documentation:**
- [GitHub Actions Quickstart](https://docs.github.com/en/actions/quickstart)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [YAML Syntax](https://yaml.org/)

### **Video Tutorials:**
- GitHub Actions Tutorial (YouTube)
- CI/CD Explained (YouTube)

### **Practice:**
- [GitHub Skills: Introduction to GitHub Actions](https://github.com/skills/hello-github-actions)

---

## 🎓 Instructor Notes

### **Preparation:**
- [ ] Test all exercise workflows before session
- [ ] Prepare demo repository
- [ ] Have backup workflows ready
- [ ] Set up screen sharing
- [ ] Print/share exercise instructions

### **Teaching Tips:**
1. **Start with "why"** - Show broken deployment story
2. **Live code** - Don't use slides for exercises
3. **Intentional errors** - Show how to debug
4. **Celebrate success** - Green checkmarks are exciting!
5. **Pause for questions** - Every 15 minutes

### **Common Student Questions:**
1. **"Why GitHub Actions vs Jenkins?"**
   - Answer: No infrastructure, free, easier learning curve, cloud-native

2. **"What if I make a mistake?"**
   - Answer: Workflows are in Git - you can always revert

3. **"How many workflows can I have?"**
   - Answer: Unlimited workflows, but free tier has 2,000 minutes/month

4. **"Can this deploy to AWS?"**
   - Answer: Yes! That's what we'll do in Session 2

### **Timing Flexibility:**
- If ahead: Add more trigger types discussion
- If behind: Combine exercises 2 and 3 with less detail
- Keep 10 minutes for Q&A minimum

### **Breakout Rooms:**
- Use for exercises if group size > 15
- Group students by experience level
- Rotate between rooms to help

---

## ✅ Pre-Session Checklist

### **For Instructor:**
- [ ] Review all exercise instructions
- [ ] Test workflows on fresh repository
- [ ] Prepare demo environment
- [ ] Set up screen sharing and recording
- [ ] Have troubleshooting guide ready
- [ ] Print or share homework assignment

### **For Students (send 1 day before):**
- [ ] GitHub account created
- [ ] Git installed and configured
- [ ] Text editor installed
- [ ] Review basic Git commands (add, commit, push)
- [ ] Read course README

---

## 🎉 Expected Outcomes

### **Immediately After Session:**
- Students have 3 working workflows
- Students understand CI/CD value
- Students can create simple workflows independently
- Students excited about automation

### **After Homework:**
- Students comfortable with YAML
- Students can use marketplace actions
- Students understand testing automation
- Students ready for Session 2 deployment

---

## 📞 Support

### **During Session:**
- Raise hand for questions
- Use chat for technical issues
- Instructor will pause for group questions

### **After Session:**
- Review exercise README files
- Check troubleshooting sections
- Post in course forum
- Email instructor for complex issues

---

## 🚀 Next Steps

After completing Session 1:
1. ✅ Finish homework assignment
2. ✅ Ensure BMI app is deployed manually on EC2
3. ✅ Prepare EC2 SSH access for Session 2
4. ✅ Review Session 2 prerequisites
5. ✅ Get excited about automating real deployments!

**Next Session:** [Automate Full BMI Deployment](../Automate-BMI-Deployment/README.md)

---

**Questions? Review the [Course README](../README.md) or ask your instructor!**
