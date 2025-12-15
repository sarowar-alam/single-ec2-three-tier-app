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

### Step 1: Create GitHub Repository

```bash
# 1. Go to GitHub.com and create a new repository
# Name: github-actions-practice
# Visibility: Public
# Initialize: Add README

# 2. Clone the repository
git clone https://github.com/YOUR_USERNAME/github-actions-practice.git
cd github-actions-practice

# 3. Verify Git configuration
git config user.name
git config user.email
```

### Step 2: Verify GitHub Actions is Enabled

1. Go to your repository on GitHub
2. Click **Settings** → **Actions** → **General**
3. Ensure "Allow all actions and reusable workflows" is selected
4. Save changes

### Step 3: Set Up Local Environment

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

### Step 1: Create Project Structure

```bash
# Create project directory
mkdir nodejs-testing-demo
cd nodejs-testing-demo

# Initialize Node.js project
npm init -y
```

### Step 2: Install Testing Framework

```bash
# Install Jest for testing
npm install --save-dev jest

# Verify installation
npm list jest
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

### Step 8: Commit and Push

```bash
# Add all files
git add .

# Commit
git commit -m "Add Node.js testing pipeline"

# Push
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

### Issue 1: Workflow Not Triggering

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

### Issue 2: npm ci Fails

**Problem:** `npm ci` command fails in workflow

**Solutions:**
```yaml
# Use npm install instead
- name: Install Dependencies
  run: npm install

# Or delete package-lock.json and regenerate
- name: Install Dependencies
  run: |
    rm -f package-lock.json
    npm install
```

### Issue 3: Tests Fail in CI but Pass Locally

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

### Issue 4: Permission Denied

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

### Issue 5: Workflow Runs Too Long

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
