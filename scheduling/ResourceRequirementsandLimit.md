# Resource Requirements and Limits



## Resource Requests

- min. required cpu and memory for scheduling a pod is known as resource request.
```yaml
spec:
    resources:
        requests:
            memory: "4Gi"
            cpu: 2
```

## Resource Limits
- maximum limit of resources, cpu and memory a pod can utilize on a node.

Note: a pod cannot use more cpu then assigned limits, but however it can use more more memory then assigned in limits, pod will be terminated with message OOM (out of memory)

```yaml
spec:
    resources:
        limits:
            memory: "6Gi"
            cpu: 3
```

## Default pod Behavior - CPU

- by default there is no request and limits set on pods.

![Behavior CPU](<Images/ideal cpu config.png>)

## Default pod Behavior - Memory

![behavior Memory](<Images/behavior memory.png>)


