variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

# ubuntu-xenial-16.04 (x64)
# Golden Image
# rm default - should always be provided
variable "aws_amis" {
  default = {
    "eu-west-1" = "ami-072799097cd458db8"
  }
}

variable "availability_zones" {
  default     = "eu-west-1b,eu-west-1c,eu-west-1a"
  description = "List of availability zones, use AWS CLI to find your "
}

variable "key_name" {
  default     = "r42"
  description = "Name of AWS key pair"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "2"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "2"
}
