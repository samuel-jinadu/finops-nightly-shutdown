# FinOps Nightly Shutdown Automator 🚀

## The Problem
Idle development resources burn cloud budgets overnight. 

## The Solution
A Terraform module that provisions a cost-optimized dev environment (Single-AZ RDS + EC2) and automatically schedules them to start at 7 AM and stop at 7 PM.

**Estimated Savings:** This setup turns off resources for 84 hours a week (50%), saving approximately **$XX.XX per month** per environment.

## Architecture
- **Compute:** 1x `t2.micro` EC2 Instance
- **Database:** 1x `db.t3.micro` RDS Instance (PostgreSQL 17, Single-AZ)
- **Automation:** AWS EventBridge (CloudWatch Events) + IAM Roles
- **State Management:** S3 + DynamoDB (Simulated via FakeCloud)

## Local Testing (FakeCloud)
This project is configured to run against `fakecloud` or any suitable local aws emulator on port 4566

1. Start FakeCloud & Stackport: `./start-fakecloud.sh && uv sync  && source .env && uv run stackport`
2. Source environment variables: `source .env`
3. Initialize Terraform: `terraform init`
4. Review the plan: `terraform plan`
5. Deploy: `terraform apply --auto-approve`