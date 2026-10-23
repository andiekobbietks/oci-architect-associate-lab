# Costs

This repository can create billable resources. The figures below are a cost *model
shape*, not a quote. Prices change and depend on region, shape, and contractual
discounts. Always confirm against the OCI pricing page and the Cost Estimator for
your tenancy before applying.

## What the configuration can create

| Resource | Module | Billable? | Billing basis |
|---|---|---|---|
| Compartment, group, policy | `iam` | No | IAM is free |
| VCN, subnets, gateways, security lists, NSGs | `networking` | No | VCN components are free |
| Object Storage bucket | `storage` | Yes | GB stored + requests + egress |
| Block Volume, 50 GB | `storage` | Yes | GB-month provisioned |
| File Storage file system + mount target | `storage` | Yes | GB-month + mount target uptime |
| Instance, `VM.Standard.E4.Flex`, 1 OCPU / 8 GB | `compute` | Yes | OCPU-hour + GB-hour while running |
| Instance pool, 2 instances by default | `compute` | Yes | Same, doubled |

## Cost-control decisions already in the configuration

1. **Lifecycle policy on the bucket.** Objects archive at 30 days and delete at 365,
   rather than accumulating in Standard tier forever.
2. **Block Volume is not attached.** An unattached volume costs GB-month but no
   compute. Attach it only when testing.
3. **The pool size is a variable.** Set `pool_size = 0` to keep the configuration in
   the plan without running pooled instances.
4. **Object Storage bucket is private.** `NoPublicAccess` also avoids the class of
   surprise egress that comes with public buckets.

## The dominant cost is compute

Everything else is rounding error next to a running instance, because compute bills
per hour and storage bills per GB-month. The practical rules:

- `terraform destroy` when finished with a session.
- If a tenancy must stay up, stop or terminate instances; a stopped instance still
  bills for boot volume storage in most shapes.
- Prefer the Always Free tier resources for a portfolio demo where they fit.
- Free-tier tenancies have finite credits. `terraform apply` spends them.

## Guardrails worth adding

- **Budget + alert** in OCI Budgets, with a threshold well below the credit balance.
- **Compartment quota** to cap how much compute the compartment can create at once.
- **Tagging** — already applied here via the `managed_by = terraform` freeform tag,
  so cost reports can be filtered by this stack.

## Honest limitation

No figure in this document has been measured against a live bill. They describe what
the configuration *can* incur and which resources are the expensive ones. Before
applying, run the OCI Cost Estimator for the exact region and shape.