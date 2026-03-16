# Lab 12 — ConfigMaps & Persistent Volumes

## Overview

In this lab we extended the existing Helm chart to support external configuration and persistent storage.

The following Kubernetes features were implemented:

- ConfigMaps for application configuration
- Environment variables injection from ConfigMap
- PersistentVolumeClaim for application data
- Volume mounts inside the container
- Persistence verification after pod restart

---

# Task 1 — Application Persistence Upgrade

The application was modified to store visit counts in a file.

## Visits Counter Logic

Each request to the root endpoint:

1. Reads the current value from `/data/visits`
2. Increments the counter
3. Writes the updated value back to the file

A new endpoint was added:

GET /visits

This endpoint returns the current visit count.

Data file location:

/data/visits

If the file does not exist, the application initializes it with value `0`.

---

## Local Docker Testing

A volume was added to `docker-compose.yml`.

    services:
      app:
        build: .
        ports:
          - "8080:8080"
        volumes:
          - ./data:/app/data

Test commands:

    docker compose up
    curl localhost:8080/
    curl localhost:8080/
    cat ./data/visits

After restarting the container the counter value remained unchanged.

---

# Task 2 — ConfigMaps

## Configuration File

A configuration file was added to the Helm chart:

files/config.json

Example content:

    {
      "appName": "moscow-time-app",
      "environment": "dev",
      "featureFlags": {
        "showVisits": true
      }
    }

---

## ConfigMap Template

File:

templates/configmap.yaml

    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: {{ include "moscow-time.fullname" . }}-config
    data:
      config.json: |-
    {{ .Files.Get "files/config.json" | indent 4 }}

This loads the configuration file directly from the Helm chart.

---

## Mount ConfigMap as File

Deployment configuration:

    volumes:
      - name: config-volume
        configMap:
          name: {{ include "moscow-time.fullname" . }}-config

    containers:
      - volumeMounts:
          - name: config-volume
            mountPath: /config

Verification:

    kubectl exec <pod> -- cat /config/config.json

---

## ConfigMap as Environment Variables

Second ConfigMap:

templates/configmap-env.yaml

    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: {{ include "moscow-time.fullname" . }}-env
    data:
      APP_ENV: "dev"
      LOG_LEVEL: "info"

Environment variables are injected using:

    envFrom:
      - configMapRef:
          name: {{ include "moscow-time.fullname" . }}-env

Verification:

    kubectl exec <pod> -- printenv | grep APP

Example output:

    APP_ENV=dev
    LOG_LEVEL=info

---

# Task 3 — Persistent Volumes

Persistent storage was implemented using a PersistentVolumeClaim.

## PVC Template

File:

templates/pvc.yaml

    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: {{ include "moscow-time.fullname" . }}-data
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 100Mi

---

## values.yaml Configuration

    persistence:
      enabled: true
      size: 100Mi
      storageClass: standard

---

## Mount PVC in Deployment

    volumes:
      - name: data-volume
        persistentVolumeClaim:
          claimName: {{ include "moscow-time.fullname" . }}-data

    containers:
      - volumeMounts:
          - name: data-volume
            mountPath: /data

Application data is stored in:

/data

---

# Persistence Test

Check PVC:

    kubectl get pvc

Example output:

    NAME                               STATUS   CAPACITY
    moscow-time-app-moscow-time-data   Bound    100Mi

Check stored counter:

    kubectl exec <pod> -- cat /data/visits

---

## Pod Restart Test

Before pod deletion:

    curl /visits

Example output:

    Visits: 5

Delete pod:

    kubectl delete pod <pod-name>

After new pod starts:

    curl /visits

Output remains the same:

    Visits: 5

This confirms that data is preserved using Persistent Volume.

---

# ConfigMap vs Secret

ConfigMaps are used for:

- application configuration
- feature flags
- environment variables

Secrets are used for:

- passwords
- API tokens
- TLS certificates

Main difference:

| Feature | ConfigMap | Secret |
|--------|-----------|--------|
| Purpose | Configuration | Sensitive data |
| Storage | Plain text | Base64 encoded |

---

# Conclusion

In this lab the application Helm chart was extended to support configuration and persistent storage.

Implemented features:

- ConfigMaps for external configuration
- environment variable injection
- PersistentVolumeClaim for data persistence
- verification of data survival after pod restart

These mechanisms allow running the same container image in different environments while keeping configuration and data separate from the image.

# Screenshots

![alt text](image.png)
![alt text](image-1.png)
![alt text](image-2.png)