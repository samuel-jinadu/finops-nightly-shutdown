
output "ec2_public_ip" {
  description = "The public IP address of the development web server"
  value       = aws_instance.dev_server.public_ip
}

output "rds_endpoint" {
  description = "The connection endpoint for the RDS database"
  value       = aws_db_instance.default.endpoint
}

output "automation_schedule" {
  description = "The configured start and stop schedules"
  value       = "Starts at: ${var.start_schedule} | Stops at: ${var.stop_schedule}"
}


output "finops_savings_summary" {
  description = "Estimated cost savings from automated scheduling"
  value = {
    time_off_percentage     = format("%.1f%%", local.savings_percentage)
    estimated_ec2_savings   = format("$%.2f/month", local.ec2_monthly_savings)
    estimated_rds_savings   = format("$%.2f/month", local.rds_monthly_savings)
    total_estimated_savings = format("$%.2f/month", local.total_monthly_savings)
    annual_savings          = format("$%.2f/year", local.total_monthly_savings * 12)
  }
}