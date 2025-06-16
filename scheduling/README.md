# Scheduling

## Manual scheduling
- Scheduling the pods manually in definition file. Without a schedule we can schedule the pod in definition file.

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

## Automatic Scheduling

### link -> ![Pod Placement and Node Selection in Kubernetes](Pod Placement and Node Selection in Kubernetes.md)

## link -> ![Resource Requirements and Limit](Pod Placement and Node Selection in Kubernetes.md)


