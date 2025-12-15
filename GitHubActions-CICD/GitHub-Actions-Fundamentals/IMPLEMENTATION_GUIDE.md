# Session 1: GitHub Actions Fundamentals - Implementation Guide

**Duration:** 90 minutes  
**Level:** Beginner to Intermediate  
**Prerequisites:** GitHub account, Git basics, text editor

---

## 📋 Table of Contents

1. [Pre-Session Setup](#pre-session-setup)
2. [Exercise 1: Hello World Workflow](#exercise-1-hello-world-workflow-20-min)
3. [Exercise 2: Node.js Testing Pipeline](#exercise-2-nodejs-testing-pipeline-20-min)
4. [Exercise 3: Multi-Job Pipeline](#exercise-3-multi-job-pipeline-20-min)
5. [Troubleshooting](#troubleshooting)
6. [Validation Checklist](#validation-checklist)

---

## 🚀 Pre-Session Setup

### Step 1: Setup SSH for GitHub (Required for Private Repos)

**Why SSH?** SSH keys provide secure authentication without passwords, essential for private repositories.

#### 1.1: Generate SSH Key Pair

```bash
# Check if you already have SSH keys
ls -la ~/.ssh
# Look for: id_rsa and id_rsa.pub (or id_ed25519 and id_ed25519.pub)

# If no keys exist, generate new SSH key pair
ssh-keygen -t ed25519 -C "your_email@example.com"
# Press Enter to accept default location (~/.ssh/id_ed25519)
# Enter passphrase (optional but recommended)

# Alternative for older systems (use RSA)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

#### 1.2: Add SSH Key to SSH Agent

```bash
# Start SSH agent in background
eval "$(ssh-agent -s)"

# Add your SSH private key to the agent
ssh-add ~/.ssh/id_ed25519
# Or for RSA: ssh-add ~/.ssh/id_rsa

# Verify key is added
ssh-add -l
```

#### 1.3: Copy SSH Public Key

```bash
# Display your public key
cat ~/.ssh/id_ed25519.pub
# Or for RSA: cat ~/.ssh/id_rsa.pub

# Copy the entire output (starts with ssh-ed25519 or ssh-rsa)
```

**On Windows (PowerShell):**
```powershell
# Copy to clipboard directly
Get-Content ~/.ssh/id_ed25519.pub | Set-Clipboard
```

#### 1.4: Add SSH Key to GitHub

1. Go to GitHub.com → **Settings** (click your profile picture)
2. Click **SSH and GPG keys** in left sidebar
3. Click **New SSH key** button
4. **Title:** Give it a name (e.g., "My Laptop" or "Work PC")
5. **Key type:** Authentication Key
6. **Key:** Paste your public key (from step 1.3)
7. Click **Add SSH key**
8. Confirm with your GitHub password if prompted

#### 1.5: Test SSH Connection

```bash
# Test connection to GitHub
ssh -T git@github.com

# Expected output:
# Hi YOUR_USERNAME! You've successfully authenticated, but GitHub does not provide shell access.
```

**If you see an error:**
```bash
# Add GitHub to known hosts
ssh-keyscan github.com >> ~/.ssh/known_hosts

# Try again
ssh -T git@github.com
```

---

### Step 2: Create GitHub Repository

```bash
# 1. Go to GitHub.com and create a new repository
# Name: github-actions-practice
# Visibility: Public or Private (SSH works for both!)
# Initialize: Add README

# 2. Clone the repository using SSH
git clone git@github.com:YOUR_USERNAME/github-actions-practice.git
# Example: git clone git@github.com:sarowar-alam/github-actions-practice.git

cd github-actions-practice

# 3. Verify Git configuration
git config user.name
git config user.email

# If not set, configure them:
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```

**Alternative: Convert Existing HTTPS Clone to SSH**
```bash
# If you already cloned with HTTPS, switch to SSH
cd github-actions-practice
git remote set-url origin git@github.com:YOUR_USERNAME/github-actions-practice.git

# Verify the change
git remote -v
# Should show: git@github.com:YOUR_USERNAME/github-actions-practice.git
```

---

### Step 3: Verify GitHub Actions is Enabled

1. Go to your repository on GitHub
2. Click **Settings** → **Actions** → **General**
3. Ensure "Allow all actions and reusable workflows" is selected
4. Save changes

---

### Step 4: Set Up Local Environment

```bash
# Install Node.js (if not already installed)
# Download from: https://nodejs.org/ (LTS version)

# Verify installation
node --version  # Should show v18.x or higher
npm --version   # Should show v9.x or higher
```

---

## 🎯 Exercise 1: Hello World Workflow (20 min)

**Goal:** Create your first GitHub Actions workflow

### Step 1: Create Workflow Directory

```bash
# Create .github/workflows directory
mkdir -p .github/workflows
```

### Step 2: Create Hello World Workflow

Create file: `.github/workflows/hello-world.yml`

```yaml
name: Hello World Workflow

# Trigger on push to any branch
on:
  push:
    branches:
      - '*'
  pull_request:
    branches:
      - '*'

jobs:
  greet:
    # Run on Ubuntu latest
    runs-on: ubuntu-latest
    
    steps:
      # Step 1: Print greeting
      - name: Say Hello
        run: echo "Hello, GitHub Actions!"
      
      # Step 2: Show date and time
      - name: Show Timestamp
        run: date
      
      # Step 3: Display runner info
      - name: Show Runner Info
        run: |
          echo "Runner OS: $RUNNER_OS"
          echo "Runner Name: $RUNNER_NAME"
          echo "Workflow: $GITHUB_WORKFLOW"
```

### Step 3: Commit and Push

```bash
# Add the workflow file
git add .github/workflows/hello-world.yml

# Commit with descriptive message
git commit -m "Add Hello World workflow"

# Push to GitHub
git push origin main
```

### Step 4: Verify Workflow Execution

1. Go to your repository on GitHub
2. Click **Actions** tab
3. You should see "Hello World Workflow" running
4. Click on the workflow run
5. Click on "greet" job
6. Expand each step to see output

**Expected Output:**
- ✅ "Say Hello" step shows: `Hello, GitHub Actions!`
- ✅ "Show Timestamp" shows current date/time
- ✅ "Show Runner Info" displays system information

### Step 5: Test Manual Trigger

Modify the workflow to add manual trigger:

```yaml
on:
  push:
    branches:
      - '*'
  pull_request:
    branches:
      - '*'
  workflow_dispatch:  # Add this line
```

Commit and push:
```bash
git add .github/workflows/hello-world.yml
git commit -m "Add manual trigger to workflow"
git push origin main
```

Test manual run:
1. Go to **Actions** tab
2. Click "Hello World Workflow"
3. Click **Run workflow** button
4. Select branch and click **Run workflow**

---

## 🧪 Exercise 2: Node.js Testing Pipeline (20 min)

**Goal:** Automate testing for a Node.js project

---

### 📖 What's Happening in This Exercise?

**The Big Picture:**  
You're creating an automated testing system that runs **every time you push code** to GitHub. Instead of manually running `npm test` on your laptop, GitHub Actions does it automatically in the cloud—testing your code on multiple Node.js versions simultaneously.

**Real-World Scenario:**  
Imagine you're working on a team project. You write some code, push it to GitHub, and before your teammate reviews it, the CI pipeline:
1. ✅ Automatically downloads your code
2. ✅ Installs all dependencies
3. ✅ Runs all tests on Node.js 18 and 20
4. ✅ Reports pass/fail within seconds
5. ✅ Prevents broken code from being merged

**What You're Building:**

```
Your Code Push
      ↓
GitHub detects push
      ↓
Triggers GitHub Actions Workflow
      ↓
┌─────────────────────────────────────┐
│  Cloud Runner (Ubuntu VM)           │
│  ┌─────────────┐  ┌─────────────┐  │
│  │  Node 18.x  │  │  Node 20.x  │  │
│  │  Run Tests  │  │  Run Tests  │  │
│  │     ✓ 5/5   │  │     ✓ 5/5   │  │
│  └─────────────┘  └─────────────┘  │
└─────────────────────────────────────┘
      ↓
✅ All Tests Passed! (or ❌ Tests Failed!)
      ↓
Green checkmark appears on your commit
```

**Key Concepts You'll Learn:**

1. **Continuous Integration (CI):** Automatically test code changes
2. **Matrix Strategy:** Test on multiple Node.js versions simultaneously
3. **Dependency Caching:** Speed up builds by caching `node_modules`
4. **npm ci vs npm install:** Reproducible builds with lock files
5. **Artifacts & Outputs:** See test results in GitHub Actions logs

**The Flow Step-by-Step:**

| Step | What You Do | What Happens |
|------|-------------|--------------|
| 1-6  | Create calculator code + tests locally | You write the code that needs testing |
| 7    | Create `.github/workflows/nodejs-test.yml` | Define automation rules |
| 8    | Push to GitHub | Trigger the magic! |
| 9    | Watch Actions tab | See tests run automatically in the cloud |

**After This Exercise:**  
Every push to GitHub will automatically run your tests. No manual work. No "it works on my machine" problems. Just automated quality checks!

---

### Step 1: Create Project Structure

```bash
# Navigate to your repository root
cd github-actions-practice

# Initialize Node.js project in the root directory
npm init -y

# This creates package.json in the root
# Note: We're NOT creating a subdirectory - keep files in root for GitHub Actions
```

### Step 2: Install Testing Framework

```bash
# Install Jest for testing
npm install --save-dev jest

# This creates package-lock.json automatically
# IMPORTANT: package-lock.json is required for GitHub Actions caching

# Verify installation
npm list jest

# Verify package-lock.json was created
ls -la package-lock.json
```

### Step 3: Create Calculator Module

Create file: `calculator.js`

```javascript
// calculator.js - Simple calculator functions

function add(a, b) {
  return a + b;
}

function subtract(a, b) {
  return a - b;
}

function multiply(a, b) {
  return a * b;
}

function divide(a, b) {
  if (b === 0) {
    throw new Error('Cannot divide by zero');
  }
  return a / b;
}

module.exports = { add, subtract, multiply, divide };
```

### Step 4: Create Test File

Create file: `calculator.test.js`

```javascript
// calculator.test.js - Tests for calculator functions

const { add, subtract, multiply, divide } = require('./calculator');

describe('Calculator Functions', () => {
  
  test('adds 2 + 3 to equal 5', () => {
    expect(add(2, 3)).toBe(5);
  });

  test('subtracts 5 - 3 to equal 2', () => {
    expect(subtract(5, 3)).toBe(2);
  });

  test('multiplies 4 * 5 to equal 20', () => {
    expect(multiply(4, 5)).toBe(20);
  });

  test('divides 10 / 2 to equal 5', () => {
    expect(divide(10, 2)).toBe(5);
  });

  test('throws error when dividing by zero', () => {
    expect(() => divide(10, 0)).toThrow('Cannot divide by zero');
  });
  
});
```

### Step 5: Update package.json

Add test script to `package.json`:

```json
{
  "name": "nodejs-testing-demo",
  "version": "1.0.0",
  "description": "GitHub Actions testing demo",
  "main": "calculator.js",
  "scripts": {
    "test": "jest"
  },
  "devDependencies": {
    "jest": "^29.7.0"
  }
}
```

### Step 6: Test Locally

```bash
# Run tests locally
npm test

# Expected output:
# PASS  calculator.test.js
#   Calculator Functions
#     ✓ adds 2 + 3 to equal 5
#     ✓ subtracts 5 - 3 to equal 2
#     ✓ multiplies 4 * 5 to equal 20
#     ✓ divides 10 / 2 to equal 5
#     ✓ throws error when dividing by zero
#
# Test Suites: 1 passed, 1 total
# Tests:       5 passed, 5 total
```

### Step 7: Create CI Workflow

Create file: `.github/workflows/nodejs-test.yml`

**Important:** Make sure your project structure looks like this:
```
github-actions-practice/
├── .github/
│   └── workflows/
│       ├── hello-world.yml
│       └── nodejs-test.yml      ← New file
├── calculator.js                 ← In root directory
├── calculator.test.js            ← In root directory
├── package.json                  ← In root directory
├── package-lock.json            ← In root directory (must be committed!)
└── README.md
```

**Workflow content:**

```yaml
name: Node.js CI Testing

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [18.x, 20.x]
    
    steps:
      # Step 1: Checkout code
      - name: Checkout Repository
        uses: actions/checkout@v4
      
      # Step 2: Setup Node.js
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      
      # Step 3: Install dependencies
      - name: Install Dependencies
        run: npm ci
      
      # Step 4: Run tests
      - name: Run Tests
        run: npm test
      
      # Step 5: Display test results
      - name: Test Summary
        if: always()
        run: echo "Tests completed for Node.js ${{ matrix.node-version }}"
```

### Step 8: Clean Up and Commit

```bash
# If you accidentally created nodejs-testing-demo subdirectory, remove it
rm -rf nodejs-testing-demo

# Add all files (including package-lock.json!)
git add .

# Verify package-lock.json is included and no subdirectory exists
git status
# Should show: calculator.js, calculator.test.js, package.json, package-lock.json
# Should NOT show: nodejs-testing-demo/

# Commit
git commit -m "Add Node.js testing pipeline"

# Push
git push origin main
```

**Note:** If you see duplicate test results (tests running from both root and subdirectory), clean up the subdirectory:
```bash
rm -rf nodejs-testing-demo
git add .
git commit -m "Remove duplicate subdirectory"
git push origin main
```

### Step 9: Verify CI Pipeline

1. Go to **Actions** tab on GitHub
2. Check "Node.js CI Testing" workflow
3. Verify tests run on both Node.js 18.x and 20.x
4. Confirm all 5 tests pass

**Expected Results:**
- ✅ 2 jobs run (Node.js 18.x and 20.x)
- ✅ All tests pass in both versions
- ✅ Green checkmark on workflow

**Detailed Success Indicators:**

**1. Workflow Summary:**
```
✓ test (18.x) completed in 12s
✓ test (20.x) completed in 14s
```

**2. Test Output (each job shows):**
```
Run npm test

PASS ./calculator.test.js
  Calculator Functions
    ✓ adds 2 + 3 to equal 5 (2 ms)
    ✓ subtracts 5 - 3 to equal 2 (1 ms)
    ✓ multiplies 4 * 5 to equal 20
    ✓ divides 10 / 2 to equal 5
    ✓ throws error when dividing by zero (1 ms)

Test Suites: 1 passed, 1 total
Tests:       5 passed, 5 total
Snapshots:   0 total
Time:        0.541 s
```

**3. Cache Performance:**
```
Cache restored successfully
Cache Size: ~2-5 MB
Cache saved successfully
```

**4. Full Workflow Steps (each job):**
```
✓ Checkout Repository       (1s)
✓ Setup Node.js 18.x/20.x   (1s)
✓ Install Dependencies       (5s)
✓ Run Tests                  (2s)
✓ Test Summary              (1s)
✓ Post Setup Node.js        (1s)
✓ Complete job              (1s)
```

**5. Final Validation Checklist:**
- [ ] Workflow badge shows passing (green)
- [ ] Both Node.js versions tested successfully
- [ ] No errors in any step
- [ ] All 5 calculator tests pass
- [ ] Cache is working (faster subsequent runs)
- [ ] Test output is clean (no warnings)
- [ ] Commit shows green checkmark on GitHub

**6. What You've Accomplished:**
- ✅ Set up automated testing with GitHub Actions
- ✅ Configured multi-version testing (Node.js 18.x, 20.x)
- ✅ Implemented dependency caching for faster builds
- ✅ Created a maintainable test suite
- ✅ Established CI pipeline that runs on every push

**Next:** If all checks pass, you're ready for Exercise 3! If you see any warnings about duplicate tests, ensure you've completed the cleanup step (Step 8).

---

## 🔄 Exercise 3: Multi-Job Pipeline (20 min)

**Goal:** Create a pipeline with multiple dependent jobs

### Step 1: Create Advanced Workflow

Create file: `.github/workflows/multi-job-pipeline.yml`

```yaml
name: Multi-Job Pipeline

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  # Job 1: Lint and validate code
  lint:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20.x'
      
      - name: Install Dependencies
        run: npm ci
      
      - name: Lint Check
        run: echo "✅ Linting passed (simulated)"

  # Job 2: Run tests (depends on lint)
  test:
    needs: lint
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [18.x, 20.x]
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      
      - name: Install Dependencies
        run: npm ci
      
      - name: Run Unit Tests
        run: npm test

  # Job 3: Build application (depends on test)
  build:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20.x'
      
      - name: Install Dependencies
        run: npm ci
      
      - name: Build Application
        run: echo "🔨 Building application..."
      
      - name: Create Build Artifact
        run: |
          mkdir -p dist
          cp calculator.js dist/
          echo "Build completed at $(date)" > dist/build-info.txt
      
      - name: Upload Build Artifact
        uses: actions/upload-artifact@v4
        with:
          name: build-artifact
          path: dist/
          retention-days: 7

  # Job 4: Security scan (runs in parallel with test)
  security:
    needs: lint
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Run Security Scan
        run: echo "🔒 Security scan passed (simulated)"

  # Job 5: Deploy (depends on both build and security)
  deploy:
    needs: [build, security]
    runs-on: ubuntu-latest
    
    steps:
      - name: Download Build Artifact
        uses: actions/download-artifact@v4
        with:
          name: build-artifact
      
      - name: Display Artifact Contents
        run: |
          echo "📦 Artifact contents:"
          ls -la
          cat build-info.txt
      
      - name: Deploy to Production
        run: echo "🚀 Deployed successfully (simulated)"
```

### Step 2: Commit and Push

```bash
git add .github/workflows/multi-job-pipeline.yml
git commit -m "Add multi-job pipeline"
git push origin main
```

### Step 3: Verify Pipeline Execution

1. Go to **Actions** tab
2. Click "Multi-Job Pipeline"
3. Observe the job dependency graph

**Expected Execution Order:**
```
1. lint (runs first)
   ↓
2. test + security (run in parallel after lint)
   ↓
3. build (runs after test completes)
   ↓
4. deploy (runs after both build and security complete)
```

### Step 4: Download and Verify Artifact

1. Click on the completed workflow run
2. Scroll down to **Artifacts** section
3. Download "build-artifact"
4. Extract and verify contents:
   - `calculator.js` file
   - `build-info.txt` with timestamp

---

## 🔐 Bonus: Working with Secrets

### Step 1: Add Repository Secret

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Name: `API_KEY`
4. Value: `test-secret-key-12345`
5. Click **Add secret**

### Step 2: Create Workflow Using Secret

Create file: `.github/workflows/secrets-demo.yml`

```yaml
name: Secrets Demo

on:
  workflow_dispatch:

jobs:
  use-secrets:
    runs-on: ubuntu-latest
    
    steps:
      - name: Use Secret
        env:
          MY_API_KEY: ${{ secrets.API_KEY }}
        run: |
          echo "Secret length: ${#MY_API_KEY}"
          echo "Secret starts with: ${MY_API_KEY:0:4}"
          # Never echo the full secret!
      
      - name: Verify Secret Exists
        if: secrets.API_KEY != ''
        run: echo "✅ Secret configured correctly"
```

### Step 3: Test Secret Usage

```bash
git add .github/workflows/secrets-demo.yml
git commit -m "Add secrets demo"
git push origin main
```

Run manually and verify secret is accessible but masked in logs.

---

## 🐛 Troubleshooting

### Issue 1: Dependencies Lock File Not Found

**Problem:** Error message: `Dependencies lock file is not found... Supported file patterns: package-lock.json`

**Cause:** The workflow uses `cache: 'npm'` but `package-lock.json` is missing

**Solutions:**

**Option 1: Generate and commit package-lock.json (Recommended)**
```bash
# Generate lock file
npm install

# Verify it was created
ls -la package-lock.json

# Add and commit it
git add package-lock.json
git commit -m "Add package-lock.json for CI caching"
git push origin main
```

**Option 2: Remove cache from workflow**
```yaml
# In .github/workflows/nodejs-test.yml
# Remove or comment out the cache line:
- name: Setup Node.js ${{ matrix.node-version }}
  uses: actions/setup-node@v4
  with:
    node-version: ${{ matrix.node-version }}
    # cache: 'npm'  # Comment this out
```

**Option 3: Use npm install instead of npm ci**
```yaml
# Change this:
- name: Install Dependencies
  run: npm ci

# To this:
- name: Install Dependencies
  run: npm install
```

**Why this happens:**
- `npm ci` requires `package-lock.json` for reproducible builds
- GitHub Actions cache feature needs lock file to determine cache key
- If you used `npm install` locally without committing the lock file, CI will fail

---

### Issue 2: Workflow Not Triggering

**Problem:** Workflow doesn't run after push

**Solutions:**
```bash
# Check if .github/workflows directory exists
ls -la .github/workflows/

# Verify file extension is .yml or .yaml
ls .github/workflows/*.yml

# Check workflow syntax at https://www.yamllint.com/

# Ensure you pushed to the correct branch
git branch --show-current
```

### Issue 3: package.json and package-lock.json Out of Sync

**Problem:** Error: `npm ci can only install packages when your package.json and package-lock.json are in sync`

**Example Error:**
```
Invalid: lock file's jest@30.2.0 does not satisfy jest@29.7.0
```

**Cause:** Version mismatch between package.json and package-lock.json

**Solution (Run locally):**
```bash
# Navigate to your repository
cd github-actions-practice

# Delete the out-of-sync lock file
rm package-lock.json

# Regenerate lock file based on package.json
npm install

# Verify versions match
cat package.json | grep jest
cat package-lock.json | grep '"version"' | head -5

# Commit the new lock file
git add package-lock.json
git commit -m "Fix: Regenerate package-lock.json to match package.json"
git push origin main
```

**Why this happens:**
- You ran `npm install` which upgraded Jest to 30.x
- But package.json still specifies 29.x
- `npm ci` requires exact version match for reproducible builds

---

### Issue 4: npm ci Fails (General)

**Problem:** `npm ci` command fails in workflow

**Solutions:**
```yaml
# Solution 1: Use npm install instead
- name: Install Dependencies
  run: npm install

# Solution 2: Regenerate lock file in CI
- name: Install Dependencies
  run: |
    rm -f package-lock.json
    npm install

# Solution 3: Use exact npm version
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '20.x'
- name: Install Dependencies
  run: |
    npm ci --legacy-peer-deps
```

### Issue 5: Tests Fail in CI but Pass Locally

**Problem:** Tests pass locally but fail in GitHub Actions

**Solutions:**
```yaml
# Add debugging to see environment differences
- name: Debug Environment
  run: |
    node --version
    npm --version
    pwd
    ls -la

# Use exact Node.js version as local
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '18.17.0'  # Specific version
```

### Issue 6: Permission Denied

**Problem:** Workflow fails with permission errors

**Solutions:**
```yaml
# Add permissions at workflow level
permissions:
  contents: read
  actions: write

# Or at job level
jobs:
  test:
    permissions:
      contents: read
    runs-on: ubuntu-latest
```

### Issue 7: Workflow Runs Too Long

**Problem:** Workflow exceeds time limits

**Solutions:**
```yaml
# Add timeout to jobs
jobs:
  test:
    timeout-minutes: 10
    runs-on: ubuntu-latest

# Add timeout to steps
steps:
  - name: Run Tests
    timeout-minutes: 5
    run: npm test
```

---

## ✅ Validation Checklist

### After Exercise 1:
- [ ] Hello World workflow created
- [ ] Workflow triggers on push
- [ ] Manual trigger works
- [ ] All steps show green checkmarks
- [ ] Logs display expected output

### After Exercise 2:
- [ ] Node.js project initialized
- [ ] Tests run locally and pass
- [ ] CI workflow created
- [ ] Tests run on multiple Node.js versions
- [ ] All 5 calculator tests pass in CI

### After Exercise 3:
- [ ] Multi-job pipeline created
- [ ] Jobs execute in correct order
- [ ] Dependency graph displays correctly
- [ ] Build artifact uploaded successfully
- [ ] Artifact can be downloaded and verified

### After Secrets Demo:
- [ ] Repository secret created
- [ ] Secret accessible in workflow
- [ ] Secret value masked in logs
- [ ] Workflow confirms secret exists

### Overall Session 1 Completion:
- [ ] Understand CI/CD concepts
- [ ] Can write YAML workflows
- [ ] Know how to use actions from marketplace
- [ ] Can debug workflow failures
- [ ] Comfortable with jobs and steps
- [ ] Understand secrets management
- [ ] Ready for Session 2 deployment automation

---

## 📚 Next Steps

**Before Session 2:**
1. Complete the homework assignment
2. Ensure BMI app is deployed manually on EC2
3. Prepare SSH access to EC2 instance
4. Review [Automate-BMI-Deployment](../Automate-BMI-Deployment/) folder

**Additional Practice:**
- Add more tests to calculator
- Create workflows for different programming languages
- Experiment with different triggers (schedule, tags)
- Explore GitHub Marketplace for useful actions

---

## 🔗 Helpful Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [YAML Validator](https://www.yamllint.com/)
- [Jest Testing Framework](https://jestjs.io/)

---

**Session 1 Complete! 🎉**  
You're now ready to automate real application deployments in Session 2.
