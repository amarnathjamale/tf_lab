variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID to deploy the instance in"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Variable for vpc_security_group_ids"
  type        = list(string)
}
