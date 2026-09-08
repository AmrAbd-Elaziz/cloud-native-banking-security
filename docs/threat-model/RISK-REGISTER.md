# Cloud-Native Banking Risk Register

## 1. Purpose

This risk register prioritizes the security threats identified during the
STRIDE threat-modeling exercise for the fictional cloud-native banking
platform.

Inherent risk represents the risk before controls. Residual risk represents
the estimated risk after the proposed controls are implemented.

---

## 2. Risk Scoring

Risk is calculated using:

`Risk Score = Likelihood × Impact`

### Likelihood

| Rating | Description |
|---:|---|
| 1 | Rare |
| 2 | Unlikely |
| 3 | Possible |
| 4 | Likely |
| 5 | Almost Certain |

### Impact

| Rating | Description |
|---:|---|
| 1 | Insignificant |
| 2 | Minor |
| 3 | Moderate |
| 4 | Major |
| 5 | Severe |

### Severity

| Score | Severity | Response |
|---:|---|---|
| 1–4 | Low | Accept or monitor |
| 5–9 | Medium | Planned remediation |
| 10–16 | High | Prioritized remediation |
| 17–25 | Critical | Treatment required before production |

---

## 3. Risk Register

| Risk ID | Threat ID | Risk | Likelihood | Impact | Score | Severity | Treatment | Owner | Residual |
|---|---|---|---:|---:|---:|---|---|---|---:|
| R-01 | TM-I-01 | Broken object-level authorization exposes another customer's financial data | 4 | 5 | 20 | Critical | Enforce object-level authorization and negative access-control testing | Application Security | 6 |
| R-02 | TM-T-01 | Transfer parameters are manipulated to perform an unauthorized transaction | 4 | 5 | 20 | Critical | Validate account ownership, enforce transaction limits and use idempotency controls | Payments Team | 8 |
| R-03 | TM-E-03 | Excessive cloud IAM permissions allow access to protected resources | 4 | 5 | 20 | Critical | Apply least privilege, workload federation and permission boundaries | Cloud Security | 6 |
| R-04 | TM-I-04 | A database, backup or storage service is accidentally exposed publicly | 3 | 5 | 15 | High | Use private endpoints and continuously enforce public-access restrictions | Cloud Platform | 5 |
| R-05 | TM-E-01 | Excessive Kubernetes RBAC permits secret access or workload modification | 4 | 4 | 16 | High | Use dedicated service accounts and least-privilege RBAC | Kubernetes Platform | 6 |
| R-06 | TM-E-02 | A privileged container is used to compromise a Kubernetes worker node | 3 | 5 | 15 | High | Run as non-root, drop capabilities and prohibit privileged containers | Kubernetes Platform | 5 |
| R-07 | TM-I-02 | Secrets or credentials are exposed in source code, artifacts or CI logs | 4 | 5 | 20 | Critical | Use secrets scanning, log masking and short-lived credentials | DevSecOps | 6 |
| R-08 | TM-T-03 | A malicious dependency, Action or image compromises the software supply chain | 4 | 5 | 20 | Critical | Pin dependencies, apply cooldowns, generate SBOMs and verify signed images | DevSecOps | 8 |
| R-09 | TM-S-01 | Credential stuffing results in customer account takeover | 5 | 4 | 20 | Critical | Enforce MFA, rate limiting, bot protection and risk-based authentication | Identity Security | 8 |
| R-10 | TM-S-02 | A forged, expired, replayed or stolen token is accepted by an API | 4 | 5 | 20 | Critical | Validate signature, issuer, audience and expiry and use short-lived tokens | Identity Security | 6 |
| R-11 | TM-I-03 | Sensitive banking or authentication information is written to logs | 3 | 5 | 15 | High | Apply structured logging, masking, restricted access and retention controls | Security Operations | 5 |
| R-12 | TM-D-01 | Malicious requests exhaust API or Kubernetes resources | 4 | 4 | 16 | High | Apply DDoS protection, WAF rules, rate limits and resource limits | Cloud Operations | 6 |

---

## 4. Risk Priorities

### Priority 1: Fraud and Unauthorized Access

- R-01: Broken object-level authorization
- R-02: Transfer manipulation
- R-09: Credential stuffing
- R-10: Token forgery or replay

### Priority 2: Cloud and Kubernetes Compromise

- R-03: Excessive cloud IAM
- R-04: Public data-service exposure
- R-05: Excessive Kubernetes RBAC
- R-06: Privileged container execution

### Priority 3: Supply Chain and Information Disclosure

- R-07: Secrets exposure
- R-08: Software supply-chain compromise
- R-11: Sensitive data in logs

### Priority 4: Availability

- R-12: API resource exhaustion

---

## 5. Risk Treatment

The project supports four treatment options:

- **Mitigate:** Implement controls that reduce likelihood or impact
- **Avoid:** Remove the risky feature or architecture decision
- **Transfer:** Transfer defined exposure through contracts or insurance
- **Accept:** Formally approve and monitor the residual risk

All Critical and High risks identified in this project use the Mitigate
treatment strategy.

Critical risks must not be accepted without documented business and security
approval.

---

## 6. Risk Acceptance Criteria

A risk may only be accepted when:

1. The business impact is documented
2. Compensating controls are identified
3. Residual risk is within approved tolerance
4. An accountable owner approves the decision
5. A review or expiration date is assigned
6. Monitoring and alerting are available

---

## 7. Review Triggers

The risk register must be reviewed when:

- A new banking feature or API is introduced
- Authentication or authorization changes
- Cloud or Kubernetes architecture changes
- A third-party payment integration is added
- A security incident occurs
- A Critical or High vulnerability is identified
- Applicable regulatory requirements change
- The scheduled quarterly review becomes due

---

## 8. Current Status

All listed risks are currently in the `Planned` treatment stage.

The next project phases will create vulnerable Terraform and Kubernetes
configurations, validate the risks using security scanners, implement
remediation controls and reassess the residual risk.