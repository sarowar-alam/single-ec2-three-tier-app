# Exercise 1: Hello World Workflow

**Duration:** 10 minutes  
**Difficulty:** ⭐ Beginner  
**Goal:** Create and run your first GitHub Actions workflow

---

## 🎯 Objectives

By the end of this exercise, you will:
- ✅ Create a GitHub repository
- ✅ Understand workflow file structure
- ✅ Create your first `.github/workflows/` directory
- ✅ Write a simple YAML workflow
- ✅ Trigger a workflow by pushing code
- ✅ View workflow logs in GitHub Actions tab

---

## 📋 Prerequisites

- GitHub account (free)
- Git installed on your computer
- Text editor (VS Code, Sublime, Notepad++, etc.)

---

## 🚀 Step-by-Step Instructions

### **Step 1: Create GitHub Repository**

1. Go to [GitHub.com](https://github.com)
2. Click the **"+"** button in top right → **"New repository"**
3. Fill in details:
   - **Repository name:** `github-actions-demo`
   - **Description:** "Learning GitHub Actions"
   - **Visibility:** Public
   - **☑️ Initialize with README**
4. Click **"Create repository"**

---

### **Step 2: Clone Repository Locally**

```bash
# Clone the repository (replace YOUR_USERNAME)
git clone https://github.com/YOUR_USERNAME/github-actions-demo.git

# Navigate into directory
cd github-actions-demo

# Verify you're in the right place
ls -la
# You should see: README.md and .git/
```

---

### **Step 3: Create Workflow Directory**

```bash
# Create the required directory structure
mkdir -p .github/workflows

# Verify it was created
ls -la .github/
```

**Why `.github/workflows/`?**
- GitHub Actions looks for workflows in this specific directory
- Must be at the repository root
- Must be exactly `.github/workflows/` (case-sensitive on Linux)

---

### **Step 4: Create Workflow File**

Create a new file: `.github/workflows/hello.yml`

```bash
# Using VS Code
code .github/workflows/hello.yml

# Or using any text editor
# nano .github/workflows/hello.yml
# vim .github/workflows/hello.yml
```

**Paste this content:**

```yaml
name: Hello World Pipeline

# Trigger: Run on every push to any branch
on: [push]

# Jobs to run
jobs:
  say-hello:
    # Runner: Use Ubuntu latest
    runs-on: ubuntu-latest
    
    # Steps to execute
    steps:
      # Step 1: Print a message
      - name: Say Hello
        run: echo "Hello from GitHub Actions!"
      
      # Step 2: Print system info
      - name: Print System Info
        run: |
          echo "Runner OS: ${{ runner.os }}"
          echo "Repository: ${{ github.repository }}"
          echo "Branch: ${{ github.ref }}"
          echo "Event: ${{ github.event_name }}"
          date
          
      # Step 3: Print environment
      - name: Print Environment
        run: |
          echo "GitHub Actions is awesome!"
          echo "This workflow was triggered by: ${{ github.actor }}"
```

**Save the file!**

---

### **Step 5: Commit and Push**

```bash
# Check status
git status
# You should see: .github/workflows/hello.yml

# Add the workflow file
git add .github/workflows/hello.yml

# Commit with a message
git commit -m "Add hello world workflow"

# Push to GitHub
git push origin main
```

---

### **Step 6: Watch It Run!**

1. Go to your GitHub repository in browser
2. Click the **"Actions"** tab at the top
3. You should see:
   - Workflow name: "Hello World Pipeline"
   - Status: Yellow (running) or Green (completed)
   - Triggered by: Your username
   - Branch: main

4. **Click on the workflow** to see details

---

### **Step 7: View Logs**

1. Click on the running/completed workflow
2. Click on the job **"say-hello"**
3. Expand each step to see output:

**Expected Output:**

```
✓ Say Hello
  Hello from GitHub Actions!

✓ Print System Info
  Runner OS: Linux
  Repository: YOUR_USERNAME/github-actions-demo
  Branch: refs/heads/main
  Event: push
  Sun Dec 15 10:30:45 UTC 2025

✓ Print Environment
  GitHub Actions is awesome!
  This workflow was triggered by: YOUR_USERNAME
```

---

## ✅ Success Criteria

You've successfully completed this exercise when:
- ✅ Workflow appears in Actions tab
- ✅ All steps show green checkmarks
- ✅ You can see the "Hello from GitHub Actions!" message
- ✅ System info displays correctly
- ✅ You understand the workflow structure

---

## 🧪 Experiment!

Now that it's working, try these modifications:

### **Experiment 1: Change the Message**

Edit `.github/workflows/hello.yml`:
```yaml
- name: Say Hello
  run: echo "Hello, I'm learning CI/CD!"
```

Commit, push, and watch it run again!

```bash
git add .github/workflows/hello.yml
git commit -m "Update greeting message"
git push origin main
```

---

### **Experiment 2: Add More Steps**

Add a new step before the last one:

```yaml
- name: List Files
  run: ls -la
```

This will show files in the runner's workspace.

---

### **Experiment 3: Run Multiple Commands**

```yaml
- name: System Information
  run: |
    echo "CPU Info:"
    nproc
    echo "Memory Info:"
    free -h
    echo "Disk Info:"
    df -h
```

---

### **Experiment 4: Use Different Runner**

Try running on Windows or macOS:

```yaml
jobs:
  say-hello:
    runs-on: windows-latest  # or macos-latest
```

---

## 🐛 Troubleshooting

### **Problem: Workflow doesn't appear in Actions tab**

**Solution:**
- Check file path is exactly: `.github/workflows/hello.yml`
- Check file extension is `.yml` not `.txt`
- Make sure you pushed to GitHub: `git push origin main`
- Refresh your browser

---

### **Problem: "Invalid workflow file"**

**Solution:**
- YAML is sensitive to indentation
- Use spaces, not tabs
- Check indentation carefully (2 spaces per level)
- Validate YAML at: https://www.yamllint.com/

---

### **Problem: Workflow failed to run**

**Solution:**
- Click on the failed workflow to see error message
- Most common: Syntax error in YAML
- Check you used `run:` for shell commands
- Ensure `runs-on:` has a valid runner

---

## 📝 Understanding the Workflow

Let's break down each part:

```yaml
name: Hello World Pipeline
```
- Human-readable name shown in GitHub UI

```yaml
on: [push]
```
- **Trigger:** When does this workflow run?
- `push` = runs on every git push to any branch
- Could also be: `pull_request`, `schedule`, `workflow_dispatch`, etc.

```yaml
jobs:
```
- Container for all jobs in this workflow
- A workflow can have multiple jobs

```yaml
  say-hello:
```
- Job ID (must be unique within workflow)
- Use lowercase with hyphens

```yaml
    runs-on: ubuntu-latest
```
- **Runner:** What operating system to use
- Options: `ubuntu-latest`, `windows-latest`, `macos-latest`
- GitHub provides these runners for free

```yaml
    steps:
```
- Container for all steps in this job
- Steps run sequentially (one after another)

```yaml
      - name: Say Hello
        run: echo "Hello from GitHub Actions!"
```
- **Step** with a name and command to run
- `name:` is optional but recommended
- `run:` executes shell commands

```yaml
        run: |
          echo "Line 1"
          echo "Line 2"
```
- `|` allows multi-line commands
- Each line runs sequentially

```yaml
${{ runner.os }}
```
- **Context variable** - accesses GitHub Actions context
- Available contexts: `github`, `runner`, `env`, `secrets`, etc.

---

## 🎓 Key Concepts Learned

### **1. Workflow Structure**
```
Workflow
  └── Event Trigger (on:)
      └── Jobs
          └── Steps
              └── Actions or Commands
```

### **2. GitHub Actions File Location**
- **Must be:** `.github/workflows/filename.yml`
- At repository root
- Can have multiple workflow files

### **3. Event Triggers**
- `push` - Code pushed to repository
- `pull_request` - PR opened or updated
- `schedule` - Cron schedule (e.g., daily)
- `workflow_dispatch` - Manual trigger

### **4. Runners**
- GitHub-hosted (free tier: 2,000 min/month)
- Self-hosted (your own servers)
- Different OS options

---

## 📚 Next Steps

1. ✅ Complete Experiment modifications
2. ✅ Try different triggers (e.g., `workflow_dispatch`)
3. ✅ Move to **Exercise 2: Node.js Testing**
4. ✅ Explore GitHub Actions Marketplace

---

## 🔗 Useful Links

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [Events That Trigger Workflows](https://docs.github.com/en/actions/reference/events-that-trigger-workflows)
- [Context and Expression Syntax](https://docs.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions)

---

## 🎉 Congratulations!

You've created your first GitHub Actions workflow! 🚀

You now understand:
- ✅ How to structure a workflow file
- ✅ Where to put workflow files
- ✅ How to trigger workflows
- ✅ How to view logs
- ✅ Basic YAML syntax

**Ready for the next challenge?** → [Exercise 2: Node.js Testing](../02-nodejs-testing/README.md)
