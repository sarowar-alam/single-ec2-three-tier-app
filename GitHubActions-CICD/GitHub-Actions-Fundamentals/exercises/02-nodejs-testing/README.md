# Exercise 2: Node.js Test Pipeline

**Duration:** 20 minutes  
**Difficulty:** ⭐⭐ Intermediate  
**Goal:** Create a pipeline that automatically tests a Node.js application

---

## 🎯 Objectives

- ✅ Use marketplace actions (actions/checkout, actions/setup-node)
- ✅ Set up Node.js environment in GitHub Actions
- ✅ Install dependencies automatically
- ✅ Run automated tests
- ✅ Understand test automation benefits

---

## 📋 What We're Building

A simple calculator app with:
- 4 functions: add, subtract, multiply, divide
- 5 unit tests using Jest
- Automated testing on every push

---

## 🚀 Instructions

### **Step 1: Copy Files to Your Repository**

Copy these files to your `github-actions-demo` repository:

```
github-actions-demo/
├── calculator.js
├── calculator.test.js
├── package.json
└── .github/workflows/test.yml
```

### **Step 2: Install Dependencies Locally (Optional)**

```bash
# In your repository folder
npm install

# Run tests locally
npm test
```

You should see:
```
PASS  ./calculator.test.js
  ✓ adds 1 + 2 to equal 3
  ✓ subtracts 5 - 2 to equal 3
  ✓ multiplies 3 * 4 to equal 12
  ✓ divides 10 / 2 to equal 5
  ✓ throws error when dividing by zero

Test Suites: 1 passed, 1 total
Tests:       5 passed, 5 total
```

### **Step 3: Push to GitHub**

```bash
git add .
git commit -m "Add calculator with automated tests"
git push origin main
```

### **Step 4: Watch Tests Run**

1. Go to GitHub Actions tab
2. See "Run Tests" workflow executing
3. Watch each step complete
4. All tests should pass!

---

## 🧪 Experiment: Intentional Test Failure

### **Make a Test Fail**

Edit `calculator.test.js`:
```javascript
test('adds 1 + 2 to equal 3', () => {
  expect(add(1, 2)).toBe(4);  // Changed from 3 to 4 (wrong!)
});
```

Push and watch it fail:
```bash
git add calculator.test.js
git commit -m "Break test intentionally"
git push origin main
```

You'll see a red ❌ in GitHub Actions!

### **Fix It**

Change it back to `toBe(3)` and push again.

---

## ✅ Success Criteria

- ✅ Workflow runs on push
- ✅ Node.js 18 is set up
- ✅ Dependencies install successfully
- ✅ All 5 tests pass
- ✅ You understand CI/CD testing benefits

---

**Next:** [Exercise 3: Multi-Job Pipeline](../03-multi-job-pipeline/README.md)
