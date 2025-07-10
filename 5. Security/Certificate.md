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


## Generating certificates

### 1. CA certificates
```
## generating keys
openssl genrsa -out ca.key 2048     ####### this command will output the ca.key file as key

## cert signing request
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr

## Sign certificate
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt
```

### 2. Admin user certificates
```
## generating keys
openssl genrsa -out admin.key 2048     ####### this command will output the ca.key file as key

## cert signing request
openssl req -new -key admin.key -subj "/CN=kube-admin" -out admin.csr

openssl req -new -key admin.key -subj "/CN=kube-admin/O=system:masters" -out admin.csr       ### providing user with admin access

## Sign certificate
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -out admin.crt



## How to use the certificate to authenticate

curl https://kube-apiserver:6443/api/v1/pods --key admin.key --cert admin.crt -cacert ca.crt
```

### 3. Server Certificates

- Creating certificates for kube-apiserver and etcd is a critical step in securing a Kubernetes cluster. These certificates ensure secure communication between the Kubernetes control plane components and the etcd database.

#### kube-apiserver Certificate
The kube-apiserver certificate is used by the Kubernetes API server to secure communication with clients (e.g., kubectl) and other Kubernetes components.

Common Name (CN): kube-apiserver
Subject Alternative Names (SANs):
    1. Cluster IP of the API server (e.g., 10.96.0.1).
    2. DNS names (e.g., kubernetes, kubernetes.default, kubernetes.default.svc, kubernetes.default.svc.cluster.local).

It ensures:
    1. Authentication of clients (e.g., kubelet, controller-manager, scheduler).
    2. Encryption of API server traffic.
```
# Create a Certificate Signing Request
openssl req -new -key kube-apiserver.key -subj "/CN=kube-apiserver" -out kube-apiserver.csr

# Sign the Certificate with the CA
openssl x509 -req -in kube-apiserver.csr -CA ca.crt -CAkey ca.key  -out kube-apiserver.crt

```

#### etcd Certificate
The etcd certificate is used to secure communication between the kube-apiserver and the etcd database.

It ensures:
    1. Authentication of the kube-apiserver to etcd.
    2. Encryption of data in transit between the API server and etcd.


## Veiwing Certificates

`openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout`

## Certificate API

- user generate a key and a csr.
    `openssl genrsa -out jane.key 2048`
  
- create a certificate signing request and change the text into base64 

    `openssl req -new -key jane.key -subj "/CN=jane" -out jane.csr`

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
    name: jane
spec:
    expirationSeconds: 600
    usages:
    - digital signature
    - key encipherment
    - server auth
    request:

```