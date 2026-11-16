variable "instance_type" {
  description = "The type of ec2 to provision"
  type        = string
  default     = "t2.micro"
}

variable "db_instance_class" {
  default     = "db.t3.micro"
  description = "The instance class of the database"
}

variable "start_schedule" {
  description = "The cronjob start schedule as a string"
  type        = string
  default     = "cron(0 7 * * ? *)"
}

variable "stop_schedule" {
  description = "The cronjob stop schedule as a string"
  type        = string
  default     = "cron(0 19 * * ? *)"
}