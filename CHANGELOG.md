# Changelog

All notable changes to this repository are recorded here.
This project follows [Semantic Versioning](https://semver.org/).

## [0.1.1] - 2026-10-23

### Fixed

- Each module now declares its own `required_version` and `required_providers`.
  The first CI run failed `tflint` on `terraform_required_version` and
  `terraform_required_providers` for all four modules — a module should not
  inherit its constraints silently from the root.

## [0.1.0] - 2026-10-23

Initial shell. Nothing has been applied to a live tenancy.

### Added

- Root module with `versions.tf`, `providers.tf`, `main.tf`, `variables.tf`,
  `outputs.tf` and `terraform.tfvars.example`.
- `modules/networking` — VCN, public and private subnets, internet gateway, NAT
  gateway, service gateway, route tables, security lists and a network security group.
- `modules/storage` — Object Storage bucket with lifecycle policy, Block Volume, and
  File Storage file system.
- `modules/compute` — instance, instance configuration and instance pool.
- `modules/iam` — project compartment, group and least-privilege policy.
- `docs/architecture.md`, `docs/azure-oci-mapping.md`, `docs/costs.md`.
- `diagrams/architecture.py` — diagrams-as-code source.
- `.github/workflows/terraform.yml` — fmt, validate, tflint and checkov.

### Notes

- Exam domain weights used for the module split are from the published 1Z0-1072-25
  objectives (Networking 35%, Storage 25%, Compute 20%, IAM 20%). The 2026 blueprint
  is expected to match.