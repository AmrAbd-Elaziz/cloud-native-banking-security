# Vulnerable AWS Terraform Security Baseline

## Assessment Summary

Checkov was used to assess the intentionally vulnerable AWS Terraform
configuration before remediation.

The configuration represents a fictional cloud-native banking environment and
must not be deployed to a real AWS account.

| Metric | Result |
|---|---:|
| Passed checks | 17 |
| Failed checks | 40 |
| Skipped checks | 0 |
| Total evaluated checks | 57 |

## Finding Categories

| Security Area | Findings | Primary Risks |
|---|---:|---|
| S3 data protection | 13 | Public financial data, missing encryption, logging, versioning and lifecycle controls |
| RDS database security | 10 | Public database exposure, unencrypted data and insufficient resilience |
| IAM least privilege | 9 | Administrative access, privilege escalation and data exfiltration |
| EKS control plane | 4 | Public API exposure, missing secrets encryption and incomplete logging |
| CloudWatch logging | 2 | Short retention and missing KMS encryption |
| Network security | 2 | Public SSH access and unrestricted outbound traffic |
| **Total** | **40** | |

## Critical Attack Paths

### Public S3 Financial Data

The transaction log bucket allows public-read access and disables every S3
public-access-block control.

The bucket also lacks:

- KMS encryption
- Versioning
- Access logging
- Cross-region replication
- Lifecycle management
- Event notifications
- Bucket-owner-enforced object ownership

A malicious or accidental public exposure could disclose fictional financial
transaction records.

Related checks include:

- CKV_AWS_20
- CKV_AWS_53
- CKV_AWS_54
- CKV_AWS_55
- CKV_AWS_56
- CKV_AWS_145
- CKV2_AWS_6
- CKV2_AWS_65

### Excessive IAM Permissions

The banking API IAM policy permits every AWS action against every AWS
resource.

A compromised workload identity could:

- Access sensitive data
- Create or modify credentials
- Escalate privileges
- Modify security controls
- Exfiltrate information
- Take control of the AWS account

Related checks include:

- CKV_AWS_62
- CKV_AWS_63
- CKV_AWS_286
- CKV_AWS_287
- CKV_AWS_288
- CKV_AWS_289
- CKV_AWS_290
- CKV_AWS_355
- CKV2_AWS_40

### Public and Unencrypted Database

The fictional banking RDS database is publicly accessible and does not encrypt
stored data.

It also lacks:

- Backup retention
- Multi-AZ resilience
- Deletion protection
- IAM database authentication
- Enhanced monitoring
- Database log exports
- Automatic minor-version upgrades
- Snapshot tag propagation

A compromise or operational failure could cause unauthorized access, data loss
or extended service disruption.

Related checks include:

- CKV_AWS_16
- CKV_AWS_17
- CKV_AWS_118
- CKV_AWS_129
- CKV_AWS_133
- CKV_AWS_157
- CKV_AWS_161
- CKV_AWS_226
- CKV_AWS_293
- CKV2_AWS_60

### Exposed EKS Control Plane

The EKS control-plane endpoint is publicly accessible from `0.0.0.0/0`.

The cluster also lacks:

- Kubernetes secrets encryption using KMS
- Private endpoint access
- Complete control-plane logging

This increases the attack surface and reduces the available evidence for
security monitoring and incident response.

Related checks:

- CKV_AWS_37
- CKV_AWS_38
- CKV_AWS_39
- CKV_AWS_58

### Insufficient Network Restrictions

The database security group permits SSH access from the entire Internet and
allows unrestricted outbound communication.

A compromised resource could establish arbitrary outbound connections or be
used for data exfiltration.

Related checks:

- CKV_AWS_24
- CKV_AWS_382

### Insufficient Audit-Log Protection

The CloudWatch log group retains logs for only one day and does not use a
customer-managed KMS key.

This could prevent effective investigation of delayed security incidents and
does not provide adequate protection for sensitive audit evidence.

Related checks:

- CKV_AWS_158
- CKV_AWS_338

## Banking and PCI DSS Relevance

| Security Concern | Banking Impact | PCI DSS Control Theme |
|---|---|---|
| Public S3 access | Disclosure of transaction and audit data | Protect stored account data |
| Wildcard IAM policy | Unauthorized administrative activity | Restrict access by business need |
| Public RDS database | Direct exposure of financial systems | Protect systems from untrusted networks |
| Missing encryption | Exposure of stored sensitive data | Strong cryptography |
| Public EKS endpoint | Increased control-plane attack surface | Secure system configurations |
| Insufficient logging | Reduced detection and investigation capability | Log and monitor access |
| Missing backups | Data loss and availability risk | Resilience and recovery |
| Open network rules | Unauthorized connectivity and exfiltration | Network security controls |

## Risk Conclusion

The vulnerable Terraform configuration must not be deployed.

The combination of public data storage, unrestricted IAM permissions, public
database access, an Internet-accessible EKS control plane and insufficient
logging creates multiple credible paths to financial-data exposure and cloud
account compromise.

The remediation phase will create a separate hardened Terraform configuration,
preserving this baseline for comparison and audit evidence.