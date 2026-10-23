# ---------------------------------------------------------------- tenancy auth
variable "tenancy_ocid" {
  description = "OCID of the tenancy. Leave empty to read from ~/.oci/config."
  type        = string
  default     = ""
}

variable "user_ocid" {
  description = "OCID of the API user. Leave empty to read from ~/.oci/config."
  type        = string
  default     = ""
}

variable "fingerprint" {
  description = "Fingerprint of the API key. Leave empty to read from ~/.oci/config."
  type        = string
  default     = ""
}

variable "private_key_path" {
  description = "Path to the OCI API private key. Leave empty to read from ~/.oci/config."
  type        = string
  default     = ""
}

variable "config_file_profile" {
  description = "Profile name in ~/.oci/config."
  type        = string
  default     = "DEFAULT"
}

# ------------------------------------------------------------------- placement
variable "region" {
  description = "OCI region identifier, for example uk-london-1."
  type        = string
  default     = "uk-london-1"
}

variable "parent_compartment_ocid" {
  description = "OCID of the compartment that will hold the project compartment. Use the tenancy OCID for a top-level project."
  type        = string
}

# --------------------------------------------------------------------- project
variable "project_name" {
  description = "Short name used as a prefix for every resource and the project compartment."
  type        = string
  default     = "ociarchlab"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.project_name))
    error_message = "project_name must start with a letter and contain only lowercase letters, digits and hyphens (3-21 characters)."
  }
}

variable "environment" {
  description = "Environment label applied as a freeform tag."
  type        = string
  default     = "lab"
}

variable "defined_tags" {
  description = "Optional defined tags applied to resources."
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------ networking
variable "vcn_cidr" {
  description = "CIDR block for the VCN."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.20.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet."
  type        = string
  default     = "10.20.1.0/24"
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to reach port 22 on the public subnet. Narrow this for anything but a lab."
  type        = string
  default     = "0.0.0.0/0"
}

# --------------------------------------------------------------------- compute
variable "instance_shape" {
  description = "Compute shape for the sample instance."
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "instance_ocpus" {
  description = "OCPUs for the flex shape."
  type        = number
  default     = 1
}

variable "instance_memory_gb" {
  description = "Memory in GB for the flex shape."
  type        = number
  default     = 8
}

variable "ssh_public_key" {
  description = "SSH public key injected into the instance. Leave empty to skip metadata injection."
  type        = string
  default     = ""
}

# --------------------------------------------------------------------- storage
variable "bucket_name_suffix" {
  description = "Suffix appended to the project name for bucket naming. Bucket names are globally unique in OCI."
  type        = string
  default     = "data"
}

variable "block_volume_size_gb" {
  description = "Size of the sample block volume in GB."
  type        = number
  default     = 50
}