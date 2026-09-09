# Vulnerable Azure Terraform Security Baseline

## Assessment Summary

Checkov was used to assess the intentionally vulnerable Azure Terraform
configuration before remediation.

The configuration represents a fictional banking environment created only for
authorized security training. It must not be deployed to a real Azure
subscription.

| Metric | Result |
|---|---:|
| Passed checks | 15 |
| Failed checks | 45 |
| Skipped checks | 0 |
| Total evaluated checks | 60 |

## Finding Categories

| Security Area | Findings | Primary Risks |
|---|---:|---|
| Azure Kubernetes Service | 15 | Public control plane, weak identity controls, missing monitoring and network policy |
| Storage security | 13 | Public financial data, weak TLS, shared keys and insufficient resilience |
| Azure SQL security | 11 | Public database exposure, weak TLS, insufficient auditing and resilience |
| Key Vault security | 5 | Public access, missing purge protection and insufficient network isolation |
| Network security | 1 | Public administrative and database access |
| **Total** | **45** | |

## Critical Attack Paths

### Public Storage of Financial Data

The transaction-log storage account permits public network access and allows
nested objects to become publicly accessible.

The associated container uses public blob access.

Additional weaknesses include:

- HTTPS-only access disabled
- TLS 1.0 permitted
- Shared access keys enabled
- Infrastructure encryption disabled
- Cross-tenant replication enabled
- Insufficient network restrictions
- Insufficient recovery and replication controls

An attacker could potentially access, modify or exfiltrate fictional financial
transaction records.

### Exposed AKS Control Plane

The AKS API server is publicly accessible from `0.0.0.0/0`.

The cluster also lacks:

- Private-cluster enforcement
- Azure RBAC controls
- Disabled local administrator accounts
- Azure Policy integration
- Network Policy
- Azure CNI networking
- Azure Monitor integration
- Controlled upgrade channels
- Secrets Store CSI rotation
- Additional workload and control-plane protections

A compromised local credential or exposed API could provide a path into the
banking container platform.

### Public Azure SQL Database

The Azure SQL server permits public network access and has an Internet-wide
firewall rule.

The database configuration also includes:

- TLS 1.0
- No private endpoint
- Disabled transparent data encryption
- No zone redundancy
- No ledger integrity protection
- Insufficient audit retention
- Insufficient threat detection and security monitoring

This creates confidentiality, integrity and availability risks for fictional
cardholder data.

### Weak Key Vault Isolation

The Key Vault permits public access and uses a network policy with the default
action set to allow.

Additional weaknesses include:

- Purge protection disabled
- Short soft-delete retention
- Legacy access-control configuration
- Insufficient network isolation
- Missing private connectivity controls

Compromise of the vault could expose application secrets, encryption material
or service credentials.

### Permissive Network Security

The Network Security Group contains rules intended to expose administrative or
database services to untrusted networks.

Public SSH and SQL access significantly increase brute-force, exploitation and
unauthorized-access risks.

## Banking and PCI DSS Relevance

| Security Concern | Banking Impact | PCI DSS Control Theme |
|---|---|---|
| Public storage | Exposure of transaction and audit information | Protect stored account data |
| Public AKS endpoint | Increased platform attack surface | Secure system configurations |
| Weak identity controls | Unauthorized cluster administration | Restrict access by business need |
| Public Azure SQL | Direct exposure of financial databases | Network security controls |
| TLS 1.0 | Weak protection for data in transit | Strong cryptography |
| Missing audit controls | Limited detection and investigation | Log and monitor access |
| Public Key Vault | Exposure of credentials and keys | Protect cryptographic keys |
| Open NSG rules | Unauthorized connectivity | Restrict inbound and outbound traffic |
| Missing resilience | Increased outage and data-loss risk | Operational resilience |

## Risk Conclusion

The vulnerable Azure Terraform configuration must not be deployed.

The combination of public storage, an exposed AKS control plane, public Azure
SQL, weak Key Vault isolation and permissive network access creates multiple
credible paths to cloud compromise and financial-data exposure.

The remediation phase will create a separate hardened Azure configuration,
preserving this baseline for comparison and audit evidence.