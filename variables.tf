variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "dev_instance_type" {
  default = "t2.micro"
}

variable "test_instance_type" {
  default = "t2.micro"
}

variable "prod_instance_type" {
  default = "t2.large"
}

locals {
  instance_type = {
    dev  = var.dev_instance_type
    test = var.test_instance_type
    prod = var.prod_instance_type
  }
}

