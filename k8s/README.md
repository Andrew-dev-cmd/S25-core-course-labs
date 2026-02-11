# Lab 9 — Kubernetes Deployment of Moscow Time App

## 1. Architecture Overview
- **Application:** Moscow Time Web App (Python)
- **Deployment:** `moscow-time-python`
- **Pods:** 3 replicas (scalable to 5)
- **Service:** NodePort `moscow-time-service` on port 30080
- **Container:** non-root, port 5000
- **Health Checks:** Liveness and Readiness probes enabled
- **Strategy:** RollingUpdate (maxSurge=1, maxUnavailable=0)
- **Resource Management:** Requests: CPU 100m, Memory 128Mi; Limits: CPU 250m, Memory 256Mi

**Diagram:**
![k8s diagram](<Blank diagram - Page 1.png>)

## 2. Manifest Files

### **deployment.yml**
- **Purpose:** Deploy Python app with 3 replicas, health checks, resources, rolling updates
- **Key settings:**
  - `replicas: 3`
  - `livenessProbe` & `readinessProbe` on `/`
  - Resource requests & limits defined
  - Non-root container
  - Rolling update strategy enabled

### **service.yml**
- **Purpose:** Expose Deployment via NodePort
- **Key settings:**
  - `type: NodePort`
  - `port: 5000` → `targetPort: 5000`
  - `nodePort: 30080` for local access
  - Selects pods using `app: moscow-time` label


---

## 3. Deployment Evidence

### **Applied resources:**
```bash
kubectl apply -f k8s/deployment.yml
kubectl apply -f k8s/service.yml
```

*Get all resources:*

`kubectl get all`

![alt text](image.png)

*Describe Deployment:*

`kubectl describe deployment moscow-time-python`

![alt text](image-1.png)

*Accessing the App:*

`minikube service moscow-time-service`

![alt text](image-2.png)

## 4. Operations Performed

*Deployment:*

```
kubectl apply -f k8s/deployment.yml
kubectl get pods
```

*Service creation:*

```
kubectl apply -f k8s/service.yml
kubectl get svc
```

*Scaling to 5 replicas:*

```
kubectl scale deployment moscow-time-python --replicas=5
kubectl get pods
```

*Rolling Update (v1.0 → v1.1):*

```
kubectl apply -f k8s/deployment.yml
kubectl rollout status deployment/moscow-time-python
```

*Rollback:*

```
kubectl rollout undo deployment/moscow-time-python
kubectl rollout history deployment/moscow-time-python
```

## 5. Production Considerations

- Health Checks: Liveness and Readiness probes prevent unhealthy pods from receiving traffic.

- Resource Limits: Avoid CPU/memory starvation and ensure stability.

- Rolling Updates: Zero-downtime deployment strategy.

- Non-root container: Improves security.

- Monitoring & Observability: Logs via kubectl logs, metrics server recommended.

## 6. Challenges & Solutions

- Pod crash at start: Fix probes configuration

- NodePort conflicts: Explicitly set nodePort: 30080

*Lessons learned:*

- Kubernetes declarative manifests

- Scaling and rolling updates

- Service exposure for local cluster access

- Resource management best practices