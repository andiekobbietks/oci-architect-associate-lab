# ---------------------------------------------------------------------------
# IAM module  --  20% of the Architect Associate exam
#
# Teaches the OCI permission model: compartments are the boundary, groups are
# the subject, policies are the rule. Deliberately least-privilege: the policy
# grants verbs on resource types inside one compartment, never
# "manage all-resources in tenancy".
# ---------------------------------------------------------------------------

resource "oci_identity_compartment" "project" {
  compartment_id = var.parent_compartment_ocid
  name           = "${var.project_name}-${var.environment}"
  description    = "Project compartment for ${var.project_name} (${var.environment})."
  enable_delete  = false # true would delete the compartment and everything in it on destroy

  freeform_tags = var.tags
}

# A group to hold the humans or service principals who operate this stack.
resource "oci_identity_group" "platform" {
  compartment_id = var.parent_compartment_ocid
  name           = "${var.project_name}-platform"
  description    = "Platform operators for ${var.project_name}."

  freeform_tags = var.tags
}

# Least-privilege policy. Each statement names an explicit verb and an explicit
# resource type, scoped to the project compartment only.
resource "oci_identity_policy" "platform" {
  compartment_id = var.parent_compartment_ocid
  name           = "${var.project_name}-platform-policy"
  description    = "Scoped permissions for the ${var.project_name} platform group."

  statements = [
    "Allow group ${oci_identity_group.platform.name} to read all-resources in compartment ${oci_identity_compartment.project.name}",
    "Allow group ${oci_identity_group.platform.name} to manage instance-family in compartment ${oci_identity_compartment.project.name}",
    "Allow group ${oci_identity_group.platform.name} to manage virtual-network-family in compartment ${oci_identity_compartment.project.name}",
    "Allow group ${oci_identity_group.platform.name} to manage volume-family in compartment ${oci_identity_compartment.project.name}",
    "Allow group ${oci_identity_group.platform.name} to manage object-family in compartment ${oci_identity_compartment.project.name}",
    "Allow group ${oci_identity_group.platform.name} to use file-family in compartment ${oci_identity_compartment.project.name}",
  ]

  freeform_tags = var.tags
}