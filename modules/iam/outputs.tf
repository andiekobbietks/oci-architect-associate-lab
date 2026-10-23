output "compartment_id" {
  description = "OCID of the project compartment created by this module."
  value       = oci_identity_compartment.project.id
}

output "group_name" {
  description = "Name of the platform group."
  value       = oci_identity_group.platform.name
}

output "policy_id" {
  description = "OCID of the least-privilege policy."
  value       = oci_identity_policy.platform.id
}