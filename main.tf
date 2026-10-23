# ---------------------------------------------------------------------------
# oci-architect-associate-lab
#
# Root module. Wires the four domain modules together in dependency order:
#   iam  ->  networking  ->  compute
#                        ->  storage
# ---------------------------------------------------------------------------

locals {
  common_tags = merge(
    {
      project     = var.project_name
      environment = var.environment
      managed_by  = "terraform"
    },
    var.defined_tags,
  )
}

module "iam" {
  source = "./modules/iam"

  parent_compartment_ocid = var.parent_compartment_ocid
  project_name            = var.project_name
  environment             = var.environment
  tags                    = local.common_tags
}

module "networking" {
  source = "./modules/networking"

  compartment_id      = module.iam.compartment_id
  project_name        = var.project_name
  vcn_cidr            = var.vcn_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  ssh_ingress_cidr    = var.ssh_ingress_cidr
  tags                = local.common_tags
}

module "storage" {
  source = "./modules/storage"

  compartment_id       = module.iam.compartment_id
  project_name         = var.project_name
  bucket_name_suffix   = var.bucket_name_suffix
  block_volume_size_gb = var.block_volume_size_gb
  file_subnet_id       = module.networking.private_subnet_id
  tags                 = local.common_tags
}

module "compute" {
  source = "./modules/compute"

  compartment_id = module.iam.compartment_id
  project_name   = var.project_name
  subnet_id      = module.networking.public_subnet_id
  nsg_id         = module.networking.app_nsg_id
  shape          = var.instance_shape
  ocpus          = var.instance_ocpus
  memory_gb      = var.instance_memory_gb
  ssh_public_key = var.ssh_public_key
  tags           = local.common_tags
}