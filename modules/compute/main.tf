# ---------------------------------------------------------------------------
# Compute module  --  20% of the Architect Associate exam
#
# Covers:
#   * Instance            -- a single VM, with an explicit shape config and NIC
#   * Instance configuration -- the reusable template for a pool
#   * Instance pool       -- template + placement + size, the autoscaling unit
#
# Availability domains are discovered, never hard-coded, because AD names are
# tenancy-specific.
# ---------------------------------------------------------------------------

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Pick the newest Oracle Linux 9 image that supports the chosen shape.
data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "9"
  shape                    = var.shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

locals {
  nsg_ids = var.nsg_id == "" ? [] : [var.nsg_id]

  instance_metadata = (
    var.ssh_public_key == ""
    ? {}
    : { ssh_authorized_keys = var.ssh_public_key }
  )
}

# ----------------------------------------------------------------- single VM
resource "oci_core_instance" "app" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = var.shape
  display_name        = "${var.project_name}-vm-app"

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_gb
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.oracle_linux.images[0].id
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
    nsg_ids          = local.nsg_ids
    display_name     = "${var.project_name}-vnic-app"
  }

  metadata = local.instance_metadata

  freeform_tags = var.tags
}

# ---------------------------------------------------- instance configuration
# The template. Note this carries no availability domain -- placement is the
# pool's job.
resource "oci_core_instance_configuration" "app" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-ic-app"

  instance_details {
    instance_type = "compute"

    launch_details {
      shape = var.shape

      shape_config {
        ocpus         = var.ocpus
        memory_in_gbs = var.memory_gb
      }

      source_details {
        source_type = "image"
        image_id    = data.oci_core_images.oracle_linux.images[0].id
      }

      create_vnic_details {
        subnet_id        = var.subnet_id
        assign_public_ip = true
        nsg_ids          = local.nsg_ids
        display_name     = "${var.project_name}-vnic-pool"
      }

      metadata = local.instance_metadata

      freeform_tags = var.tags
    }
  }

  freeform_tags = var.tags
}

# ---------------------------------------------------------------- instance pool
# The scaling unit. A real autoscaling configuration attaches to this pool.
resource "oci_core_instance_pool" "app" {
  compartment_id            = var.compartment_id
  instance_configuration_id = oci_core_instance_configuration.app.id
  size                      = var.pool_size
  display_name              = "${var.project_name}-pool-app"

  placement_configurations {
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    primary_subnet_id   = var.subnet_id
  }

  freeform_tags = var.tags
}