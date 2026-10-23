output "bucket_name" {
  description = "Name of the Object Storage bucket."
  value       = oci_objectstorage_bucket.data.name
}

output "bucket_namespace" {
  description = "Object Storage namespace for the tenancy."
  value       = data.oci_objectstorage_namespace.ns.namespace
}

output "block_volume_id" {
  description = "OCID of the Block Volume."
  value       = oci_core_volume.data.id
}

output "file_system_id" {
  description = "OCID of the File Storage file system."
  value       = oci_file_storage_file_system.shared.id
}

output "mount_target_id" {
  description = "OCID of the File Storage mount target."
  value       = oci_file_storage_mount_target.shared.id
}