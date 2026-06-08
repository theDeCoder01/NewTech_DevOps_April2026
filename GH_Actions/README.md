# GitHub Actions Labs

Four hands-on labs that progressively teach GitHub Actions CI/CD — from Python testing pipelines through to Terraform infrastructure automation.

## Lab Structure

```
GH_Actions/
├── lab1/               # Calculator app — workflow already provided
│   ├── calculator.py
│   ├── test_calculator.py
│   ├── requirements.txt
│   └── README.md
├── lab2/               # String utils — you create the workflow
│   ├── string_utils.py
│   ├── test_string_utils.py
│   ├── requirements.txt
│   ├── README.md
│   └── SOLUTION.md     # Instructor solution guide
├── lab3/               # Data pipeline — you design parallel jobs
│   ├── validator.py
│   ├── test_validator.py
│   ├── transformer.py
│   ├── test_transformer.py
│   ├── reporter.py
│   ├── test_reporter.py
│   ├── requirements.txt
│   ├── README.md
│   └── SOLUTION.md     # Instructor solution guide
├── lab4/               # Terraform CI/CD — fmt, validate, checkov, plan, apply
│   ├── terraform/
│   │   ├── main.tf                  # Intentionally broken — fix it with CI
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   ├── README.md
│   └── SOLUTION.md     # Instructor solution guide
└── solutions/
    ├── lab1-solution.md   # Lab 1 workflow walkthrough (instructor reference)
    ├── lab2-solution.yml  # Lab 2 full bonus solution workflow (instructor reference)
    ├── lab3-solution.yml  # Lab 3 full bonus solution workflow (instructor reference)
    ├── lab4-single.yml    # Lab 4 single workflow with conditional apply
    ├── lab4-ci.yml        # Lab 4 CI-only workflow (split version)
    └── lab4-cd.yml        # Lab 4 CD workflow (split version)
```

The active workflow files live at the **repository root** under `.github/workflows/`:

```
.github/
└── workflows/
    └── python-tests.yml   # Lab 1 starter workflow (provided)
```

## Labs

### Lab 1 — Python Calculator

Explore a working GitHub Actions workflow that automatically runs tests on every push.

**Goal:** Understand how a CI workflow is structured — triggers, jobs, and steps.

Start here: [lab1/README.md](./lab1/README.md)

### Lab 2 — String Utils

Create your own GitHub Actions workflow from scratch.

**Goal:** Write a workflow that runs tests for the String Utils project. Use the Lab 1 workflow in `.github/workflows/python-tests.yml` as your reference.

**Bonus challenges:** matrix builds, code coverage, linting, combined jobs.

Start here: [lab2/README.md](./lab2/README.md)

### Lab 3 — Data Pipeline (Parallel Jobs)

Design a workflow where multiple jobs run **at the same time**.

**Goal:** Use parallel job execution to test three independent modules simultaneously, then fan them into a summary job. Learn why jobs without `needs:` run concurrently and how to use fan-out / fan-in patterns.

**Bonus challenges:** cross-platform matrix, `fail-fast: false`, code coverage per module, concurrent security scan.

Start here: [lab3/README.md](./lab3/README.md)

### Lab 4 — Terraform CI/CD

Write a CI/CD pipeline for infrastructure-as-code.

**Goal:** Create a single GitHub Actions workflow that runs `terraform fmt`, `terraform validate`, `checkov` security scanning, and `terraform plan` on every PR — then conditionally runs `terraform apply` only when code reaches `main`. The provided Terraform code has intentional bugs; your pipeline catches them and you fix them.

**Enhancement:** Refactor the single conditional workflow into two separate files — `terraform-ci.yml` (PR) and `terraform-cd.yml` (merge to main).

Start here: [lab4/README.md](./lab4/README.md)

## Prerequisites

- A GitHub account
- Basic Python knowledge
- Python 3.11 installed locally (for running tests before pushing)

## Running Tests Locally

```bash
# Lab 1
cd GH_Actions/lab1
python -m unittest test_calculator.py -v

# Lab 2
cd GH_Actions/lab2
python -m unittest test_string_utils.py -v

# Lab 3 (run each module separately, or all at once)
cd GH_Actions/lab3
pytest test_validator.py -v
pytest test_transformer.py -v
pytest test_reporter.py -v
# or: pytest -v

# Lab 4 (Terraform — requires AWS credentials)
cd GH_Actions/lab4/terraform
cp terraform.tfvars.example terraform.tfvars  # fill in your values
terraform init -backend-config="bucket=YOUR-STATE-BUCKET"
terraform fmt -check
terraform validate
checkov -d . --framework terraform
terraform plan -var-file=terraform.tfvars
```
