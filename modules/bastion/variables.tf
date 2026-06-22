variable "region" {
  description = "The region where resources are created."
  type        = string
}

variable "vpc" {
  description = "The VPC to which the bastion host will be attached."
  type        = string
}

variable "bastion_name" {
  description = "Bastion host name"
  type        = string
}

variable "public_subnet" {
  description = "The VPC to which the bastion host will be attached."
  type        = string
}

# variable "subnetwork" {
#   description = "The VPC to which the bastion host will be attached."
#   type        = string
# }

variable "network" {
  description = "The VPC to which the bastion host will be attached."
  type        = string
}