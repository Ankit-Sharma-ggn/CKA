<p align="center">
  <img src="https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.svg"
       alt="Kubernetes Logo" width="140">
</p>

<h1 align="center">Cluster Lifecycle Management</h1>

**Node Eviction Timeout** - time duration the cluster wait before restarting a pod on unreacahble node.

For upgrade and other maintenance activity, we need to mark a node unschedulable and move the workflow to another nodes.


```
kubectl drain node01    ## for updating node as unschedulable and drain pods from the node

kubectl uncordon node01 ## for updating node as schedulable

```

## Kubernetes versions

- version number contain Major, minor and patch version.

    ` v1.0.alpha > v1.0.beta > v1.0.1 `

## Cluster upgrade

- No component can be on higher version then kube-apiserver.

- if kube-apiserver is at version v1.10, controller-manager and  kube-scheduler can be at x or x-1 version. Simillarly kubelet and kub-proxy can be at x, x-1 or x-2 version.

- first we upgrade the controlplane, and during upgrade all the management plane is not accessible but all the pods on workernodes will be functioning as normal. After that we we upgrade the worknodes.

` kubeadm upgrade plan`

Upgrade steps

```
1. upgrade kubeadm utility
    sudo apt-cache madison kubeadm     ### check for the available versions
    apt-get upgrade -y kubeadm=1.12.0-00

2. Upgrade masternode
    kubeadm upgrade apply v1.12.0

3. upgrade kubelet on masternode
    sudo apt-cache madison kubelet
    apt-get upgrade -y kubelet=1.12.0-00

4. upgrade on worker nodes
    kubectl drain node01

    apt-get upgrade -y kubeadm=1.12.0-00

    apt-get upgrade -y kubelet=1.12.0-00

    kubeadm upgrade node config --kubelet-version v1.12.0

    systemctl restart kubelet

    kubectl uncordon node01
```
### Upgrading Clusters With Kubeadm

Reference:- https://github.com/kodekloudhub/community-faq/blob/main/docs/cluster-upgrades.md

Under the old system we had one giant repo that covered all versions going back a number of years. Once you configured your package repository for that one monster repo, you were set, and didn't need to worry about configuring anything again -- when new versions of kubeadm and other binaries came out, they were added to that repo.

The new system is different. Each minor version (e.g., 1.27, 1.28, 1.29) has its own repo (going back to 1.24), and if you want to install binaries from that family of binaries, you need to configure your package manager to include the repo for that binary version. In our Kubernetes certification courses, we use Ubuntu systems, which use the apt package manager. To support a Kubernetes such as 1.29, you need to:

Find the right file under /etc/apt on the system you need to upgrade. In the Kubernetes docs and in our labs, that file is /etc/apt/sources.list.d/kubernetes.list, but it can be any other file name under /etc/apt/sources.list.d, or even in /etc/apt/sources.list, although we don't recommend that.

You need to edit that file to support our desired version. The easiest thing to do is to look for a line that starts with deb, and edit the version number to what you need to install. If you see a line like:

`deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /`
then you need to edit to be:

`deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /`


### Backup before upgrades

- **resource configuration**: backup solutions are available to take daily, regularly backup of the resources.
    ` kubectl get all --all-namespaces -o yaml > all-deploy-svc.yaml`

- **ETCD**:
```
    ETCDTL_API=3 etcdctl snapshot save snap.db

    ETCDTL_API=3 etcdctl snapshot status snap.db

    ## restore process
    service kube-apiserver stop

    ETCDTL_API=3 etcdctl snapshot restore snap.db --data-dir /var/lib/etcd-from-backup

    ## update this location of etcd backup in ETCD config file.

    systemctl daemon-reload

    service etcd restart

    service kube-apiserver start

    ##NOTE: with etcdctl command we need to specify endpoint, cacert, cert and key
```
