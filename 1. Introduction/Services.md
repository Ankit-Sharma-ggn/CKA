<p align="center">
  <img src="https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.svg"
       alt="Kubernetes Logo" width="140">
</p>

<h1 align="center">Kubernetes Services</h1>


- Create a communication channel between pods, nodes and external world. 
- Provide a consistent IP address and DNS name, ensuring reliable communication even when the underlying pods change.
- Distribute traffic across multiple pods, ensuring high availability and scalability

types:

## 1. NodePort
- make available the internal port (pod) available on a port of a node.

`kubectl expose pod <pod-name> --port=80 --target-port=80 --type=NodePort`

```
## Optional: you can specify a specific NodePort (within the 30000–32767 range):

kubectl expose pod <pod-name> --port=80 --target-port=80 --type=NodePort --name=mynodeportsvc
kubectl patch svc mynodeportsvc -p '{"spec":{"ports":[{"port":80,"targetPort":80,"nodePort":30080}]}}'
```


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

`kubectl expose pod <pod-name> --port=80 --target-port=80 --type=ClusterIP`

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

`kubectl expose pod <pod-name> --port=80 --target-port=80 --type=LoadBalancer`

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

```
## using create command
kubectl create service clusterip mysvc --tcp=80:80
kubectl create service nodeport mynodesvc --tcp=80:80
kubectl create service loadbalancer mylbsvc --tcp=80:80

```


## ➡️ **Next Topic:** -> [Scheduling in Kubernetes](../2.%20Scheduling/README.md)