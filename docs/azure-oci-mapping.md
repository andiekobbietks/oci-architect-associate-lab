# Azure to OCI concept mapping

The value of a cross-cloud mapping is that it makes prior knowledge transferable and
makes the genuine differences visible. Azure is used as the reference because it is
the most common comparison for UK cloud contracts.

## Identity and access

| Azure | OCI | Note |
|---|---|---|
| Entra ID tenant | Tenancy | Both are the top-level identity boundary |
| Management group / subscription | Compartment (nestable) | Compartments nest like folders; access is compartment-scoped |
| Resource group | Compartment | OCI has one concept where Azure has two |
| Entra ID group | Identity group | Similar |
| RBAC role assignment | Policy statement | OCI policies are plain-language sentences: `Allow group X to manage Y in compartment Z` |
| Managed identity | Instance principal / resource principal | The OCI equivalent of workload identity |
| Conditional Access | No direct equivalent | Enforced at the IdP federation layer, not inside OCI IAM |

**Key difference:** Azure RBAC assigns a role with a built-in permission set. OCI
policies name verb and resource type directly. OCI is more explicit and more verbose.

## Networking

| Azure | OCI | Note |
|---|---|---|
| Virtual network (VNet) | Virtual Cloud Network (VCN) | Same idea |
| Subnet | Subnet | OCI subnets are regional (span ADs); Azure subnets are regional too |
| Network security group | Network security group | Conceptually the same, both per-NIC |
| — | Security list | OCI-only: applies VCN-wide, the older control |
| Route table / UDR | Route table | Same |
| NAT gateway | NAT gateway | Same |
| — | Service gateway | OCI-only: private path to Oracle services, no internet traversal |
| Azure Firewall / NVA | No built-in managed firewall | Use a third-party NVA or OCI Network Firewall |
| Private endpoint | Service gateway (for OCI services) | Different model: the gateway is attached to the subnet's route table |
| Load balancer (L4/L7) | Load balancer (flexible shapes) | Similar |

**Key difference:** OCI has both security lists **and** NSGs. Azure has only NSGs.
The service gateway is an OCI concept with no direct Azure match — Azure's closest
analogue is a private endpoint, but the mechanism is different.

## Compute

| Azure | OCI | Note |
|---|---|---|
| Virtual machine | Instance | Same |
| VM size | Shape (fixed or Flex) | Flex shapes let you set OCPU and memory independently |
| VM scale set | Instance pool | Pool + instance configuration + autoscaling policy |
| Availability set | — | OCI spreads across ADs or fault domains |
| Availability zone | Availability domain | OCI ADs are physically separate within a region |
| — | Fault domain | Additional anti-affinity within an AD |
| Azure Marketplace image | OCI Marketplace image | Similar |

**Key difference:** OCI Flex shapes and fault domains have no exact Azure match. The
instance pool + instance configuration split is the closest analogue to a scale set,
but the availability-domain handling differs sharply.

## Storage

| Azure | OCI | Note |
|---|---|---|
| Blob Storage | Object Storage | Similar; OCI buckets are in a tenancy-wide namespace |
| — | Storage tier + lifecycle rules | OCI Object Storage has archive tiers similar to Blob's cool/archive |
| Managed disk | Block Volume | Both are network-attached, detachable disks |
| Azure Files | File Storage (NFS) | Both are managed file shares |
| — | Mount target | OCI's network endpoint for File Storage; Azure uses private endpoints instead |

## Where the transfer is hardest

1. **Policy language.** OCI policies are free-text statements with a specific grammar.
   Getting the grammar wrong fails silently in the sense that a permission just is not
   granted. This is the single biggest time sink for an Azure engineer.
2. **Security lists vs NSGs.** Two overlapping controls means you must reason about
   which takes precedence and where each applies.
3. **Availability domains.** Azure engineers expect zones; OCI ADs behave differently
   and are named per tenancy.
4. **Resource model.** OCI compartments collapse Azure's management group and resource
   group into one nestable concept. This is simpler, but the mental shift trips people.

## What transfers cleanly

- Networking fundamentals: CIDR, subnets, route tables, gateways.
- Compute shape sizing and image selection.
- Object vs block vs file storage decisions.
- The general Terraform workflow: `init`, `plan`, `apply`, `destroy`, state, modules.
- Least-privilege thinking, once the OCI policy grammar is learned.