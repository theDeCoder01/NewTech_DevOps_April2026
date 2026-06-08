# Lab 4: CI/CD for Terraform

Write a GitHub Actions workflow that automatically validates, scans, plans, and applies Terraform infrastructure — and learns to tell the difference between what should happen on a **PR** versus on a **merge to main**.

---

## 🎯 What You'll Build

A single GitHub Actions workflow file that runs a Terraform quality gate:

```
Every push / PR                     Only on merge to main
──────────────                      ─────────────────────
terraform fmt -check                (all of the left) +
terraform validate                  terraform apply
checkov security scan               terraform output
terraform plan
```

The twist: **the provided Terraform code has bugs**. Your CI pipeline will catch them. Fix each one and watch the pipeline go green — that's the whole point.

---

## 📁 Lab Structure

```
lab4/
├── terraform/
│   ├── main.tf                    # PROVIDED — has intentional issues
│   ├── variables.tf               # PROVIDED
│   ├── outputs.tf                 # PROVIDED
│   └── terraform.tfvars.example   # PROVIDED — copy and fill in locally
├── README.md                      # This file
└── SOLUTION.md                    # Instructor reference
```

The workflow file you create goes at the **repository root**:

```
.github/workflows/
└── terraform.yml    ← YOU CREATE THIS
```

---

## ☁️ Prerequisites

You need an AWS account and two S3 buckets before you start.

### 1. Create a Terraform state bucket (one-time)

This bucket stores Terraform's state file between CI runs.

```bash
# Replace YOUR-NAME with your actual name
aws s3 mb s3://YOUR-NAME-tf-state --region us-east-1
aws s3api put-bucket-versioning \
  --bucket YOUR-NAME-tf-state \
  --versioning-configuration Status=Enabled
```

### 2. Add GitHub Secrets

In your repository go to **Settings → Secrets and variables → Actions** and add:

| Secret | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | Your AWS access key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key |
| `TF_STATE_BUCKET` | The state bucket name you just created |
| `TF_BUCKET_NAME` | A globally unique name for the app bucket the lab will create (e.g. `alice-lab4-a3f9`) |

---

## 🧪 Running Terraform Locally First

Before writing the workflow, make sure you can run Terraform locally.

```bash
cd GH_Actions/lab4/terraform

# Copy and fill in the example vars file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Initialise — notice the -backend-config flag
terraform init -backend-config="bucket=YOUR-STATE-BUCKET-NAME"

# Check formatting
terraform fmt -check

# Validate syntax
terraform validate

# Preview changes
terraform plan -var-file=terraform.tfvars

# Apply (creates the S3 bucket in AWS)
terraform apply -var-file=terraform.tfvars

# When done
terraform destroy -var-file=terraform.tfvars
```

---

## 🔍 What's Wrong with the Terraform Code?

Run the pipeline and let CI tell you. Your job is to:

1. Write the workflow
2. Push a branch and open a PR
3. Read the CI output carefully
4. Fix each issue in `main.tf`
5. Repeat until the pipeline is fully green

There are **three categories of issues** — one caught by each stage of your pipeline.

---

## 🚀 Your Challenge: Write the Workflow

### Step 1 — Understand the pipeline stages

| Stage | Command | What it catches |
|---|---|---|
| Format check | `terraform fmt -check` | Code not formatted to Terraform's standard |
| Validate | `terraform validate` | Syntax and configuration errors |
| Security scan | `checkov -d . --framework terraform` | Misconfigurations and insecure defaults |
| Plan | `terraform plan -out=tfplan` | Shows exactly what AWS resources will change |
| Apply | `terraform apply tfplan` | Creates / updates / destroys real resources |
| Output | `terraform output` | Verifies the deployment produced the expected values |

### Step 2 — Create `.github/workflows/terraform.yml`

Your workflow must:

1. **Trigger** on `push` to `main` AND on `pull_request` to `main`
2. **Set up** AWS credentials using environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
3. **Install** Terraform (use `hashicorp/setup-terraform@v3`)
4. **Run `terraform init`** — pass the state bucket via `-backend-config`
5. **Run `terraform fmt -check`** — fail the job if code is not formatted
6. **Run `terraform validate`**
7. **Install and run `checkov`** — fail the job if security issues are found
8. **Run `terraform plan`** — save the plan to a file with `-out=tfplan`
9. **Run `terraform apply`** — **only when the trigger is a push to `main`** (not on PRs)
10. **Run `terraform output`** — only after a successful apply

### Step 3 — The conditional apply

The most important concept in this lab. Use an `if:` condition to control when apply runs:

```yaml
- name: Terraform Apply
  if: ???    # Fill this in — when should apply run?
  run: terraform apply -auto-approve tfplan
```

Hint: `github.ref` and `github.event_name` are the two expressions you need.

### Step 4 — Fix the Terraform code

Once your workflow is running, read the CI output and fix the issues in `main.tf`.  
Commit the fixes, push, and watch the pipeline go green.

### Step 5 — Verify the deployment

After merging to `main`:
- Check the GitHub Actions logs to confirm apply ran
- Go to the AWS console → S3 and find your new bucket
- Verify the bucket has the correct configuration (versioning, encryption, public access block)

---

## 💡 Key Concepts

### Conditional steps with `if:`

```yaml
- name: Terraform Apply
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: terraform apply -auto-approve tfplan
```

This step only runs when someone pushes directly to `main` (i.e. after a PR is merged). On a PR, this step is **skipped** — only the plan runs.

### Partial backend configuration

Terraform's backend block cannot use variables. Instead, pass values at `init` time:

```bash
terraform init -backend-config="bucket=${{ secrets.TF_STATE_BUCKET }}"
```

This is the standard pattern for keeping the state bucket name out of version control.

### Passing Terraform variables in CI

Instead of committing a `terraform.tfvars` file (which would be gitignored), use `TF_VAR_*` environment variables. Terraform automatically picks them up:

```yaml
env:
  TF_VAR_bucket_name: ${{ secrets.TF_BUCKET_NAME }}
```

### Working directory

All Terraform commands must run from the correct directory:

```yaml
- name: Terraform Plan
  run: terraform plan -out=tfplan
  working-directory: './GH_Actions/lab4/terraform'
```

---

## ✨ Enhancement: Split into Two Workflows

Once your single workflow is working, refactor it into two separate files:

- `.github/workflows/terraform-ci.yml` — triggered on `pull_request`, runs fmt → validate → checkov → plan
- `.github/workflows/terraform-cd.yml` — triggered on `push` to `main`, runs all stages including apply

**Why split?**
- Clearer separation of concerns
- Each file has one responsibility
- Easier to add different permissions or environments to each
- Standard in real-world repositories

---

## ✨ Bonus Challenges

These are not required for the lab but document important real-world patterns:

**1. Post plan as a PR comment**
Use `actions/github-script` to read the `terraform show -no-color tfplan` output and post it as a comment on the PR. Reviewers can see exactly what will change without reading logs.

**2. Manual approval gate before apply**
Create a GitHub Environment called `production` with "Required reviewers". Reference it in your deploy job — the apply step pauses until a human approves it.

**3. Cache the `.terraform/` directory**
Provider plugins are downloaded fresh on every run. Use `actions/cache` to cache `.terraform/` and speed up subsequent runs significantly.

**4. Drift detection**
Add a third workflow triggered on a schedule (`on: schedule: - cron: '0 6 * * *'`) that runs `terraform plan` and fails if any drift is detected (infrastructure changed outside of Terraform).

**5. Matrix across Terraform versions**
Test that your configuration is compatible with multiple Terraform versions in parallel — builds directly on what you learned in Lab 3.

---

## ✔️ Success Criteria

- ✅ Pipeline runs on every PR and push to `main`
- ✅ `terraform fmt -check` fails on the original code and passes after your fix
- ✅ `checkov` fails on the original code and passes after your fix
- ✅ `terraform plan` succeeds and shows the expected resources
- ✅ `terraform apply` runs **only** on push to `main` — skipped on PRs
- ✅ After merging, the S3 bucket exists in AWS with the correct configuration
- ✅ `terraform output` prints the bucket name and ARN

---

## 📚 Resources

- [hashicorp/setup-terraform action](https://github.com/hashicorp/setup-terraform)
- [Terraform AWS S3 bucket resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
- [Checkov documentation](https://www.checkov.io/1.Welcome/What%20is%20Checkov.html)
- [GitHub Actions: `if` expressions](https://docs.github.com/en/actions/learn-github-actions/expressions)
- [GitHub Actions: context variables](https://docs.github.com/en/actions/learn-github-actions/contexts#github-context)

Good luck! 🎓
