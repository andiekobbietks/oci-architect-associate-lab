variable "compartment_id" {
  description = "Compartment in which to create storage resources."
  type        = string
}

variable "project_name" {
  description = "Prefix for resource display names."
  type        = string
}

variable "bucket_name_suffix" {
  description = "Suffix appended to the project name to form the bucket name."
  type        = string
  default     = "data"
}

variable "file_subnet_id" {
  description = "Subnet the File Storage mount target attaches to. Should be a private subnet."
  type        = string
}

variable "block_volume_size_gb" {
  description = "Size of the sample block volume in GB."
  type        = number
  default     = 50
}

variable "tags" {
  description = "Freeform tags applied to every resource in this module."
  type        = map(string)
  default     = {}
}