output "compartment_id" {
  description = "OCID of the project compartment."
  value       = module.iam.compartment_id
}

output "vcn_id" {
  description = "OCID of the VCN."
  value       = module.networking.vcn_id
}

output "public_subnet_id" {
  description = "OCID of the public subnet."
  value       = module.networking.public_subnet_id
}

output "private_subnet_id" {
  description = "OCID of the private subnet."
  value       = module.networking.private_subnet_id
}

output "bucket_name" {
  description = "Name of the Object Storage bucket."
  value       = module.storage.bucket_name
}

output "instance_id" {
  description = "OCID of the sample compute instance."
  value       = module.compute.instance_id
}