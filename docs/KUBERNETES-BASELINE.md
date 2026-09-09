# Vulnerable Kubernetes Security Baseline

## Assessment Summary

Checkov was used to assess the intentionally vulnerable Kubernetes banking
workload before remediation.

| Metric | Result |
|---|---:|
| Passed checks | 72 |
| Failed checks | 32 |
| Skipped checks | 0 |
| Total evaluated checks | 104 |

## Finding Categories

| Category | Findings | Key Risks |
|---|---:|---|
| RBAC and privilege escalation | 10 | Cluster-wide wildcard access, secret access, impersonation and role escalation |
| Container and pod hardening | 13 | Root execution, privileged mode, host access, excessive capabilities and missing seccomp |
| Resource and health management | 6 | Missing CPU and memory controls and missing health probes |
| Container image security | 2 | Mutable latest tag and missing immutable image digest |
| Network segmentation | 1 | No NetworkPolicy associated with the workload |
| **Total** | **32** | |

## Highest-Risk Findings

### Wildcard ClusterRole

The workload received wildcard permissions for every API group, resource and
verb. Compromise of the service account could lead to complete cluster
takeover.

Related checks:

- CKV_K8S_49
- CKV_K8S_156
- CKV_K8S_157
- CKV_K8S_158
- CKV2_K8S_1
- CKV2_K8S_2
- CKV2_K8S_3
- CKV2_K8S_4
- CKV2_K8S_5

### Privileged Root Container

The container runs as UID 0 with privileged mode, privilege escalation and all
Linux capabilities enabled.

Related checks:

- CKV_K8S_16
- CKV_K8S_20
- CKV_K8S_23
- CKV_K8S_25
- CKV_K8S_28
- CKV_K8S_37
- CKV_K8S_40

### Host Access

The workload shares the host network and process namespaces and mounts the
host root filesystem. A container compromise could directly affect the
Kubernetes worker node.

Related checks:

- CKV_K8S_17
- CKV_K8S_19

### Missing Workload Isolation

The workload has no associated NetworkPolicy, allowing unrestricted network
communication depending on the cluster networking configuration.

Related check:

- CKV2_K8S_6

### Missing Availability Controls

CPU and memory requests and limits are missing. Liveness and readiness probes
are also absent.

Related checks:

- CKV_K8S_8
- CKV_K8S_9
- CKV_K8S_10
- CKV_K8S_11
- CKV_K8S_12
- CKV_K8S_13

### Mutable Container Image

The workload uses `nginx:latest` without an immutable digest. A future image
change could introduce unreviewed or malicious code.

Related checks:

- CKV_K8S_14
- CKV_K8S_43

## Risk Conclusion

The vulnerable workload must not be deployed.

The combination of wildcard RBAC, privileged root execution, host access,
service-account token mounting and unrestricted networking creates a credible
cluster-takeover path.

The next phase will create a separate remediated manifest and validate the
security improvements through repeatable Checkov scanning.