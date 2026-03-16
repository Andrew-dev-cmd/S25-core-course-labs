# Lab 13 — GitOps with ArgoCD

## Overview

In this lab GitOps continuous deployment was implemented using ArgoCD.  
Git was used as the single source of truth for the Kubernetes cluster state.

ArgoCD continuously compares the cluster state with the configuration stored in the Git repository and automatically reconciles any differences.

Main objectives of this lab:

- Install and configure ArgoCD
- Deploy an application using an ArgoCD Application resource
- Implement multi-environment deployment (dev / prod)
- Test automatic synchronization and self-healing behavior

---

# ArgoCD Installation

ArgoCD was installed using the official Helm chart.

Add Helm repository:

    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update

Create namespace:

    kubectl create namespace argocd

Install ArgoCD:

    helm install argocd argo/argo-cd -n argocd

Verify installation:

    kubectl get pods -n argocd

All components reached the Running state.

---

# Accessing ArgoCD UI

Access to the ArgoCD web interface was configured using port forwarding.

    kubectl port-forward svc/argocd-server -n argocd 8080:443

The UI became available at:

    https://localhost:8080

The initial admin password was retrieved from a Kubernetes secret:

    kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d

---

# Application Deployment

An ArgoCD Application resource was created to deploy the existing Helm chart.

File location:

    k8s/argocd/application.yaml

Application configuration:

    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: moscow-time-app
      namespace: argocd
    spec:
      project: default

      source:
        repoURL: https://github.com/Andrew-dev-cmd/S25-core-course-labs.git
        targetRevision: lab13
        path: k8s/moscow-time-chart

      destination:
        server: https://kubernetes.default.svc
        namespace: default

The application was applied:

    kubectl apply -f k8s/argocd/application.yaml

ArgoCD detected the application and deployed the resources from the Helm chart.

Application status:

    argocd app get moscow-time-app

---

# GitOps Workflow Test

To verify GitOps functionality, the Helm configuration was modified.

Example change in values.yaml:

    replicaCount: 2

Changes were committed and pushed to Git:

    git add .
    git commit -m "Change replica count"
    git push

ArgoCD detected that the cluster state was out of sync with the Git repository.

After synchronization the deployment was updated and the replica count changed accordingly.

---

# Multi-Environment Deployment

Two separate environments were created:

    dev
    prod

Namespaces were created:

    kubectl create namespace dev
    kubectl create namespace prod

Environment-specific Helm values files were used:

    values-dev.yaml
    values-prod.yaml

Two ArgoCD Applications were created.

---

## Dev Application

File:

    k8s/argocd/application-dev.yaml

Key configuration:

    syncPolicy:
      automated:
        prune: true
        selfHeal: true

Dev environment features:

- automatic synchronization
- automatic drift correction
- configuration applied immediately after Git changes

---

## Prod Application

File:

    k8s/argocd/application-prod.yaml

Production configuration does not include automated sync.

This means deployments must be triggered manually.

Reasons:

- safer release management
- change review before deployment
- controlled production updates

---

# Self-Healing Test

ArgoCD self-healing was tested by manually modifying the cluster state.

Manual scaling test:

    kubectl scale deployment moscow-time-dev-moscow-time -n dev --replicas=5

This created a configuration drift between Git and the cluster.

ArgoCD detected the difference and automatically restored the replica count defined in Git.

Final state verification:

    kubectl get deployment -n dev

The replica count returned to the value defined in values-dev.yaml.

---

# Kubernetes Self-Healing Test

Pod deletion was tested to demonstrate Kubernetes self-healing.

    kubectl delete pod -n dev <pod-name>

The Deployment controller recreated the pod automatically.

This behavior is handled by Kubernetes controllers rather than ArgoCD.

---

# Difference Between Kubernetes and ArgoCD Healing

Kubernetes self-healing:

- ensures the correct number of pods
- handled by controllers such as Deployment and ReplicaSet

ArgoCD self-healing:

- ensures the cluster configuration matches the Git repository
- restores configuration drift automatically

---

# Conclusion

In this lab GitOps deployment was successfully implemented using ArgoCD.

The following capabilities were demonstrated:

- declarative application deployment from Git
- automated synchronization with the repository
- environment-specific deployments
- configuration drift detection
- self-healing behavior

Using GitOps ensures that the Kubernetes cluster state always matches the configuration stored in the Git repository.

# Screenshots

![alt text](image.png)

![alt text](image-1.png)

![](image-2.png)

![alt text](image-3.png)

![alt text](image-4.png)

![alt text](image-5.png)