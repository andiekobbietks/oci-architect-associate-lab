provider "oci" {
  # Any of these may be left empty when ~/.oci/config is populated.
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region

  # Set to the profile name in ~/.oci/config, or leave as "DEFAULT".
  config_file_profile = var.config_file_profile
}