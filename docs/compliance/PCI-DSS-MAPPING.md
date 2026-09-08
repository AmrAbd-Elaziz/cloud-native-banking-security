# PCI DSS Security Control Mapping

## 1. Purpose

This document maps the fictional cloud-native banking security architecture
to the twelve principal PCI DSS v4.0.1 requirements.

This is a portfolio-level security control mapping for an authorized training
environment. It is not a PCI DSS certification, Report on Compliance,
Self-Assessment Questionnaire or formal compliance assessment.

---

## 2. Scope Assumptions

The fictional platform processes payment-related requests but does not store
real cardholder data.

The following components are considered potentially in scope:

- Web Application Firewall
- API Gateway
- Identity Provider
- Kubernetes ingress
- Payment Service
- Transfer Service
- Message queue
- Banking database
- Secrets Manager and KMS
- Logging and SIEM
- CI/CD pipeline
- Container registry
- Administrative access paths

Scope must be validated through formal data-flow analysis before any real
payment implementation.

---

## 3. PCI DSS Requirements Mapping

| Requirement | Objective | Project Controls | Planned Evidence | Status |
|---|---|---|---|---|
| 1 | Install and maintain network security controls | WAF, API Gateway, private subnets, Kubernetes Network Policies and restricted database access | Architecture diagram, firewall rules, Network Policies and IaC scan | Planned |
| 2 | Apply secure configurations to all system components | Hardened containers, non-root workloads, read-only filesystems, approved base images and configuration baselines | Kubernetes manifests, Dockerfile assessment and policy scan | Planned |
| 3 | Protect stored account data | Encryption at rest, KMS-managed keys, data minimization, retention controls and restricted database access | Encryption configuration, IAM review and data-classification records | Planned |
| 4 | Protect cardholder data with strong cryptography during transmission | TLS for external and internal sensitive communication, managed certificates and private service connectivity | TLS configuration, architecture review and endpoint validation | Planned |
| 5 | Protect systems and networks from malicious software | Container scanning, approved images, runtime monitoring and controlled package sources | Trivy report, image inventory and runtime policy | Planned |
| 6 | Develop and maintain secure systems and software | Threat modeling, secure code practices, SAST, SCA, IaC scanning, dependency management and security gates | STRIDE model, pipeline reports, SBOM and remediation evidence | In Progress |
| 7 | Restrict access by business need to know | Least-privilege cloud IAM, Kubernetes RBAC, service identities and restricted secret access | IAM policies, RBAC manifests and access-review evidence | Planned |
| 8 | Identify users and authenticate access | Unique accounts, MFA, short-lived tokens, workload identity and prohibited shared administrator accounts | Identity configuration, token-validation tests and access records | Planned |
| 9 | Restrict physical access to cardholder data | Cloud-provider physical security responsibilities and organizational access procedures | Shared-responsibility documentation and provider assurance reports | Out of Technical Lab Scope |
| 10 | Log and monitor access to systems and cardholder data | Central logging, Kubernetes audit logs, cloud activity logs, transaction audit events and SIEM alerting | Log samples, alert rules, retention configuration and access records | Planned |
| 11 | Test security systems and processes regularly | Vulnerability scanning, penetration testing, configuration scanning, policy validation and remediation retesting | SAST, IaC, Kubernetes, container and DAST reports | Planned |
| 12 | Support information security with organizational policies and programs | Risk register, architecture review, incident procedures, ownership and periodic review | Risk register, review approvals and documented procedures | In Progress |

---

## 4. Technical Control Mapping

### Network Security

Controls:

- Public traffic enters through the WAF and API Gateway
- Kubernetes worker nodes remain private
- Databases have no public endpoints
- Network Policies restrict east-west traffic
- Administrative access uses controlled identity-based access

Related requirements:

- Requirement 1
- Requirement 7
- Requirement 8

### Secure Software Development

Controls:

- STRIDE threat modeling
- Security architecture review
- SAST and secrets scanning
- Dependency and container scanning
- Infrastructure as Code scanning
- Security gates in CI/CD
- Remediation validation

Related requirements:

- Requirement 6
- Requirement 11
- Requirement 12

### Data Protection

Controls:

- Data minimization
- Encryption at rest
- Encryption in transit
- Centralized key management
- Restricted database access
- Sensitive-data masking in logs

Related requirements:

- Requirement 3
- Requirement 4
- Requirement 7
- Requirement 10

### Identity and Access Management

Controls:

- Unique user identities
- Administrator MFA
- Customer MFA support
- Short-lived access tokens
- Workload identity
- Least-privilege IAM and RBAC
- Periodic access review

Related requirements:

- Requirement 7
- Requirement 8
- Requirement 10

### Monitoring and Testing

Controls:

- Cloud activity logging
- Kubernetes audit logging
- Application security events
- Central SIEM monitoring
- Vulnerability assessment
- Penetration testing
- Configuration and policy scanning

Related requirements:

- Requirement 10
- Requirement 11
- Requirement 12

---

## 5. Evidence Plan

The project will produce:

1. Cloud and Kubernetes architecture diagram
2. Data-flow and trust-boundary documentation
3. STRIDE threat model
4. Risk register
5. Security architecture review
6. Vulnerable IaC scan reports
7. Remediated IaC scan reports
8. Kubernetes security scan reports
9. Container vulnerability reports
10. CycloneDX SBOM
11. Secrets scan report
12. GitHub Actions security-pipeline evidence
13. Remediation comparison
14. Residual-risk assessment

---

## 6. Shared Responsibility

The cloud provider is responsible for security of the underlying cloud
infrastructure, including defined physical and environmental controls.

The project owner remains responsible for security in the cloud, including:

- Identity and access configuration
- Network configuration
- Kubernetes workloads
- Application security
- Data protection
- Logging and monitoring
- Vulnerability management
- Incident response
- Compliance evidence

Cloud-provider compliance does not automatically make the deployed banking
application compliant.

---

## 7. Current Gaps

The following controls remain to be implemented and validated:

- Cloud IAM policies
- Private network infrastructure
- Kubernetes RBAC
- Kubernetes Network Policies
- Workload hardening
- Secrets Manager integration
- Encryption controls
- Central audit logging
- Security monitoring alerts
- Automated IaC and Kubernetes scanning
- Container signing and verification
- Remediation and retesting evidence

---

## 8. Compliance Statement

This mapping demonstrates security-design awareness and control traceability.

A real PCI DSS assessment would require:

- Confirmed cardholder data environment scope
- Formal evidence collection
- Operational process testing
- Interviews with control owners
- Sampling and technical validation
- Approved compensating controls
- Assessment by appropriately authorized personnel