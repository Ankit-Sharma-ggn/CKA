<p align="center">
  <img src="https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.svg"
       alt="Kubernetes Logo" width="140">
</p>

<h1 align="center">📦 Cluster Architecture, Installation and Configuration</h1>


## Prepare underlying infrastructure for installing a Kubernetes cluster

### Linux node setup

- Configure hostname, static IP, and /etc/hosts entries across nodes.

    ```
    hostnamectl set-hostname master-node
    echo "192.168.1.10 master-node" >> /etc/hosts
    ```

- Update kernel parameters for Kubernetes networking (net.bridge.bridge-nf-call-iptables, ip_forward, etc.).
- Disable swap (swapoff -a and remove swap entries from /etc/fstab).

    ```
    This creates a file /etc/modules-load.d/k8s.conf that ensures Linux kernel modules are loaded at boot.

    overlay → required for container runtimes like containerd (enables OverlayFS filesystem).

    br_netfilter → allows bridged network traffic (used by Kubernetes networking) to be visible to iptables for packet filtering.

    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
    overlay
    br_netfilter
    EOF

    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables  = 1
    net.ipv4.ip_forward                 = 1
    EOF

    sudo sysctl --system
    ```

2.	Container runtime installation

    ```
    sudo dpkg -i containerd.io_1.7.22-1_amd64.deb

    ## If you get missing dependency errors, fix them with:
    sudo apt-get install -f

    sudo systemctl enable containerd
    sudo systemctl start containerd

    systemctl status containerd
    ```

3.	Networking prerequisites
o	Ensure required ports are open (6443, 2379–2380, 10250–10259, 30000–32767, etc.).
o	Set up network interface routing for pods/services.
4.	Kubeadm prerequisites
```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet

kubelet --version

```
5.	Certificates & SSH
o	Set up SSH access between nodes (sometimes for troubleshooting).
o	Prepare certificate directories or approve CSRs if needed.
6.	Cluster bootstrapping (related follow-up tasks)
    -	Run kubeadm init with required parameters (advertise address, pod CIDR, etc.).
    -	Set up kubeconfig (~/.kube/config).
    -	Apply a CNI plugin (Calico, Weave, etc.) after control-plane init.

```
ip addr show eth0     ### to find the IP address of controlplane

sudo kubeadm init \
--apiserver-advertise-address=192.168.100.160 \
--apiserver-cert-extra-sans=controlplane \
--pod-network-cidr=172.17.0.0/16 \
--service-cidr=172.20.0.0/16

Your Kubernetes control-plane has initialized successfully!

## To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

## Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

## hen you can join any number of worker nodes by running the following on each as root:
kubeadm join 192.168.100.160:6443 --token hb4j2v.87qslsx1nwh19m5k \
--discovery-token-ca-cert-hash sha256:72bb2ed9cc598bcdb2f65a747c06952043bf4fd23c9841d29ba601dd92792d41 

```


o	Join worker nodes with kubeadm join.



## Create and manage Kubernetes clusters using kubeadm
## Manage the lifecycle of Kubernetes clusters
## 

## Manage role based access control (RBAC)
## Implement and configure a highly-available control plane
## Use Helm and Kustomize to install cluster components
## Understand extension interfaces (CNI, CSI, CRI, etc.)
## Understand CRDs, install and configure operators




