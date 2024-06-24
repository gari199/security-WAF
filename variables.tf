variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "WAF project"
}

variable "region" {
  description = "Region where components will be deployed"
  type        = string
  default     = "eu-central-1"
}

variable "security_group_id" {
  description = "ID of existing SG"
  type        = string
  default     = "sg-0c226fddab0a2860c"
}

variable "bucket_name" {
  description = "Name of the Bucket for logging"
  type        = string
  default     = "aws-waf-logs-acme-demo-waf-security"
}

variable "subnet_id_1" {
  description = "Subnet ID 1"
  type        = string
}

variable "subnet_id_2" {
  description = "Subnet ID 1"
  type        = string
}

variable "subnet_id_3" {
  description = "Subnet ID 1"
  type        = string
}

