#### Variables 

variable "cidr_vpc" {
  description = "cidr block to be used by the VPC in Mumbai"
}


variable "az1" {
  description = "cidr block to be used by the VPC in Mumbai"
}


variable "az2" {
  description = "cidr block to be used by the VPC in Mumbai"
}

variable "cidr_pubsub1_vpc" {
  description = "cidr block to be used by the public subnet in US-EAST-1A"
}

variable "cidr_pubsub2_vpc" {
  description = "cidr block to be used by the public subnet in us-east-ab"
}

variable "cidr_prvsub1_vpc" {
  description = "cidr block to be used by the private subnet in US-EAST-1A"
}

variable "cidr_prvsub2_vpc" {
  description = "cidr block to be used by the private subnet in US-EAST-1B"
}

variable "us-east-ami" {
  description = "AMI of the instance to be used in Virginia"
}


variable "us-east-instance" {
  description = "Instance Type of Virginia"
}


