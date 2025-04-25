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

* list of all CNI plugin :-
    <pre>/opt/cni/bin</pre> - 

* list of CNI in use :-
    <pre>/etc/cni/net.d </pre>

#### Weave (CNI): 
Weave Net is a Container Network Interface (CNI) plugin that provides a simple, fast, and secure network for Kubernetes clusters. It allows all pods across nodes to communicate with each other as if they were on the same local network — no matter which node they're on.

### how it works:-
Weave creates an overlay network across all Kubernetes nodes using a peer-to-peer mesh. It uses VXLAN encapsulation to tunnel pod traffic between nodes.

    * Each node gets a block of IP addresses assigned from a global CIDR (e.g., 10.32.0.0/12).

    * Pods on the node get IPs from this block. Weave keeps a distributed IPAM (IP Address Management) database to avoid collisions.

    * When a pod sends traffic to another pod (on a different node):

    * The packet is intercepted by Weave.

    * It encapsulates the traffic using VXLAN and sends it over the mesh to the correct node.

    * On the destination node, Weave decapsulates and delivers it to the target pod.


## Service Network
* a cluster wide virtual object, span across the nodes in cluster.

* kube-proxy create forwarding rules on each nodes to forward the traffic of service network to particular pod.

    default proxy mode = iptables

<pre> kube-proxy --proxy-mode [userspace | iptables | ipvs ]</pre>


* ip range of the services configured by kube-proxy- 

    <pre> kube-api-server --service-cluster-ip-range ipNet</pre>

* get configured Ip range from cluster 

    <pre> ps aux | grep kube-api-server </pre>

    * default value - 10.0.0.0/24

* IP network for pods and service should not be collide (overlap)

* finding iptables rule created by kube-proxy
    <pre> iptables -L -t nat | grep "name of service"  </pre>

* kube proxy logs
    <pre> "/var/log/kube-proxy.log" </pre>

* type of network services
    * ClusterIP - access within cluster
    * NodePort - accessible outside

## DNS in Kubernetes

* kube dns is a default dns use by kubernetes to give friendly name for resolution.

* previously the name of kubernetes dns was kube-dns, but from v1.12 the name is CoreDNS.

![Kube DNS](/images/kube-dns.png)

### How services get resolved in cluster

* Let assume we created a web service `web-ser` in namespace `app`.

    - Withing the namespace it can be resolve by `web-ser`
    - From another namespace `web-ser.app`
    - Resolution within kubernetes cluster by `web-ser.app.svc.cluster.local`

        | **Component**    | **Meaning**              |
        |------------------|--------------------------|
        | `web-ser`        | Service name             |
        | `app`            | Namespace                |
        | `svc`            | Type (service)           |
        | `cluster.local`  | Root domain (default)    |

### How services get resolved in cluster

* Pods dns records are not created by default, the settings needs to be enabled.

* Pods dns entry is created by replacing "." in pod's IP with "-"

    i.e > 10.244.2.5 > 10-244-2-5

    - FQDN  > "10-244-2-5.app.pod.cluster.local"

### How CoreDNS is setup in kubernetes

* CoreDNS is deployed as pod in kube-system. It uses a configuration file for setting\configuration. 
    "/etc/coredns/Corefile"

    - file is passes as configMap to Coredns pod with name "core-dns"
    <pre> 
    .:53 {
    errors
    health
    ready
    kubernetes cluster.local in-addr.arpa ip6.arpa {
        pods insecure
        fallthrough in-addr.arpa ip6.arpa
        ttl 30
    }
    prometheus :9153
    forward . 8.8.8.8 8.8.4.4 {
        max_concurrent 1000
    }
    cache 30
    loop
    reload
    loadbalance
    log
    }</pre>

    | Directive | Purpose |
    | ------- | ------- |
    | `.:53` | Listens on all interfaces on port 53 |
    | `errors` | Enables error logging |
    | `health` | Provides a health endpoint for monitoring
    | `ready`| Adds a readiness endpoint for Kubernetes |
    | `kubernetes` | Handles DNS queries for Kubernetes services and pods |
    | `prometheus` | Enables Prometheus metrics at port 9153 |
    | `forward` | Forwards DNS queries to upstream servers (Google DNS in this case) |
    | `cache`         | Caches DNS responses for 30 seconds |
    | `loop`          | Prevents infinite forwarding loops |
    | `reload`        | Automatically reloads CoreDNS on config changes |
    | `loadbalance`   | Balances the response order for A/AAAA records |
    | `log` | Logs DNS queries (can be fine-tuned or redirected to a file) |
    
    
* a default core-dns service (cluster-IP) is created, which points to the core-dns pods. 

* In each pod, etc/resolv.conf contains a nameserver entry(core-dns service (cluster-IP)), which points to the coreDNS service IP. This configurations are done by kubernetes when pods are created. The entry of service-ip is already there in kubelet configuration file

    `cat /var/lib/kubelet/config.yaml`
    ```
    ...
     clusterDNS:
     - 10.96.0.10
     clusterDomain: cluster.local 
    ```