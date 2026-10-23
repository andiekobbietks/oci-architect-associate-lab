variable "parent_compartment_ocid" {
  description = "OCID of the compartment that will hold the project compartment."
  type        = string
}

variable "project_name" {
  description = "Prefix for the project compartment name."
  type        = string
}

variable "environment" {
  description = "Environment label."
  type        = string
}

variable "tags" {
  description = "Freeform tags applied to every resource in this module."
  type        = map(string)
  default     = {}
}