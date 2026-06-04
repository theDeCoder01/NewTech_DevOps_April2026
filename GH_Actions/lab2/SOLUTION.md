# Lab 2 Solution Guide

This document provides the complete solution to Lab 2, including all bonus challenges.

## 📁 Solution Files

The complete solution workflow is provided in: `GH_Actions/solutions/lab2-solution.yml`

Copy it to `.github/workflows/lab2-solution.yml` in your repository to activate it.

## 🎯 What the Solution Includes

### Core Requirements ✅
- ✅ Triggers on push to main branch
- ✅ Runs on Ubuntu
- ✅ Uses Python (multiple versions)
- ✅ Installs dependencies
- ✅ Runs the tests

### Bonus Challenges ✅
1. ✅ **Multiple Python versions** (3.9, 3.10, 3.11) using matrix strategy
2. ✅ **Code coverage reporting** using pytest-cov
3. ✅ **Push and pull requests** - workflow triggers on both
4. ✅ **Linting step** - uses flake8 and black
5. ✅ **Combined workflow** - tests both lab1 and lab2 in separate jobs

## 🔍 Solution Breakdown

### Job Structure

The solution uses **4 jobs** that run in sequence:

```
lint (runs first)
  ↓
test-lab1 (runs after lint) + test-lab2 (runs after lint)
  ↓
summary (runs after both tests complete)
```

### 1. Lint Job

```yaml
lint:
  - Runs code quality checks
  - Uses flake8 for Python linting
  - Uses black for code formatting checks
  - Continues even if linting issues found (continue-on-error: true)
```

**Why?** Catch code quality issues before running tests.

### 2. Test Lab 1 Job

```yaml
test-lab1:
  - Uses matrix strategy for Python 3.9, 3.10, 3.11
  - Runs pytest with coverage
  - Uploads coverage report (only for Python 3.11)
  - Creates 3 parallel test runs (one per Python version)
```

**Why matrix?** Ensures code works across multiple Python versions.

### 3. Test Lab 2 Job

```yaml
test-lab2:
  - Same structure as test-lab1
  - Tests string_utils.py
  - Runs in parallel with test-lab1 (both need lint to complete)
  - Generates coverage reports
```

**Why separate jobs?** Lab1 and Lab2 are independent - they can run in parallel!

### 4. Summary Job

```yaml
summary:
  - Runs after all tests complete
  - Shows status of each test job
  - Uses `if: always()` to run even if tests fail
```

**Why?** Provides a clear summary of all test results.

## 🚀 Alternative Solutions

### Option 1: Simple Single Job (Minimum Requirements)

If you just wanted to meet the basic requirements:

```yaml
name: Lab 2 Simple Tests

on:
  push:
    branches: [ main ]

jobs:
  test-lab2:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Python 3.11
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      working-directory: './GH_Actions/lab2'
      run: |
        python -m pip install --upgrade pip
        pip install pytest
    
    - name: Run tests
      working-directory: './GH_Actions/lab2'
      run: python -m unittest test_string_utils.py -v
```

### Option 2: Modify Existing python-tests.yml

You could add lab2 testing to the existing workflow:

```yaml
# Add this job to .github/workflows/python-tests.yml
  test-lab2:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Set up Python 3.11
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install pytest
      working-directory: './GH_Actions/lab2'
    
    - name: Run tests
      run: python -m unittest test_string_utils.py -v
      working-directory: './GH_Actions/lab2'
```

## 🎓 Key Concepts Explained

### 1. Matrix Strategy

```yaml
strategy:
  matrix:
    python-version: ['3.9', '3.10', '3.11']
```

This creates **3 parallel jobs** - one for each Python version. GitHub Actions automatically runs them in parallel.

### 2. Job Dependencies

```yaml
needs: lint
```

This makes the test job wait for the lint job to complete.

### 3. Conditional Steps

```yaml
if: matrix.python-version == '3.11'
```

Only runs this step when Python version is 3.11 (avoids uploading 3 duplicate coverage reports).

### 4. Working Directory

```yaml
working-directory: './GH_Actions/lab2'
```

All commands in that step run from the lab2 folder, not the repository root.

### 5. Artifacts

```yaml
uses: actions/upload-artifact@v4
with:
  name: lab2-coverage-report
  path: ./GH_Actions/lab2/coverage.xml
```

Saves files (like coverage reports) that you can download after the workflow runs.

## 📊 Coverage Reporting

The solution uses `pytest-cov` to generate coverage reports:

```bash
pytest test_string_utils.py -v --cov=string_utils --cov-report=term-missing
```

This shows:
- Which lines of code are tested
- Which lines are NOT tested
- Overall coverage percentage

Example output:
```
---------- coverage: platform linux, python 3.11.0 -----------
Name              Stmts   Miss  Cover   Missing
-----------------------------------------------
string_utils.py      25      0   100%
-----------------------------------------------
TOTAL                25      0   100%
```

## 🧪 Testing the Solution

To test this workflow:

1. **Copy** `GH_Actions/solutions/lab2-solution.yml` → `.github/workflows/lab2-solution.yml`
2. **Commit and push** the workflow file to your repository
3. **Check the Actions tab** on GitHub
4. **View the workflow run** - you should see all 4 jobs
5. **Check the summary** - all tests should pass ✅

## 💡 What Students Should Learn

From this solution, students learn:

1. **Workflow structure** - jobs, steps, triggers
2. **Matrix builds** - testing multiple versions in parallel
3. **Job dependencies** - using `needs` to control execution order
4. **Working directories** - organizing monorepo projects
5. **Code quality** - linting and formatting
6. **Test coverage** - measuring code quality
7. **Artifacts** - saving and sharing workflow outputs
8. **Parallel execution** - independent jobs run simultaneously

## 🎯 Grading Rubric (Optional)

If you want to grade student solutions:

| Requirement | Points |
|-------------|--------|
| Workflow runs on push | 10 |
| Uses Ubuntu | 5 |
| Sets up Python | 10 |
| Installs dependencies | 10 |
| Runs tests successfully | 15 |
| **Bonus: Multiple Python versions** | +10 |
| **Bonus: Code coverage** | +10 |
| **Bonus: Push + PR triggers** | +5 |
| **Bonus: Linting** | +10 |
| **Bonus: Combined workflow** | +15 |
| **Total** | 50 (+50 bonus) |

## 🔗 Additional Resources

- [GitHub Actions Matrix Builds](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs)
- [pytest-cov Documentation](https://pytest-cov.readthedocs.io/)
- [Flake8 Documentation](https://flake8.pycqa.org/)
- [Black Code Formatter](https://black.readthedocs.io/)
