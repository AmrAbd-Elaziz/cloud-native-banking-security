# STRIDE Threat Model

## 1. Purpose

This document applies the STRIDE methodology to the fictional cloud-native
banking platform.

The objective is to identify threats across users, APIs, Kubernetes workloads,
cloud services, databases, secrets management and CI/CD components before
implementation.

This threat model contains no real banking data or production infrastructure.

---

## 2. STRIDE Categories

| Category | Security Property | Example |
|---|---|---|
| Spoofing | Authentication | Attacker uses stolen credentials or forged tokens |
| Tampering | Integrity | Attacker modifies a payment or deployment artifact |
| Repudiation | Accountability | User denies performing a financial transaction |
| Information Disclosure | Confidentiality | Sensitive customer data is exposed |
| Denial of Service | Availability | API or service becomes unavailable |
| Elevation of Privilege | Authorization | User gains administrator or cluster privileges |

---

## 3. Security Scope

The threat model covers:

- Customer web and mobile clients
- Bank operations administrators
- DNS and CDN
- Web Application Firewall
- Identity Provider and MFA
- API Gateway
- Kubernetes ingress
- Account Service
- Transfer Service
- Payment Service
- Audit Service
- Banking database
- Message queue
- Secrets Manager and KMS
- Central logging and SIEM
- Container registry
- CI/CD pipeline

---

# 4. Identified Threats

## Spoofing Threats

### TM-S-01: Credential Stuffing Against Customer Login

**Target:** Identity Provider

**Scenario:**  
An attacker uses credentials obtained from previous data breaches to attempt
automated login against customer accounts.

**Potential Impact:**

- Customer account takeover
- Unauthorized access to balances and transactions
- Fraudulent transfer attempts
- Customer trust and regulatory impact

**Security Controls:**

- Multi-factor authentication
- Rate limiting
- Bot detection
- Risk-based authentication
- Failed-login monitoring
- Breached-password detection
- Account-lockout protection

---

### TM-S-02: Forged or Replayed Access Token

**Target:** API Gateway and banking APIs

**Scenario:**  
An attacker submits a forged, expired, incorrectly signed or previously stolen
access token.

**Potential Impact:**

- Unauthorized API access
- Customer impersonation
- Access to financial information
- Fraudulent transactions

**Security Controls:**

- Validate token signature
- Restrict accepted algorithms
- Validate issuer and audience
- Enforce token expiration
- Use short-lived access tokens
- Protect refresh tokens
- Implement token revocation where required
- Prevent tokens from appearing in logs

---

### TM-S-03: Workload Identity Spoofing

**Target:** Kubernetes microservices

**Scenario:**  
A compromised workload attempts to impersonate another service when connecting
to internal APIs or cloud services.

**Potential Impact:**

- Unauthorized service-to-service access
- Access to secrets
- Financial data exposure
- Lateral movement

**Security Controls:**

- Dedicated Kubernetes service accounts
- Workload identity
- Mutual TLS where appropriate
- Short-lived credentials
- Network Policies
- Service-level authorization
- Disable automatic service-account token mounting when unnecessary

---

## Tampering Threats

### TM-T-01: Transfer Parameter Manipulation

**Target:** Transfer Service

**Scenario:**  
An authenticated customer modifies account identifiers, transfer amounts or
recipient information to perform an unauthorized transaction.

**Potential Impact:**

- Financial fraud
- Unauthorized transfers
- Account balance manipulation
- Regulatory impact

**Security Controls:**

- Server-side authorization
- Validate account ownership
- Transaction limits
- Strong input validation
- Transaction integrity checks
- Idempotency keys
- Fraud-detection rules
- Complete audit logging

---

### TM-T-02: Message Queue Event Tampering

**Target:** Payment queue and Audit Service

**Scenario:**  
An attacker modifies, duplicates or injects payment events into the message
queue.

**Potential Impact:**

- Duplicate payments
- Incorrect audit records
- Fraudulent transaction processing
- Loss of data integrity

**Security Controls:**

- Queue access policies
- Encryption in transit
- Message integrity protection
- Unique event identifiers
- Replay detection
- Idempotent consumers
- Dead-letter queues
- Producer and consumer authentication

---

### TM-T-03: Container Image or Dependency Tampering

**Target:** CI/CD pipeline and container registry

**Scenario:**  
A malicious dependency or modified container image enters the software supply
chain.

**Potential Impact:**

- Backdoored banking services
- Credential theft
- Cluster compromise
- Data exfiltration

**Security Controls:**

- Pin dependencies and GitHub Actions
- Dependency cooldown periods
- Generate SBOMs
- Scan dependencies and container images
- Sign container images
- Verify signatures before deployment
- Use protected branches
- Restrict registry permissions
- Maintain immutable deployment artifacts

---

### TM-T-04: Infrastructure as Code Manipulation

**Target:** Terraform and Kubernetes manifests

**Scenario:**  
An unauthorized change makes a database public, grants excessive IAM access or
deploys a privileged container.

**Potential Impact:**

- Public exposure of banking services
- Excessive cloud privileges
- Cluster compromise
- Sensitive data disclosure

**Security Controls:**

- Pull-request review
- Branch protection
- IaC security scanning
- Policy-as-Code enforcement
- Least-privilege CI permissions
- Signed commits where required
- Terraform plan review
- Separate deployment approval

---

## Repudiation Threats

### TM-R-01: Customer Denies Initiating a Transfer

**Target:** Transfer Service and Audit Service

**Scenario:**  
A customer or attacker denies performing a financial transaction.

**Potential Impact:**

- Disputes and financial loss
- Inability to investigate fraud
- Compliance violations
- Weak legal evidence

**Security Controls:**

- Unique transaction identifier
- Authenticated user identity
- Accurate UTC timestamps
- Source and device metadata
- Tamper-resistant audit records
- Transaction confirmation
- Audit-log retention
- Restricted access to audit logs

---

### TM-R-02: Administrator Actions Are Not Traceable

**Target:** Cloud, Kubernetes and banking administration

**Scenario:**  
Privileged changes occur without reliable attribution to an individual
administrator.

**Potential Impact:**

- Insider abuse
- Undetected configuration changes
- Weak incident investigation
- Audit and compliance failure

**Security Controls:**

- Individual administrator accounts
- MFA
- Privileged access management
- Just-in-time access
- Cloud activity logging
- Kubernetes audit logging
- Administrative session recording where appropriate
- Prohibit shared administrator accounts

---

## Information Disclosure Threats

### TM-I-01: Broken Object Level Authorization

**Target:** Account Service and transaction APIs

**Scenario:**  
An authenticated customer changes an object identifier and accesses another
customer's account or transaction data.

**Potential Impact:**

- Exposure of financial information
- Privacy breach
- Regulatory penalties
- Customer trust impact

**Security Controls:**

- Object-level authorization on every request
- Derive customer identity from the validated token
- Do not trust customer identifiers from the client
- Negative authorization testing
- Minimize response data
- Log denied access attempts

---

### TM-I-02: Secrets Exposed in Source Code or CI Logs

**Target:** Source repositories and CI/CD pipeline

**Scenario:**  
Cloud credentials, database passwords, API keys or tokens are committed to
source code or printed in pipeline logs.

**Potential Impact:**

- Cloud account compromise
- Database compromise
- Unauthorized deployments
- Data theft

**Security Controls:**

- Secrets scanning
- CI log masking
- Short-lived federated credentials
- External secrets management
- Secret rotation
- Pre-commit scanning
- Restrict artifact access
- Prevent secrets from being passed as command-line arguments

---

### TM-I-03: Sensitive Banking Data Appears in Logs

**Target:** Application logging and SIEM

**Scenario:**  
Passwords, tokens, full account numbers or payment data are written to logs.

**Potential Impact:**

- Sensitive data disclosure
- PCI DSS impact
- Expanded breach scope
- Insider misuse

**Security Controls:**

- Structured logging standards
- Data masking and redaction
- Prohibit passwords and tokens in logs
- Restrict SIEM access
- Encrypt log transport and storage
- Define log-retention periods
- Automated sensitive-data detection

---

### TM-I-04: Public Database or Storage Exposure

**Target:** Protected cloud data services

**Scenario:**  
A database, backup or storage service is accidentally exposed to the Internet.

**Potential Impact:**

- Large-scale customer data breach
- Financial information exposure
- Regulatory notification
- Business interruption

**Security Controls:**

- Private endpoints
- No public database addresses
- Network access controls
- Encryption at rest
- Cloud configuration scanning
- Continuous cloud posture monitoring
- Restricted backup access
- Automated policy enforcement

---

## Denial of Service Threats

### TM-D-01: API Resource Exhaustion

**Target:** WAF, API Gateway and Kubernetes workloads

**Scenario:**  
An attacker sends a large number of requests or computationally expensive
payloads to exhaust application resources.

**Potential Impact:**

- Customer service outage
- Increased cloud cost
- Payment-processing disruption
- Resource starvation

**Security Controls:**

- DDoS protection
- WAF rules
- Rate limiting
- Request-size restrictions
- API timeouts
- Kubernetes resource requests and limits
- Horizontal scaling
- Circuit breakers
- Availability monitoring

---

### TM-D-02: Message Queue Flooding

**Target:** Payment queue

**Scenario:**  
A compromised or abusive producer floods the queue with invalid or duplicate
payment events.

**Potential Impact:**

- Delayed payment processing
- Increased operational cost
- Service instability
- Audit-processing backlog

**Security Controls:**

- Producer authorization
- Queue quotas
- Message-size limits
- Rate limiting
- Dead-letter queues
- Consumer autoscaling
- Duplicate-event detection
- Monitoring and alerting

---

## Elevation of Privilege Threats

### TM-E-01: Excessive Kubernetes RBAC

**Target:** Kubernetes cluster

**Scenario:**  
A compromised workload uses excessive RBAC permissions to access secrets,
modify workloads or gain cluster administration.

**Potential Impact:**

- Cluster takeover
- Secret theft
- Deployment manipulation
- Lateral movement

**Security Controls:**

- Least-privilege RBAC
- Dedicated service accounts
- Prohibit wildcard permissions
- Restrict access to secrets
- Kubernetes audit logging
- Periodic RBAC review
- Admission-control policies
- Disable unnecessary token mounting

---

### TM-E-02: Privileged Container Escape

**Target:** Kubernetes worker nodes

**Scenario:**  
An attacker compromises a privileged container and attempts to access the host
or other workloads.

**Potential Impact:**

- Node compromise
- Cluster-wide compromise
- Credential theft
- Banking-service disruption

**Security Controls:**

- Run as non-root
- Prohibit privileged containers
- Drop Linux capabilities
- Read-only root filesystem
- Seccomp profiles
- AppArmor or SELinux
- No hostPath mounts
- No host network or host PID access
- Runtime security monitoring

---

### TM-E-03: Excessive Cloud IAM Permissions

**Target:** AWS or Azure cloud environment

**Scenario:**  
A workload or CI/CD identity has broad permissions and is used to modify cloud
resources or access protected data.

**Potential Impact:**

- Cloud account compromise
- Data exfiltration
- Security-control modification
- Destruction of infrastructure

**Security Controls:**

- Least-privilege IAM
- Separate workload identities
- Short-lived credentials
- Workload identity federation
- Permission boundaries
- Privileged access approval
- Cloud activity monitoring
- Periodic access review

---

## 5. Threat Summary

| STRIDE Category | Threat IDs | Count |
|---|---|---:|
| Spoofing | TM-S-01 to TM-S-03 | 3 |
| Tampering | TM-T-01 to TM-T-04 | 4 |
| Repudiation | TM-R-01 to TM-R-02 | 2 |
| Information Disclosure | TM-I-01 to TM-I-04 | 4 |
| Denial of Service | TM-D-01 to TM-D-02 | 2 |
| Elevation of Privilege | TM-E-01 to TM-E-03 | 3 |
| **Total** |  | **18** |

---

## 6. Initial Security Priorities

The initial highest-priority risks are:

1. Broken object-level authorization
2. Transfer parameter manipulation
3. Excessive Kubernetes RBAC
4. Privileged container execution
5. Exposed secrets and cloud credentials
6. Public database or storage exposure
7. Container image and dependency tampering
8. Excessive cloud IAM permissions

These threats will be evaluated and prioritized in the project risk register.