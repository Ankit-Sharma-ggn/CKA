# Networking
 
## Network ports within Cluster

* On worker node
    * kubelet : 10250 (on all the nodes)
    * Services : 30000 - 32767
* on master node
    * kube-api : 6443
    * kube-scheduler : 10259
    * kube-controller-manager : 10257
    * ETCD : 2379

In case of multiple master node, for ETCD connection 2380 connection is required

![Network Ports](https://github.com/Ankit-Sharma-ggn/CKA/blob/main/images/network_ports.png)


