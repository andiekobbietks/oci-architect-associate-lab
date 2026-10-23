variable "compartment_id" {
  description = "Compartment in which to create compute resources."
  type        = string
}

variable "project_name" {
  description = "Prefix for resource display names."
  type        = string
}

variable "subnet_id" {
  description = "Subnet the instance and instance pool NICs attach to."
  type        = string
}

variable "nsg_id" {
  description = "Network security group applied to instance VNICs. Empty string to skip."
  type        = string
  default     = ""
}

variable "shape" {
  description = "Compute shape, for example VM.Standard.E4.Flex."
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "ocpus" {
  description = "OCPUs for a flex shape."
  type        = number
  default     = 1
}

variable "memory_gb" {
  description = "Memory in GB for a flex shape."
  type        = number
  default     = 8
}

variable "ssh_public_key" {
  description = "SSH public key injected into the instance. Empty string skips injection."
  type        = string
  default     = ""
}

variable "pool_size" {
  description = "Desired size of the sample instance pool."
  type        = number
  default     = 2
}

variable "tags" {
  description = "Freeform tags applied to every resource in this module."
  type        = map(string)
  default     = {}
}