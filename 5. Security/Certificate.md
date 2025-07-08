<p align="center">
  <img src="https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.svg"
       alt="Kubernetes Logo" width="140">
</p>

<h1 align="center">Certificates in Kubernetes</h1>

## Type of certificates and components

1. Client Certificates - users, kube-scheduler, kube-controllermanager, kube-proxy. Kube-api server also uses client certificates to communicate with ETCD and Kubelet servers.
2. Server Certificates - components that require server certificates: kube-apiserver, ETCD server, kubelet server
3. Root certificates

![Kubernetes CERTIFICATES](/images/image.png)
