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

### [1. 📄 Pod Placement and Node Selection in Kubernetes](PodPlacementandNodeSelection.md)

### [2. 📄 Resource Requirements and Limit](ResourceRequirementsandLimit)

## Daemon Sets

- run one copy of pod on each node of the cluster. 
- use for monitoring and logging solutions.
- kube-proxy is one of the example of daemon set.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
    name: moni-app
spec:
    selector:
        matchLabels:
            app: moni-app
    template:
        metadata:
            name: moni-app
            lables:
                app: moni-app
        spec:
            containers:
            -  name: moni-app
               image: moni-app

```
- get daemon set 
    `kubetcl get daemonsets`

    `kubetcl describe daemonsets <daemonset-name>`

## Static Pods
- pods created by kubelets on worker nodes, without involving components from master nodes is called static pods.

- use for deploying control plane components.

- any pod configuration file place at `pod manifest path` in configuration of kubelet service, are created by kubelet on worker nodes.

- Second way, specify `config` in configuration of kubelet service, and define `staticPodPath` in the config file.

- command to check kubelet service config - `sudo systemctl cat kubelet`


## Priority Class

- define priority of workloads within cluster. 

    `kubectl get priorityclass`


```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
    name: high-pr
value: 1000000000
description: "Priority class for crtiical"
globalDefault: true
preemptionPolicy: never
```
- binding the priority class with a pod

    `spec > priorityClassName > <PriorityClass Name>`

- by default a pod will have a default priority class, in which the value of `globalDefault: true`. It can be done for only one priority class only.

- `preemptionPolicy` : policy for scheduling a pod with priority, when there is no resources left on the worker nodes.

    1. never: no schedule pod will be evicted to schedule a pod with higher priority.

    2. PreemptLowerPriority: lower priority pod will be evicted to schedule a higher priority pod in case of resource exhaustion.


## Scheduling Process and Plugin

- Pod scheduling is a process of multiple steps to sort, priortize and bind the pods to noes.

1. Pod Creation: A user or controller creates a pod, and the pod is added to the API server with a Pending status

2. Scheduling Queue: On basis of priority, a queue is created for the pending pods.
    Plugin: PrioritySort

3. Filtering: The scheduler filters out nodes that do not meet the pod's requirements.

    Common filters(plugins) include:
    a. NodeUnschedulable: Excludes nodes marked as unschedulable.
    b. NodeAffinity: Ensures the pod's nodeAffinity rules are satisfied.
    c. TaintToleration: Ensures the pod tolerates the node's taints.
    d. PodTopologySpread: Ensures pods are evenly distributed across failure domains (e.g., zones).

4. Scoring: The scheduler assigns a score to each node that passed the filtering phase. This step is performed by score plugins.
    
    Common scoring criteria include:
    a. LeastAllocated: Prefers nodes with the least allocated resources.
    b. NodeAffinity: Prefers nodes that match the pod's preferredDuringScheduling rules.
    c. PodTopologySpread: Prefers nodes that improve pod distribution.

5. Pod Binding: The scheduler updates the pod's spec.nodeName field to bind it to the selected node.