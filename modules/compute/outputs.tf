output "instance_id" {
  description = "OCID of the sample compute instance."
  value       = oci_core_instance.app.id
}

output "instance_public_ip" {
  description = "Public IP of the sample instance, if assigned."
  value       = oci_core_instance.app.public_ip
}

output "instance_configuration_id" {
  description = "OCID of the instance configuration used by the pool."
  value       = oci_core_instance_configuration.app.id
}

output "instance_pool_id" {
  description = "OCID of the instance pool."
  value       = oci_core_instance_pool.app.id
}

output "image_id" {
  description = "OCID of the resolved Oracle Linux image."
  value       = data.oci_core_images.oracle_linux.images[0].id
}