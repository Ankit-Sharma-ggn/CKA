# Scheduling

## 📅 Scheduling in Kubernetes
- Manual scheduling allows you to explicitly specify the node on which a pod should run by setting the nodeName field in the pod definition file. This approach bypasses Kubernetes' default scheduler.

📌 **Example:**

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: myapp-pod
    labels:
        app: myapp
spec:
    containers:
        - name: nginx-container
          image: nginx
    nodeName: node02
```

## ⚙️ Automatic Scheduling

### 📚Topics

### [📄 Pod Placement and Node Selection in Kubernetes](PodPlacementandNodeSelection.md)

### [📄 Resource Requirements and Limit](ResourceRequirementsandLimit)


