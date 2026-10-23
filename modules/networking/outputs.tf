output "vcn_id" {
  description = "OCID of the VCN."
  value       = oci_core_vcn.main.id
}

output "public_subnet_id" {
  description = "OCID of the public subnet."
  value       = oci_core_subnet.public.id
}

output "private_subnet_id" {
  description = "OCID of the private subnet."
  value       = oci_core_subnet.private.id
}

output "app_nsg_id" {
  description = "OCID of the application network security group."
  value       = oci_core_network_security_group.app.id
}

output "internet_gateway_id" {
  description = "OCID of the internet gateway."
  value       = oci_core_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "OCID of the NAT gateway."
  value       = oci_core_nat_gateway.main.id
}