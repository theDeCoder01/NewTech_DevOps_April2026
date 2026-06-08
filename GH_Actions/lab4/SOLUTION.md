# Lab 4 Solution Guide — CI/CD for Terraform

This document is for instructors. It covers the three intentional bugs in the provided Terraform code, the complete workflow solutions, and a grading rubric.

Solution files are in `GH_Actions/solutions/`:
- `lab4-single.yml` — single workflow with conditional apply (starting point)
- `lab4-ci.yml` — CI-only workflow (split version)
- `lab4-cd.yml` — CD-only workflow (split version)

---

## 🐛 The Three Intentional Bugs

Each bug is caught by a different pipeline stage, teaching students that every stage serves a distinct purpose.

---

### Bug 1 — Formatting (caught by `terraform fmt -check`)

**Location:** `main.tf` — the `tags` block inside `aws_s3_bucket`

**The issue:** Tag attribute values are not column-aligned. `terraform fmt` enforces alignment.

```hcl
# BROKEN
tags = {
  Name = var.bucket_name
  Environment = var.environment
  Project = var.project_name
  ManagedBy = "terraform"
}
```

```hcl
# FIXED — terraform fmt aligns the = signs
tags = {
  Name        = var.bucket_name
  Environment = var.environment
  Project     = var.project_name
  ManagedBy   = "terraform"
}
```

**How to fix:** Run `terraform fmt` in the terraform directory. It rewrites the file in place.

**Teaching point:** `terraform fmt` is deterministic — running it twice produces the same result. Enforcing it in CI ensures every contributor's code looks the same regardless of their editor settings.

---

### Bug 2 — Security misconfigurations (caught by `checkov`)

**Location:** `main.tf` — `aws_s3_bucket_public_access_block` and `aws_s3_bucket_versioning`

#### 2a. Public access not blocked

```hcl
# BROKEN — all four flags are false
resource "aws_s3_bucket_public_access_block" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
```

```hcl
# FIXED
resource "aws_s3_bucket_public_access_block" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

Checkov rule: `CKV2_AWS_6` — "Ensure that S3 bucket has a Public Access block"

#### 2b. Versioning disabled

```hcl
# BROKEN
versioning_configuration {
  status = "Disabled"
}
```

```hcl
# FIXED
versioning_configuration {
  status = "Enabled"
}
```

Checkov rule: `CKV_AWS_21` — "Ensure the S3 bucket has versioning enabled"

---

### Bug 3 — Missing encryption (caught by `checkov`)

**Location:** `main.tf` — the `aws_s3_bucket_server_side_encryption_configuration` resource is entirely absent.

```hcl
# ADD THIS to main.tf
resource "aws_s3_bucket_server_side_encryption_configuration" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

Checkov rule: `CKV_AWS_145` — "Ensure that S3 bucket has encryption at rest enabled"

**Teaching point:** checkov catches not just wrong values but also *missing* resources. Having a resource with bad settings is an error; not having a required resource at all is also an error.

---

## ✅ Complete Fixed `main.tf`

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    key    = "lab4/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "app_storage" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

---

## 🔍 Workflow Breakdown

### The conditional apply — the core lesson

```yaml
- name: Terraform Apply
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: terraform apply -auto-approve tfplan
```

| Scenario | `github.event_name` | `github.ref` | Apply runs? |
|---|---|---|---|
| Pull request opened/updated | `pull_request` | `refs/pull/N/merge` | ❌ No |
| Push directly to main | `push` | `refs/heads/main` | ✅ Yes |
| Push to feature branch | `push` | `refs/heads/feature-xyz` | ❌ No |

### Why pass `-backend-config` at init?

Terraform's `backend` block is evaluated before variables are loaded, so you cannot use `var.*` or environment variables inside it. The partial configuration pattern solves this:

```yaml
- name: Terraform Init
  run: terraform init -backend-config="bucket=${{ secrets.TF_STATE_BUCKET }}" -input=false
```

The `key` and `region` are committed in `main.tf` (not sensitive). The `bucket` name is kept in a secret and injected at init time.

### Why re-run the quality gate in the CD workflow?

When using two separate workflows (enhancement task), the CD workflow re-runs `fmt`, `validate`, `checkov`, and `plan` before applying. This is because:

- The CI workflow ran on the feature branch
- Between the PR being reviewed and merged, other commits may have landed on `main`
- Running the checks again guarantees the *merged* state is valid

---

## 🚩 Common Student Mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Apply runs on PRs | Resources created on every PR, state conflicts | Add correct `if:` condition |
| Missing `-input=false` on init/plan | Pipeline hangs waiting for user input | Add `-input=false` to all commands |
| State bucket doesn't exist | `terraform init` fails with NoSuchBucket | Create state bucket first (one-time setup) |
| `TF_BUCKET_NAME` not set as secret | Plan shows `var.bucket_name` prompt or empty string | Add the secret in repo settings |
| Checkov installed but wrong working directory | Checkov scans the entire repo, misses terraform/ | Set `working-directory` or pass `-d ./GH_Actions/lab4/terraform` |
| Forgetting `-out=tfplan` on plan | Apply has no plan file, `-auto-approve` applies against live state | Always use `-out` on plan, reference the file on apply |

---

## 🎯 Grading Rubric

| Requirement | Points |
|---|---|
| Workflow triggers on both `push` and `pull_request` to `main` | 5 |
| `terraform init` uses `-backend-config` for state bucket | 10 |
| `terraform fmt -check` step present and fails on original code | 10 |
| `terraform validate` step present | 5 |
| `checkov` step present and fails on original code | 15 |
| `terraform plan` saves output with `-out=tfplan` | 10 |
| `terraform apply` runs **only** on push to `main` | 20 |
| `terraform output` runs after apply | 5 |
| All three Terraform bugs fixed (fmt + checkov pass) | 15 |
| S3 bucket exists in AWS with correct config after merge | 5 |
| **Enhancement: split into two workflow files** | +15 |
| **Total** | 100 (+15 bonus) |

---

## 🔗 Additional Resources

- [Terraform partial backend configuration](https://developer.hashicorp.com/terraform/language/settings/backends/configuration#partial-configuration)
- [hashicorp/setup-terraform action](https://github.com/hashicorp/setup-terraform)
- [Checkov skip checks](https://www.checkov.io/2.Basics/Suppressing%20and%20Skipping%20Policies.html)
- [GitHub Actions: `github` context](https://docs.github.com/en/actions/learn-github-actions/contexts#github-context)
