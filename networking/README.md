# Networking
 
## Network ports within Cluster

* On worker node
    * kubelet : 10250 (on all the nodes)
    * Services : 30000 - 32767
* On master node
    * kube-api : 6443
    * kube-scheduler : 10259
    * kube-controller-manager : 10257
    * ETCD : 2379

In case of multiple master node, for ETCD connection 2380 connection is required

![Network Ports](https://github.com/Ankit-Sharma-ggn/CKA/blob/main/images/network_ports.png)


## Basic Networking - Docker


## Networking Model ( pod level networking)

* Every POD should have an IP address
* Every POD should be able to communicate with every other pod in same node.
* Every POD should able to communicate with every POD on other nodes without NAT.

Network Solution (addon): kubernetes do not provide default networking, we need to add add-ons to support POD networking. i.e flannel, cilium and NSX

### CNI ( Container Network Interface)

CNI is a specification and library for configuring network interfaces in Linux containers. It ensures that containers have the necessary networking capabilities to communicate within a Kubernetes cluster.

* it assign an IP to each container for communication, and remove the IP when conatiner is removed.

* Weavework is one of the networking solution for kubernetes

* /opt/cni/bin - list of all CNI plugin

* /etc/cni/net.d - list of CNI to use

### Deploy Weave
Is deploy as POD on each node.

### IPAM (IP address management)


## Service Network
* a cluster wide virtual object, span across the nodes in cluster.

* kube-proxy create forwarding rules on each nodes to forward thge traffic of service network to particular pod.

* ip range of the services - 

    <pre> kube-api-server --service-cluster-ip-range ipNet</pre>

    <pre> ps aux | grep kube-api-server </pre>

    * default value - 10.0.0.0/24

* type of network services
    * ClusterIP - access within cluster
    * NodePort - accessible outside
    * 