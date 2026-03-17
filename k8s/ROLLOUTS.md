## 1. Argo Rollouts Setup

Argo Rollouts controller and dashboard were installed in a dedicated namespace.

### Installation

    kubectl create namespace argo-rollouts
    kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
    kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/dashboard-install.yaml

### Verification

    kubectl get pods -n argo-rollouts

All components were in Running state.

### Dashboard Access

kubectl port-forward svc/argo-rollouts-dashboard -n argo-rollouts 3100:3100

Dashboard available at:

    http://localhost:3100/rollouts

I use SSH tunnel for access to dashboard.

---

## 2. Rollout vs Deployment

- Deployment: basic rolling updates
- Rollout: supports canary and blue-green strategies
- Rollout allows traffic control and advanced rollback

---

## 3. Canary Deployment (dev)

Deployment was replaced with Rollout using canary strategy.

### Strategy

    steps:
      - setWeight: 20
      - pause: {}
      - setWeight: 40
      - pause: 30s
      - setWeight: 60
      - pause: 30s
      - setWeight: 80
      - pause: 30s
      - setWeight: 100

### Commands

    kubectl argo rollouts get rollout moscow-time-dev-moscow-time -n dev -w
    kubectl argo rollouts promote moscow-time-dev-moscow-time -n dev
    kubectl argo rollouts abort moscow-time-dev-moscow-time -n dev

### Result

- gradual traffic shift
- manual promotion works
- rollback works

---

## 4. Blue-Green Deployment (prod)

Blue-green strategy was configured for production.

### Configuration

    strategy:
      blueGreen:
        activeService: moscow-time-prod-moscow-time
        previewService: moscow-time-prod-moscow-time-preview
        autoPromotionEnabled: false

### Services

    kubectl get svc -n prod

- active: moscow-time-prod-moscow-time
- preview: moscow-time-prod-moscow-time-preview

### Rollout State

    kubectl argo rollouts get rollout moscow-time-prod-moscow-time -n prod

Observed:

- stable version serves production traffic
- new version deployed as preview
- cutover pending until manual promotion

### Promotion

    kubectl argo rollouts promote moscow-time-prod-moscow-time -n prod

After promotion:
- instant traffic switch
- new version becomes active

### Notes

Blue-green required double resources (both versions running).
In Minikube environment one pod remained Pending due to resource limits.

---

## 5. Canary vs Blue-Green

Canary:
- gradual rollout
- safer
- slower

Blue-Green:
- instant switch
- faster rollback
- requires more resources

---

## 6. Useful Commands

    kubectl argo rollouts get rollout <name> -w
    kubectl argo rollouts promote <name>
    kubectl argo rollouts abort <name>
    kubectl argo rollouts undo <name>

---

## 7. Conclusion

- Canary deployment successfully implemented
- Blue-green deployment successfully configured
- Preview and active environments tested
- Manual promotion and rollback verified

Progressive delivery with Argo Rollouts was successfully demonstrated.

## 8. Screenshots

![alt text](image.png)

![alt text](image-1.png)

![alt text](image-2.png)

![alt text](image-3.png)

![alt text](image-4.png)