variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "WAF project"
}

variable "account_id" {
  description = "AWS account ID where the WAF is created."
  type        = string
  default     = "637423344778"
}

variable "security_group_id" {
  description = "ID of existing SG"
  type = string
  default ="sg-0c226fddab0a2860c"
}

variable "subnet_id_1" {
  description = "SUbnet ID 1"
  type = string
}

variable "subnet_id_2" {
  description = "SUbnet ID 1"
  type = string
}

variable "subnet_id_3" {
  description = "SUbnet ID 1"
  type = string
}

