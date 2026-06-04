# Lab 2: String Utils - Create Your Own GitHub Actions Workflow

A simple string manipulation utility with tests. Your task is to create a GitHub Actions workflow from scratch!

## 📝 Project Overview

This project contains:
- `string_utils.py` - String manipulation functions
- `test_string_utils.py` - Unit tests
- `requirements.txt` - Dependencies (minimal)

## 🎯 Your Task

Create a GitHub Actions workflow that automatically runs tests when code is pushed to the repository.

## ✅ Functions Included

1. **reverse_string(text)** - Reverse a string
2. **is_palindrome(text)** - Check if text is a palindrome
3. **count_vowels(text)** - Count vowels in text
4. **capitalize_words(text)** - Capitalize first letter of each word
5. **count_words(text)** - Count words in text

## 🧪 Running Tests Locally

Test the code before creating your workflow:

```bash
# Using unittest
python -m unittest test_string_utils.py -v

# Or run the demo
python string_utils.py
```

## 🚀 Your Challenge: Create the Workflow

### Step 1: Understand the Structure

The `.github/workflows/` folder is at the **repository root**, not inside lab2!

```
Repository Root/
├── .github/
│   └── workflows/
│       └── python-tests.yml (already exists for lab1)
└── GH_Actions/
    ├── lab1/
    └── lab2/
```

You'll add a new workflow file (or modify the existing one) to also test lab2.

### Step 2: Create Your Workflow File

Option 1: Create a new workflow file in `.github/workflows/` (e.g., `lab2-tests.yml`)

Option 2: Modify the existing `python-tests.yml` to test both lab1 and lab2

Your workflow needs to:

1. **Triggers on push to main branch**
2. **Runs on Ubuntu**
3. **Uses Python 3.11**
4. **Installs dependencies**
5. **Runs the tests**

### 💡 Hints

- The `.github/workflows/` folder is at the repository root (already exists from lab1)
- Your `working-directory` should be `./GH_Actions/lab2`
- Look at the existing `python-tests.yml` in `.github/workflows/` for reference

Key things your workflow needs:
- `name:` - Give it a descriptive name
- `on:` - When should it run?
- `jobs:` - What should it do?
- `steps:` - The individual actions to perform
- `working-directory:` - Where to run the commands (`./GH_Actions/lab2`)

### ✨ Bonus Challenges

Once you have a basic workflow running:
1. Add a step to test with multiple Python versions (3.9, 3.10, 3.11)
2. Add code coverage reporting
3. Make it run on both push and pull requests
4. Add a linting step
5. Combine lab1 and lab2 tests in a single workflow with multiple jobs

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Python unittest Documentation](https://docs.python.org/3/library/unittest.html)
- Check `.github/workflows/python-tests.yml` for lab1's workflow example
- Check lab1's workflow as a reference

## ✔️ Success Criteria

Your workflow is successful when:
- ✅ It runs automatically when you push code
- ✅ All tests pass
- ✅ You can see the results in the Actions tab on GitHub

Good luck! 🎓
