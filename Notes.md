## Core Concepts

### working with etcd commands

```yaml
find the details for etcd
ps -aux | grep etcd    ### this will give details of certificates, endpoints 


export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=https://192.168.202.9:2379
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key


## Get a specific key: 
etcdctl get /registry/pods/default/nginx


## To fetch all key-value pairs: 
etcdctl get "" --prefix

```

### Pods, namespace, replicaset, replica and deployment

```yaml
## create pods without def file
kubectl run redis --image=redis:alpine --labels tier=db

## Generate POD or deployement yaml

kubectl run nginx --image=nginx --dry-run=client -o yaml

kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml

## update replica set 
kubectl replace -f rcset-def.yml
kubectl scale --replicas=6 -f rcset-def.yml
kubectl scale --replicas=6 -f replicaset myapp-rcset

## Get all components
kubectl get all

## creating pod in dev namespace
kubectl create -f pod-def.yml --namespace=dev  

## getting all the pods in all the namespaces
kubect get pods --all-namespaces         

## Create a Service named redis-service of type ClusterIP to expose pod redis on port 6379
kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml

kubectl create service clusterip redis --tcp=6379:6379 --dry-run=client -o yaml
Note : This will not use the pods labels as selectors, instead it will assume selectors as app=redis

## List pod based on labels 
kubectl get pods --selector app=myapp

## select all object based on lables 
kubectl get all --selector app=myapp,tier=frontend

```

## Services
```yaml
## Nodeport, ClusterIP and Loadbalancr

kubectl expose pod <pod-name> --port=80 --target-port=80 --type=NodePort
kubectl expose pod <pod-name> --port=80 --target-port=80 --type=ClusterIP
kubectl expose pod <pod-name> --port=80 --target-port=80 --type=LoadBalancer

## using create command
kubectl create service clusterip mysvc --tcp=80:80
kubectl create service nodeport mynodesvc --tcp=80:80
kubectl create service loadbalancer mylbsvc --tcp=80:80
```

## Scheduling


```yaml

## add taints on node 
kubetcl taint node node01 app=blue:NoSchedule

## check for taints
kubectl decribe node node01 | grep Taint

## removing taints
kubetcl taint node node01 app=blue:NoSchedule-

## toleration can be found on any system pod
spec:
    containers:
    -   name: ng
        image: nginx
    tolerations:
    - key: "app"
      operator: "Equal"
      value: "blue"
      effect: "NoSchedule"

## Node selectors
kubectl label nodes node01 size=Large

## pod config
spec:
    containers:
    -   name: data-pr
        image: web-data
    nodeSelector:
        size: Large

## Node Affinity
can be found on system or DNS pod in kube-system


```

## resource requirements and Limits

```yaml


### Pod resource limits , can be validated from any system pod
resources:
      limits:
        memory: 170Mi
        cpu: 200m
      requests:
        cpu: 100m
        memory: 70Mi

## for every pod in cluster, we can set limit of cpu and memory. It will applied to the new pods only.
apiVersion: v1
kind: LimitRange
metadata:
    name: cpu-limit
spec:
    limits:
    - default:
        cpu: 500m   ### limit
      defaultRequest:
        cpu: 500m   ### Request
      max:
        cpu: "1"
      min:
        cpu: 100m
      type: Container
```

## Cluster upgrade\ Lifecycle

```yaml
## updates and rollback

## deployment and recreate strategy

## pod def file for recreare
spec:
  strategy:
    type: Recreate

## pod def file for rolling
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
        maxSurge: 1
        maxUnavailable: 1

## check rollout status
kubectl rollout status deployment/my-depl1

kubectl rollout history deployment/my-depl1

## using command to set the image on deployement.
kubectl set image deployement/my-depl1 nginx=nginx:1.9.1

## rollback
kubectl rollout undo deployement/my-depl1

```

## Container Commands, env variables, Config Map and Secrets

```yaml
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["/bin/sh", "-c"]
    args:
      - |
        while true; do
          echo "$(date) - Hello from the container" >> /var/log/app.log;
          sleep 5;
        done

## ENv Var, config MAP and Secrets
spec:
    containers:
    - name: web-color
      image: webapp
      env:
        - name: APP_COLOR    ## ENV variable name
          value: ping        ## ENV variable value
      envFrom: 
        - configMapRef:
          name: app-config
        - secretRef:
          name: app-secret

## create config map
kubectl create configmap app-config --from-literal=APP_COLOR=blue --from-literal=APP_MODE=prod

## create secret
kubectl create secret generic app-secret --from-literal=DB_Host=mysql

```

## Cluster Upgrade

```yaml
kubectl drain controlplane    ## for updating node as unschedulable and drain pods from the node

kubectl uncordon controlplane ## for updating node as schedulable

## Cluster UPgrade 

    kubeadm upgrade plan

## upgrade kubeadm utility
    sudo apt-cache madison kubeadm     ### check for the available versions
    apt-get upgrade -y kubeadm=1.12.0-00

## update file "etc/apt/sources.list.d/kubernetes.list" to add kubeadm liberary for next version.
## and run "sudo apt update"

## Upgrade masternode
    kubeadm upgrade apply v1.12.0

##  upgrade kubelet on masternode
    sudo apt-cache madison kubelet
    apt-get install -y kubelet=1.12.0-00

## apply the config
    systemctl daemon-reload
    systemctl restart kubelet

     kubectl uncordon controlplane


## upgrade on worker nodes
    kubectl drain node01

    apt-get upgrade -y kubeadm=1.12.0-00

    apt-get upgrade -y kubelet=1.12.0-00

    kubeadm upgrade node config --kubelet-version v1.12.0

    systemctl restart kubelet

    kubectl uncordon node01

## etcd backup before upgrade

export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=https://192.168.202.9:2379
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key


etcdctl snapshot save snap.db
etcdctl snapshot status snap.db

## restore
service kube-apiserver stop

etcdctl snapshot restore snap.db --data-dir /var/lib/etcd-from-backup

update the --data-dir to new target on manifest file - /etc/kubernetes/manifests/etcd.yaml

systemctl daemon-reload
service etcd restart
service kube-apiserver start
```

## Security

```yaml

### certificate

#### cert generation process
openssl gen-rsa -out ca.key 2048
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt

#### other certificates
openssl gen-rsa -out admin.key 2048
openssl req -new -key admin.key -subj "CN=kube-admin/O=system:masters" -out admin.csr
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -out admin.crt

#### viewing certificate details 
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout

#### certificate API
openssl genrsa -out jane.key 2048
openssl req -new -key jane.key -subj "/CN=Jane" -out jane.csr
cat jane.csr | base64 | tr -d '\n'

#### csr request
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
        "## encoded certificate request data ##"

#### csr approve by admin
kubectl get csr
kubectl certificate approve jane
kubectl get csr jane -o yaml 


#### kubeconfig 
default location of the file - $HOME/.kube/config
kubectl config view

kubectl config use-context prod-user@prod

#### adding multiple config files
export KUBECONFIG=~/.kube/config:/path/to/another/kubeconfig.yaml

## The last file in the list (i.e., rightmost one) takes precedence for current-context
## use context from another config file
kubectl config use-context research --kubeconfig <path to the config file>

apiVersion: v1
kind: Config

current-context: my-cluster-context

clusters:
- name: my-cluster
  cluster:
    server: https://<API_SERVER_ENDPOINT>
    certificate-authority-data: ca.crt
contexts:
- name: my-cluster-context
  context:
    cluster: my-cluster
    user: my-user
    namespace: default
current-context: my-cluster-context
users:
- name: my-user
  user:
    client-certificate: admin.crt
    client-key: admin.key   

#### authorization
kubectl get roles
kubetcl get rolebindings
kubectl describe role <role-name>

kubectl create role pod-reader \
  --verb=get --verb=list --verb=watch \
  --resource=pods \
  --namespace=dev

kubectl create rolebinding pod-reader-binding \
  --role=pod-reader \
  --user=jane \
  --namespace=dev


### check access on resources
kubectl auth can-i create deployment
kubectl auth can-i create pods --as dev-user

### service accounts
kubectl create serviceaccount dash-sa

kubetcl get serviceaccount

kubetcl describe serviceaccount dash-sa

### with service accounts, a secret is created which contained a token which can be used as service-account token.
### default service account for every namespace, and secret associated with service account is mounted to every pod in that namespace.


## updates in release 1.22 and 1.24

### service account token is time bound.

### service account no longer create a secret for storing the token. User need to run below command to generate the token
kubecl create token <service-account-name>


```
