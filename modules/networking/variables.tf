variable "compartment_id" {
  description = "Compartment in which to create network resources."
  type        = string
}

variable "project_name" {
  description = "Prefix for resource display names."
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet."
  type        = string
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to reach TCP 22 on the app NSG."
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "Freeform tags applied to every resource in this module."
  type        = map(string)
  default     = {}
}