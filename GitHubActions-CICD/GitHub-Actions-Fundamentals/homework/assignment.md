# Session 1: Homework Assignment

**Due:** Before Session 2  
**Estimated Time:** 2-3 hours  
**Points:** 100

---

## 📝 Assignment Overview

Complete the following tasks to solidify your understanding of GitHub Actions fundamentals.

---

## Task 1: Complete All Session Exercises (30 points)

If you didn't finish during the session, complete:
- ✅ Exercise 1: Hello World Workflow
- ✅ Exercise 2: Node.js Test Pipeline
- ✅ Exercise 3: Multi-Job Pipeline

**Deliverable:** Screenshot of all 3 workflows with green checkmarks

---

## Task 2: Create Comprehensive Test Pipeline (40 points)

Create a new workflow: `.github/workflows/complete-pipeline.yml`

**Requirements:**
1. Triggers on push to main branch
2. Runs on Ubuntu latest
3. Checks out code
4. Sets up Node.js 18
5. Caches npm dependencies
6. Runs `npm install`
7. Runs `npm test`
8. Only builds if tests pass (use `needs`)
9. Uploads build artifacts

**Starter Template:**
```yaml
name: Complete Pipeline

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      # Add steps here
      
  build:
    runs-on: ubuntu-latest
    needs: test  # Only run if test passes
    steps:
      # Add build steps here
```

**Deliverable:** Working workflow with artifacts uploaded

---

## Task 3: Add Status Badge (10 points)

Add a GitHub Actions status badge to your README.md:

```markdown
![CI](https://github.com/YOUR_USERNAME/github-actions-demo/workflows/Run%20Tests/badge.svg)
```

**Deliverable:** README with working badge showing status

---

## Task 4: Experiment with Triggers (20 points)

Create a workflow that:
1. Runs on schedule (daily at midnight UTC)
2. Can be manually triggered
3. Runs on pull requests

**File:** `.github/workflows/scheduled.yml`

```yaml
name: Scheduled Check

on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight UTC
  workflow_dispatch:      # Manual trigger
  pull_request:

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Check
        run: echo "Scheduled check complete!"
```

**Deliverable:** Workflow file + screenshot of manual run

---

## Bonus Task: Explore Marketplace (10 bonus points)

Find and use an interesting action from GitHub Marketplace:

Ideas:
- Send a Slack notification
- Create a GitHub issue
- Post a comment on PR
- Upload to AWS S3

**Deliverable:** Workflow using marketplace action + explanation

---

## 📤 Submission

1. Ensure all workflows are in your GitHub repository
2. Take screenshots showing:
   - All workflows with green checkmarks
   - Artifacts uploaded successfully
   - Status badge in README
3. Submit repository URL + screenshots

---

## ✅ Grading Rubric

| Task | Points | Criteria |
|------|--------|----------|
| Task 1 | 30 | All 3 exercises complete and working |
| Task 2 | 40 | Pipeline works, tests before build, artifacts uploaded |
| Task 3 | 10 | Badge displays correctly |
| Task 4 | 20 | All triggers working |
| Bonus | 10 | Creative marketplace action use |

**Total:** 100 points (+ 10 bonus)

---

## 🆘 Getting Help

- Review exercise README files
- Check GitHub Actions documentation
- Post questions in course forum
- Office hours: [Time/Day]

---

Good luck! See you in Session 2! 🚀
