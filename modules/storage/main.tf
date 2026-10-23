# ---------------------------------------------------------------------------
# Storage module  --  25% of the Architect Associate exam
#
# Covers the three storage families the exam separates:
#   * Object Storage  -- buckets, access type, versioning, lifecycle rules
#   * Block Volume    -- network-attached block device
#   * File Storage    -- managed NFS (file system + mount target)
# ---------------------------------------------------------------------------

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_id
}

# --------------------------------------------------------------- object storage
resource "oci_objectstorage_bucket" "data" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "${var.project_name}-${var.bucket_name_suffix}"
  # Private by default. Object Storage buckets are never public unless you say so.
  access_type  = "NoPublicAccess"
  storage_tier = "Standard"
  versioning   = "Enabled"
  auto_tiering = "Disabled"

  freeform_tags = var.tags
}

# Lifecycle policy: move objects to cheaper tiers as they age, then delete.
# This is the cost-control story the exam asks about.
resource "oci_objectstorage_object_lifecycle_policy" "data" {
  namespace = data.oci_objectstorage_namespace.ns.namespace
  bucket    = oci_objectstorage_bucket.data.name

  rules {
    name        = "archive-after-30-days"
    action      = "ARCHIVE"
    target      = "objects"
    time_amount = 30
    time_unit   = "DAYS"
    is_enabled  = true
  }

  rules {
    name        = "delete-after-365-days"
    action      = "DELETE"
    target      = "objects"
    time_amount = 365
    time_unit   = "DAYS"
    is_enabled  = true
  }
}

# ------------------------------------------------------------------ block volume
resource "oci_core_volume" "data" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "${var.project_name}-bv-data"
  size_in_gbs         = var.block_volume_size_gb

  freeform_tags = var.tags
}

# ------------------------------------------------------------------ file storage
resource "oci_file_storage_file_system" "shared" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "${var.project_name}-fs-shared"

  freeform_tags = var.tags
}

# A mount target needs a subnet; the private subnet is passed in by the root
# module through the file_subnet_id variable.
resource "oci_file_storage_mount_target" "shared" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  subnet_id           = var.file_subnet_id
  display_name        = "${var.project_name}-mnt-shared"

  freeform_tags = var.tags
}