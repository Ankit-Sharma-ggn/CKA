# Service
- Create a communication channel between pods, nodes and external world. 
- Provide a consistent IP address and DNS name, ensuring reliable communication even when the underlying pods change.
- Distribute traffic across multiple pods, ensuring high availability and scalability

types:

## 1. NodePort
- make available the internal port (pod) available on a port of a node.

```yaml
apiVersion: v1
kind: Service
metadata:
    name: my-service
spec:
    type: NodePort
    ports:
        - targetPort: 80
          port: 80
          nodePort: 30008
    selector:
        type: frontend
```

## 2. ClusterIP
- Exposes the service on an internal IP within the cluster
- accessible internally

```yaml
apiVersion: v1
kind: Service
metadata:
    name: back-end
spec:
    type: ClusterIP
    ports:
        - targetPort: 80
          port: 80
    selector:
        type: back-end
```


## 3. LoadBalancer
- Provision a loadbalancer for load balancing the traffic to the application.
- Automatically integrates with cloud provider-specific load balancers

```yaml
apiVersion: v1
kind: Service
metadata:
    name: my-service
spec:
    type: LoadBalancer
    ports:
        - targetPort: 80
          port: 80
          nodePort: 30008
    selector:
        type: frontend
```