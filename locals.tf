
locals {
  hours_off_per_week   = (7 * 12)
  total_hours_per_week = 7 * 24

  savings_percentage = (local.hours_off_per_week / local.total_hours_per_week) * 100

  # Rough AWS On-Demand Pricing (us-east-1) for calculation purposes
  # t2.micro EC2: ~$0.0116/hr | db.t3.micro RDS: ~$0.018/hr
  ec2_monthly_savings   = 0.0116 * local.hours_off_per_week * 4.33
  rds_monthly_savings   = 0.018 * local.hours_off_per_week * 4.33
  total_monthly_savings = local.ec2_monthly_savings + local.rds_monthly_savings
}