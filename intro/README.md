# Introduction to Kubernetes

Kubernetes (also known as **K8s**) is an open-source platform designed to automate the deployment, scaling, and management of containerized applications. Originally developed by Google, it is now maintained by the Cloud Native Computing Foundation (CNCF).

---

## 🌐 What is a Kubernetes Cluster?

A **Kubernetes cluster** consists of two main types of nodes:

### 1. Master Node(s) – *Control Plane*
The master nodes are responsible for managing the cluster and maintaining the desired state of applications. They handle scheduling, monitoring, and responding to events.

**Key Components:**
- `kube-apiserver`: Exposes the Kubernetes API.
    - The kube-apiserver is a core component of the Kubernetes control plane. It acts as the front-end for the Kubernetes API and is the central management entity that receives, validates, and processes REST requests, then updates the cluster state accordingly.

    Key Responsibilities:

    - API Gateway: Exposes the Kubernetes API (usually at port 6443).

    - Request Validation: Authenticates and authorizes API requests.

    - State Management: Communicates with etcd to store and retrieve the cluster state.

    - Controller Interaction: Provides a unified interface for other control plane components (like kube-controller-manager, scheduler, etc.) to interact with cluster data.

    - Admission Control: Applies admission plugins to enforce policies before persisting objects.

- `etcd`: 
    - A distributed, reliable key-value store for cluster data.
    - listen on port 2379
    - etcd basic commands: ETCDCTL can interact with ETCD Server using 2 API versions - Version 2 and Version 3.  By default its set to use Version 2. Each version has different sets of commands.

    - To set the right version of API set the environment variable ETCDCTL_API command

        `export ETCDCTL_API=3`

    ```
    # commands for version 2 
    ## etcd version
    ./etcdctl --version

    ## enter any values in etcd
    ./etcdctl set key1 value1

    ## retrieve values from etcd ( same for both versions)
    ./etcdctl get key1

    # commands for version 3 
    ## etcd version

    ## enter any values in etcd
    ./etcdctl put key1 value1
    ```

    ```
    kubectl exec etcd-master -n kube-system -- sh -c "ETCDCTL_API=3 etcdctl get / --prefix --keys-only --limit=10 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt  --key /etc/kubernetes/pki/etcd/server.key" 
    ```

- `kube-scheduler`: Assigns workloads to worker nodes.
    - assign pods to the node on basis of best fit node, which has max free resources.

- `kube-controller-manager`: Ensures the cluster state matches the desired state.
    - A controller is a component which monitor components for its state and remediate in case of discrepancy. i.e Node controller, monitor the state of nodes every 5 s, and in case of no response for 40s, it marks the node unreachable. In case of no response for 5 min, the controller evict\restart the pods on other nodes. list of controllers

        - node-controller:
        - replication-controller:
        - namespace controller
        - deployment controller
        - endpoint-controller, there are more controllers.

    - controller use api-server to connect\monitor the status of each components. 

    - all controller are package in controller manager and run as service on master modes.

        `ps -aux | grep kube-controller-manager`


- `cloud-controller-manager`: Manages cloud-specific resources.

---

### 2. Worker Node(s)

Worker nodes run the actual application workloads in containers. Each worker node contains the following:

**Key Components:**
- `kubelet`: 
    - register the node in cluster.
    - Ensures containers are running in their assigned pods. 
    - Monitor the resources and provide status to kube-apiserver.

- `kube-proxy`: Handles networking and service discovery.
    - process on each node, that look for service and create rules to forward traffic within nodes.
    - internal network within kubernetes cluster to connect all pods within all nodes.


- **Container Runtime** (e.g., Docker, containerd): Executes containers.

---

![Kubernetes Archi](/images/kube_archi.png)

## 🚀 Key Features of Kubernetes

- **Self-healing**: Automatically restarts failed containers and reschedules them on healthy nodes.
- **Horizontal scaling**: Scales applications up or down based on demand.
- **Service discovery and load balancing**: Distributes traffic to appropriate pods.
- **Automated rollouts and rollbacks**: Manages application updates with zero downtime.
- **Secret and configuration management**: Manages sensitive information and app configs securely.

---

## 📌 Summary

Kubernetes is the industry-standard solution for orchestrating containerized applications. It enables teams to build, deploy, and manage applications with high availability, scalability, and resilience across clusters of machines in both cloud and on-premise environments.

 ## link -> ![Basic Introduction to Pods, replicaset and Deployement](Pod.md)
