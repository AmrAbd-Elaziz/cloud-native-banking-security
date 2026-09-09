# Kubernetes Security Remediation

## Executive Summary

The intentionally vulnerable Kubernetes banking workload was assessed with
Checkov, remediated through defensive configuration changes and scanned again.

The baseline contained 32 failed security checks. The remediated workload
completed the assessment with zero failed checks.

| Assessment | Passed | Failed | Skipped |
|---|---:|---:|---:|
| Vulnerable baseline | 72 | 32 | 0 |
| Remediated configuration | 93 | 0 | 0 |
| Improvement | — | 32 findings resolved | — |

> The number of evaluated checks changed because dangerous RBAC resources were
> removed instead of being retained in the remediated architecture.

## Remediation Details

| Security Area | Vulnerable State | Remediated State |
|---|---|---|
| RBAC | Wildcard cluster-wide permissions | Unnecessary ClusterRole and ClusterRoleBinding removed |
| Service account | Token automatically mounted | Token automount explicitly disabled |
| Container image | Mutable `nginx:latest` image | Image pinned to an immutable SHA-256 digest |
| User identity | Container executed as root | Container runs as a non-root high UID |
| Privileged mode | Privileged container enabled | Privileged execution explicitly disabled |
| Privilege escalation | Escalation permitted | `allowPrivilegeEscalation` set to false |
| Linux capabilities | All capabilities added | All capabilities dropped |
| Root filesystem | Writable filesystem | Read-only root filesystem enabled |
| Seccomp | No seccomp profile | `RuntimeDefault` seccomp profile applied |
| Host namespaces | Host network and PID shared | Host namespace sharing disabled |
| Host filesystem | Host root filesystem mounted | HostPath volume removed |
| Resource governance | No CPU or memory controls | Requests and limits configured |
| Health monitoring | No health probes | Readiness and liveness probes configured |
| External exposure | Direct LoadBalancer service | Internal ClusterIP service |
| Network isolation | No NetworkPolicy | Default-deny and explicitly allowed traffic policies |
| Namespace controls | No Pod Security controls | Restricted Pod Security labels configured |

## Supply Chain Protection

The remediated deployment uses the following immutable image reference:

```text
nginxinc/nginx-unprivileged@sha256:442753882674b49ae2c1de83ed67896131c0777f56df5005e356e62bc3f7e7ce