# Introduction to Kubernetes

Kubernetes (also known as **K8s**) is an open-source platform designed to automate the deployment, scaling, and management of containerized applications. Originally developed by Google, it is now maintained by the Cloud Native Computing Foundation (CNCF).

---

## 🌐 What is a Kubernetes Cluster?

A **Kubernetes cluster** consists of two main types of nodes:

### 1. Master Node(s) – *Control Plane*
The master nodes are responsible for managing the cluster and maintaining the desired state of applications. They handle scheduling, monitoring, and responding to events.

**Key Components:**
- `kube-apiserver`: Exposes the Kubernetes API.
- `etcd`: 
    - A distributed, reliable key-value store for cluster data.
    - listen on port 2379
    - etcd basic commands 

    ``` 
    ## enter any values in etcd
    ./etcdctl set key1 value1

    ## retrieve values from etcd
    ./etcdctl get key1
    ```

- `kube-scheduler`: Assigns workloads to worker nodes.
- `kube-controller-manager`: Ensures the cluster state matches the desired state.
    - controller-manager: 
    - node-controller:
    - replication-controller:
- `cloud-controller-manager`: Manages cloud-specific resources.

---

### 2. Worker Node(s)

Worker nodes run the actual application workloads in containers. Each worker node contains the following:

**Key Components:**
- `kubelet`: Ensures containers are running in their assigned pods.
- `kube-proxy`: Handles networking and service discovery.
- **Container Runtime** (e.g., Docker, containerd): Executes containers.

---

![Kubernetes Archi](/images/kube-archi.png)

## 🚀 Key Features of Kubernetes

- **Self-healing**: Automatically restarts failed containers and reschedules them on healthy nodes.
- **Horizontal scaling**: Scales applications up or down based on demand.
- **Service discovery and load balancing**: Distributes traffic to appropriate pods.
- **Automated rollouts and rollbacks**: Manages application updates with zero downtime.
- **Secret and configuration management**: Manages sensitive information and app configs securely.

---

## 📌 Summary

Kubernetes is the industry-standard solution for orchestrating containerized applications. It enables teams to build, deploy, and manage applications with high availability, scalability, and resilience across clusters of machines in both cloud and on-premise environments.

---
