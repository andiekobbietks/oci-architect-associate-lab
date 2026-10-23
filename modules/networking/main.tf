# ---------------------------------------------------------------------------
# Networking module  --  35% of the Architect Associate exam (largest domain)
#
# Builds a standard two-tier VCN:
#
#            internet
#               |
#        [internet gateway]        [NAT gateway]  [service gateway]
#               |                       |                |
#          public subnet           private subnet   private subnet
#          (bastion/LB)            (app tier)       (OCI services)
#
# Route tables and security lists are created explicitly rather than relying on
# the default route table and default security list, because the exam expects an
# architect to reason about both.
# ---------------------------------------------------------------------------

# ------------------------------------------------------------------- gateways
resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${var.project_name}-vcn"
  dns_label      = "ocilab"
  is_ipv6enabled = false

  freeform_tags = var.tags
}

resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-igw"
  enabled        = true

  freeform_tags = var.tags
}

resource "oci_core_nat_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-nat"

  freeform_tags = var.tags
}

# The service gateway lets private subnets reach Oracle services (Object
# Storage, and so on) without traversing the internet.
data "oci_core_services" "all" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-sgw"

  services {
    service_id = data.oci_core_services.all.services[0].id
  }

  freeform_tags = var.tags
}

# ---------------------------------------------------------------- route tables
resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-rt-public"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main.id
  }

  freeform_tags = var.tags
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-rt-private"

  # Outbound internet via NAT (no inbound).
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.main.id
  }

  # Oracle services via the service gateway.
  route_rules {
    destination       = data.oci_core_services.all.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.main.id
  }

  freeform_tags = var.tags
}

# -------------------------------------------------------------- security lists
resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-sl-public"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol  = "6" # TCP
    source    = var.ssh_ingress_cidr
    stateless = false
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = var.vcn_cidr
    stateless = false
    tcp_options {
      min = 80
      max = 80
    }
  }

  freeform_tags = var.tags
}

resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-sl-private"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Only the VCN itself may reach private-tier ports.
  ingress_security_rules {
    protocol  = "6"
    source    = var.vcn_cidr
    stateless = false
    tcp_options {
      min = 443
      max = 443
    }
  }

  freeform_tags = var.tags
}

# -------------------------------------------------------------------- subnets
resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = var.public_subnet_cidr
  display_name               = "${var.project_name}-subnet-public"
  dns_label                  = "public"
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false

  freeform_tags = var.tags
}

resource "oci_core_subnet" "private" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.main.id
  cidr_block        = var.private_subnet_cidr
  display_name      = "${var.project_name}-subnet-private"
  dns_label         = "private"
  route_table_id    = oci_core_route_table.private.id
  security_list_ids = [oci_core_security_list.private.id]
  # Hard guarantee: no public IP, even if a caller asks for one.
  prohibit_public_ip_on_vnic = true

  freeform_tags = var.tags
}

# ------------------------------------------------------- network security group
# NSGs are per-VNIC, unlike security lists which apply VCN-wide. Modern OCI
# designs prefer NSGs; both are shown so the difference is visible.
resource "oci_core_network_security_group" "app" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-nsg-app"

  freeform_tags = var.tags
}

resource "oci_core_network_security_group_security_rule" "app_ssh" {
  network_security_group_id = oci_core_network_security_group.app.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = var.ssh_ingress_cidr
  source_type               = "CIDR_BLOCK"
  description               = "SSH from the operator CIDR"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "app_http" {
  network_security_group_id = oci_core_network_security_group.app.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  description               = "HTTP from inside the VCN"

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}