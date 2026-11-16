# Ticket 44 — Kubernetes Incident Simulation & Troubleshooting

## Objective

Practice Kubernetes incident detection, troubleshooting, root cause analysis (RCA), remediation, and recovery verification using a local k3d cluster.

**Environment:** Local k3d cluster (`devops-lab`)
**Incident namespaces:** `incident-lab`, `oom-lab`
**Scope:** Controlled laboratory simulations; no production incidents or AWS resources.

## Incident 01 — CrashLoopBackOff

### Symptoms

The `broken-api` Deployment experienced repeated container failures.

Observed evidence:

- Container exited with **Exit Code 1**.
- Pod entered **CrashLoopBackOff**.
- Restart count increased.
- Application logs reported a startup configuration error.

### Investigation

```bash
kubectl get pods -n incident-lab
kubectl describe pod -n incident-lab -l app=broken-api
kubectl logs -n incident-lab deployment/broken-api
kubectl logs -n incident-lab deployment/broken-api --previous
```

The `--previous` log retrieval was attempted but unavailable during the initial investigation. Current container logs were successfully retrieved.

### Root Cause

The original laboratory script unconditionally executed `exit 1`, simulating a missing `DATABASE_URL` configuration.

The initial error message was simulated rather than produced by an actual environment-variable validation.

### Remediation

Updated the startup script to validate `DATABASE_URL` and provided a dummy database URL for testing.

### Verification

```bash
kubectl rollout status deployment/broken-api -n incident-lab --timeout=120s
kubectl get pods -n incident-lab
kubectl logs -n incident-lab deployment/broken-api
```

**Confirmed result:**

- Deployment successfully rolled out.
- New pod reached `1/1 Running`.
- Zero restarts observed.
- Logs confirmed successful startup.

**Limitation:** Database connectivity and actual API functionality were not tested.

---

## Incident 02 — OOMKilled

### Symptoms

The `memory-hog` container repeatedly terminated and entered CrashLoopBackOff.

Observed evidence:

| Metric                             | Value     |
| ---------------------------------- | --------- |
| Last termination reason            | OOMKilled |
| Exit code                          | 137       |
| Restart count during investigation | 6         |
| Memory request                     | 32Mi      |
| Memory limit                       | 64Mi      |
| Attempted application allocation   | 128Mi     |

### Investigation

```bash
kubectl get pods -n oom-lab
kubectl describe pod -n oom-lab -l app=memory-hog
kubectl logs -n oom-lab deployment/memory-hog
kubectl get events -n oom-lab --sort-by=.lastTimestamp
```

Kubernetes reported `OOMKilled` and Exit Code 137. The container attempted to allocate more memory than its configured limit.

### Root Cause

The Python workload attempted a 128 MiB allocation while its container memory limit was 64 MiB.

The resulting out-of-memory termination caused repeated restarts and CrashLoopBackOff.

This was an intentional memory-allocation test, not evidence of a production memory leak.

### Remediation

Updated the Deployment resources:

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "25m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

An initial remediation attempt did not update the Deployment. Kubernetes returned `unchanged`, demonstrating the importance of validating local manifests against live resources.

After correcting the manifest, the updated Deployment was applied successfully.

### Verification

```bash
kubectl rollout status deployment/memory-hog -n oom-lab --timeout=120s
kubectl get pods -n oom-lab
kubectl logs -n oom-lab deployment/memory-hog
```

**Confirmed result:** The user verified that the pod was Running and the updated configuration was visible.

Long-term stability and real application performance were not evaluated.

---

## Lessons Learned

1. **CrashLoopBackOff is a symptom**, not a root cause.
2. **OOMKilled with Exit Code 137** is strong evidence of an out-of-memory termination.
3. **Memory requests** influence scheduling, while **memory limits** constrain container memory usage.
4. **Application logs, termination states, and Kubernetes events** provide complementary diagnostic evidence.
5. **`kubectl apply` returning `unchanged`** means the intended configuration update may not have been saved or applied.
6. **Recovery verification** must follow remediation.
7. Increasing memory limits can resolve insufficient allocation but does not automatically fix memory leaks.

## Interview Preparation

### CrashLoopBackOff

"I investigated a **CrashLoopBackOff** by checking the **container state, exit code, restart count, and application logs**. I identified a **startup configuration problem**, updated the configuration, and **verified the deployment rollout and pod readiness**."

### OOMKilled

"In my Kubernetes lab, I investigated an **OOMKilled container with Exit Code 137**. The application attempted to allocate **128 MiB**, but its **memory limit was 64 MiB**. I updated the **resource requests and limits**, redeployed the application, and **verified that the pod was Running**."

## Ticket Status

- [x] CrashLoopBackOff simulation
- [x] CrashLoopBackOff remediation and verification
- [x] OOMKilled simulation
- [x] OOMKilled remediation and verification
- [x] Incident RCA documented
- [x] Documentation committed and pushed to GitHub
