# oci-architect-associate-lab

Infrastructure-as-code for the Oracle Cloud Infrastructure (OCI) Architect Associate
syllabus (**1Z0-1072-26**). One Terraform repository, four modules, mapped 1:1 to the
exam domains.

This is a study-and-evidence repo: the infrastructure that the exam describes, written
so it can be read, explained, and defended in an interview.

## What this covers

| Exam domain | Weight | Module | Key resources |
|---|---|---|---|
| Networking | 35% | `modules/networking` | VCN, public/private subnets, internet/NAT/service gateways, route tables, security lists, NSGs |
| Storage | 25% | `modules/storage` | Object Storage buckets + lifecycle, Block Volume, File Storage |
| Compute | 20% | `modules/compute` | Instance, instance configuration, instance pool (autoscaling) |
| Identity and Access Management | 20% | `modules/iam` | Compartment, group, policy |

The weights are the published objectives for the 2025 version of the exam. The 2026
blueprint is expected to match; confirm against the Exam Topics module in Oracle MyLearn.

## Repository layout

```
.
├── README.md
├── CHANGELOG.md
├── .gitignore
├── versions.tf                 # terraform + provider pins
├── providers.tf                # OCI provider / authentication
├── main.tf                     # wires the four modules together
├── variables.tf                # tenancy, region, project prefix
├── outputs.tf                  # VCN, subnet, bucket, instance OCIDs
├── terraform.tfvars.example    # placeholders — copy to terraform.tfvars
├── modules/
│   ├── networking/
│   ├── storage/
│   ├── compute/
│   └── iam/
├── docs/
│   ├── architecture.md         # design decisions and trade-offs
│   ├── azure-oci-mapping.md    # Azure -> OCI concept mapping
│   └── costs.md                # rough cost model and cost-control notes
├── diagrams/
│   └── architecture.py         # diagrams-as-code (Python `diagrams`)
└── .github/workflows/
    └── terraform.yml           # fmt, validate, tflint, checkov
```

## Design decisions

Recorded in full in `docs/architecture.md`. In short:

- **Hand-written resources, not wrapper modules.** A portfolio repo should show that the
  author understands the primitive resources. Oracle's `oracle-terraform-modules/*` are
  excellent for production but hide the teaching material.
- **One compartment per module scope.** Compartment boundaries are the OCI permission
  boundary, so they are modelled explicitly rather than implied.
- **Dynamic groups and policies are least-privilege.** No `manage all-resources in tenancy`.
- **Availability domains are discovered, not hard-coded.** AD names differ by tenancy and
  region; the configuration reads them via `oci_identity_availability_domains`.
- **Networking uses NSGs in addition to security lists.** Security lists are the older
  VCN-wide control; NSGs are per-VNIC and are what the exam expects an architect to
  reason about.

## Requirements

| Tool | Version |
|---|---|
| Terraform | >= 1.5.0 |
| OCI provider | >= 5.0.0 |
| Python (diagrams only) | 3.10+ |

## Authentication

The provider reads standard OCI API-key credentials. Either:

- populate `~/.oci/config` and leave the credential variables empty, or
- supply `tenancy_ocid`, `user_ocid`, `fingerprint` and `private_key_path` via
  `terraform.tfvars` (never committed).

**Never commit API keys or state.** `.gitignore` excludes `*.tfstate`, `.terraform/`,
real `*.tfvars` and OCI key files. See `docs/architecture.md` for the reasoning.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # then fill in your tenancy details
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

`terraform apply` creates billable resources. Review `docs/costs.md` first, and
`terraform destroy` when finished.

## Status

Shell only. Resources are written and validated; nothing has been applied to a live
tenancy yet. See `CHANGELOG.md` for what exists at each version.

## Licence

MIT. See `LICENSE`.