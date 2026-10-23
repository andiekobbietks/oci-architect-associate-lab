# Architecture

Design decisions for `oci-architect-associate-lab`, and the trade-offs behind them.
This is a study repo: each decision is written so it can be explained aloud.

## Domain map

The module split follows the published exam weights, not the order resources are
usually created in:

| Domain | Weight | Module |
|---|---|---|
| Networking | 35% | `modules/networking` |
| Storage | 25% | `modules/storage` |
| Compute | 20% | `modules/compute` |
| Identity and Access Management | 20% | `modules/iam` |

Dependency order differs: IAM creates the compartment every other module needs, so
`iam -> networking -> {compute, storage}`.

## Network topology

A two-tier VCN, `10.20.0.0/16`:

```
                       internet
                          |
                 [internet gateway]        [NAT gateway]   [service gateway]
                          |                      |                |
                   public subnet          private subnet    private subnet
                   10.20.0.0/24           10.20.1.0/24     (OCI services)
                   (bastion / LB)          (app tier)
```

| Control | Applied to | Why |
|---|---|---|
| Internet gateway | Public subnet route table | Inbound and outbound internet for tier 1 |
| NAT gateway | Private subnet route table | Outbound only — no inbound path exists |
| Service gateway | Private subnet route table | Reach Oracle services without public internet |

**Route tables are explicit.** The VCN's default route table is created by OCI but
not used. A reader can see exactly which gateway serves which subnet, which is the
question the exam asks.

**Security lists *and* NSGs.** Security lists apply to every VNIC in a subnet; NSGs
apply per VNIC. The repo provides both so the difference is demonstrable, not just
asserted. New designs should prefer NSGs.

**`prohibit_public_ip_on_vnic = true` on the private subnet.** This is a hard
guarantee at the subnet level, not a convention. Even a caller asking for a public
IP will not get one.

## Identity model

- One project compartment, created by `modules/iam`.
- One group, `platform`.
- One policy, scoped to the project compartment, with explicit verbs per resource
  family.

The policy never uses `manage all-resources in tenancy`. In a real tenancy the
compartment is the permission boundary, and the policy is what makes that boundary
enforceable rather than decorative.

`enable_delete = false` on the compartment: Terraform will not delete a compartment
and its contents on `destroy` unless someone deliberately changes that flag.

## Storage choices

| Service | Configuration | Rationale |
|---|---|---|
| Object Storage | `NoPublicAccess`, versioning on | Buckets are shared-namespace and accidentally public buckets are a classic breach |
| Lifecycle policy | Archive at 30 days, delete at 365 | Cost control is an architecture decision, not an afterthought |
| Block Volume | 50 GB, first AD | Network-attached, formatted separately |
| File Storage | File system + mount target in the private subnet | Managed NFS; the mount target is the network endpoint |

## Compute choices

- The image is resolved at plan time from `oci_core_images`, newest Oracle Linux 9
  that supports the shape. Hard-coded image OCIDs go stale.
- Availability domains are read from `oci_identity_availability_domains`. AD names
  are tenancy- and region-specific; hard-coding them breaks on the next tenancy.
- `oci_core_instance_configuration` carries no availability domain. Placement belongs
  to the pool, which is the correct separation and a common exam trap.

## Hand-written resources, not wrapper modules

Oracle publishes `oracle-terraform-modules/terraform-oci-*` and OCI Landing Zone
configurations. They are the right choice for production. They are the wrong choice
here: this repo exists to show that the author understands the primitive resources,
and a module call hides exactly that. The trade-off is more lines and more maintenance
in exchange for visible understanding.

## Credential handling

`.gitignore` excludes Terraform state, real variable files, and OCI API keys.

The reasoning matters more than the list. Terraform state contains every attribute of
every resource, including values marked sensitive. OCI API keys authenticate as the
user directly, with no second factor. A committed `terraform.tfstate` or a committed
`oci_api_key.pem` is a full tenancy compromise, not a minor leak. The example file
`terraform.tfvars.example` holds placeholders only.

## Known limitations

- Nothing here has been applied to a live tenancy. Syntax is validated; runtime
  behaviour is not demonstrated.
- No remote state backend. A real project uses Object Storage as the backend with
  state locking — worth adding as a follow-up exercise.
- No load balancer, VPN, or FastConnect. These are exam topics outside the four
  modules as written.
- The instance configuration and pool have not been tested for autoscaling policy
  attachment.