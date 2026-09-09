# Azure Terraform Security Remediation

## Executive Summary

The fictional Azure banking environment was assessed with Checkov before and
after security remediation.

The vulnerable baseline contained 45 failed checks. The remediated Terraform
configuration completed the assessment with zero failed checks and one
documented scanner exception.

| Assessment | Passed | Failed | Skipped |
|---|---:|---:|---:|
| Vulnerable baseline | 15 | 45 | 0 |
| Remediated configuration | 61 | 0 | 1 |
| Improvement | — | 45 findings resolved | 1 documented exception |

> The remediated configuration includes additional defensive resources, so the
> number of evaluated checks is higher than in the vulnerable baseline.

## Remediation Summary

| Security Area | Vulnerable State | Remediated State |
|---|---|---|
| Storage transport | HTTPS disabled and TLS 1.0 allowed | HTTPS enforced and TLS 1.2 required |
| Storage exposure | Public network and blob access enabled | Public access disabled with private endpoint |
| Storage authentication | Shared keys enabled | Microsoft Entra authentication set as default and shared keys disabled |
| Storage encryption | Platform encryption only | Infrastructure encryption and customer-managed HSM key |
| Storage resilience | Local replication and no recovery controls | Geo-redundancy, versioning, soft delete and lifecycle retention |
| Key Vault access | Public access with default allow | Public access disabled with default-deny networking |
| Key Vault recovery | Purge protection disabled | 90-day soft delete and purge protection |
| Key management | No managed rotation or expiration | HSM-backed keys with rotation and expiration |
| Azure SQL access | Public server and Internet firewall rule | Public access disabled with private endpoint |
| Azure SQL identity | SQL administrator credentials | Microsoft Entra-only authentication |
| Azure SQL encryption | TDE disabled | Customer-managed TDE with automatic rotation |
| Azure SQL resilience | No zone redundancy | Business Critical tier, zone redundancy and long-term backups |
| Azure SQL monitoring | Insufficient auditing | Audit, threat detection and security alerts enabled |
| AKS endpoint | Public control plane | Private AKS cluster |
| AKS identity | Local accounts and weak RBAC | Local accounts disabled with Entra and Azure RBAC |
| AKS networking | Kubenet without Network Policy | Azure CNI and Azure Network Policy |
| AKS secrets | No rotation controls | Key Vault CSI secret rotation enabled |
| AKS monitoring | Azure Monitor disabled | Azure Monitor, Defender and control-plane diagnostics |
| AKS node security | Managed OS disks | Ephemeral, encrypted and FIPS-enabled OS disks |
| AKS maintenance | No upgrade channel | Stable Kubernetes and security-patch channels |

## Storage Security

The remediated storage configuration implements:

- HTTPS-only access
- Minimum TLS 1.2
- Disabled anonymous blob access
- Disabled public network access
- Disabled shared-key authentication
- Microsoft Entra authentication by default
- Customer-managed HSM-backed encryption
- Infrastructure encryption
- Geo-redundant storage
- Blob versioning and change feed
- Soft-delete retention
- Lifecycle management
- Private endpoint connectivity
- Read, write and delete diagnostic logging

## Key Vault Security

Key Vault protections include:

- Public network access disabled
- Default-deny network rules
- Private endpoint connectivity
- RBAC authorization
- Purge protection
- 90-day soft-delete retention
- Premium HSM-backed keys
- Defined key expiration
- Automatic key rotation
- Audit logging to Log Analytics

## Azure SQL Security

The Azure SQL environment uses:

- Private endpoint access
- Public network access disabled
- TLS 1.2
- Microsoft Entra-only administration
- Customer-managed transparent data encryption
- Automatic key rotation
- Zone redundancy
- Ledger integrity protection
- Short-term and long-term backup retention
- Extended auditing
- Threat detection
- Security alerts
- Diagnostic logging

## AKS Security

The hardened AKS cluster includes:

- Private API server
- Microsoft Entra integration
- Azure RBAC
- Local administrator accounts disabled
- Azure Policy
- Azure CNI
- Azure Network Policy
- Workload Identity
- OIDC issuer
- Key Vault CSI secret rotation
- Microsoft Defender
- Azure Monitor
- Control-plane diagnostic logging
- Ephemeral OS disks
- Disk Encryption Set
- Host encryption
- FIPS-enabled nodes
- Automatic Kubernetes and node security updates

## Documented Checkov Exception

### CKV2_AZURE_21

Checkov expects the legacy `azurerm_log_analytics_storage_insights` resource to
associate Blob Storage logging with the private container.

That legacy integration relies on storage-account shared-key authentication.
Shared-key authentication is intentionally disabled in the remediated design.

The modern configuration instead uses `azurerm_monitor_diagnostic_setting` and
explicitly sends the following events to Log Analytics:

- StorageRead
- StorageWrite
- StorageDelete
- Transaction metrics

The exception therefore avoids weakening authentication solely to satisfy an
outdated graph relationship in the scanner.

## Validation Result

| Metric | Result |
|---|---:|
| Passed checks | 61 |
| Failed checks | 0 |
| Skipped checks | 1 |
| Baseline findings resolved | 45 |

## Security Engineering Conclusion

The assessment demonstrates a complete Azure security remediation lifecycle:

1. Preserve an intentionally vulnerable Azure baseline
2. Generate repeatable Checkov evidence
3. Identify cloud attack paths
4. Implement private connectivity and strong identity controls
5. Add customer-managed encryption and recovery protections
6. Enable centralized monitoring and audit retention
7. Rescan and confirm zero failed checks
8. Document scanner limitations without weakening the architecture

The Terraform is intended for static security analysis and portfolio
demonstration. Production deployment would require organization-specific
subscriptions, identities, DNS zones, network routing, tested recovery
procedures and formal change approval.