# Introduction to pods

A Pod in Kubernetes is the smallest deployable unit of computing that can be created and managed within a Kubernetes cluster. It represents a group of one or more containers that share storage, network resources, and a specification for how to run the containers

## definition file

pod-def.yml
```yml
apiVersion: v1
kind: Pod
metadata:
    name: myapp-pod
    labels:
        app: myapp
        type: front
        ver: 1
spec:
    containers:
        - name: nginx-container
          image: nginx
```

- create pod using yml file
    `kubectl create -f pod-def.yml`
    `kubectl apply -f pod-def.yml`

- see pods
    <pre>`kubectl get pods`</pre>

- detail information about pod
    <pre>kubectl describe pod <pod-name></pre>

- create pods without def file
    `kubectl run nginx --image=nginx`

- Generate POD Manifest YAML file (-o yaml). Don't create it(--dry-run)
    `kubectl run nginx --image=nginx --dry-run=client -o yaml`

- Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run) and save it to a file.
    `kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml`

## ReplicaSets ( previously ReplicationController)

Kubernetes resource that ensures a specified number of pod replicas are running at any given time. It is responsible for maintaining the desired state of the application by monitoring the actual state and making adjustments as needed

- It is commonly used to provide high availability and fault tolerance for applications.
- provide load balancing and scaling.

ReplicationController definition
rc-def.yml
```yml
apiVersion: v1
kind: ReplicationController
metadata:
    name: myapp-rc
    labels:
        app: myapp
        type: front
spec:
    template:
        metadata:
            name: myapp-pod
            labels:
                app: myapp
                type: front
                ver: 1
        spec:
            containers:
                - name: nginx-container
                image: nginx
    replicas: 3
    
```

replicaset definition
rcset-def.yml
```yml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: myapp-rcset
    labels:
        app: myapp
        type: front
spec:
    template:
        metadata:
            name: myapp-pod
            labels:
                app: myapp
                type: front
                ver: 1
        spec:
            containers:
                - name: nginx-container
                image: nginx
    replicas: 3
    selector:
        matchLabels:
            type: front
    
```

`kubectl apply -f rcset-def.yml`

- to update a replicaset

`kubectl replace -f rcset-def.yml`
`kubectl scale --replicas=6 -f rcset-def.yml`
`kubectl scale --replicas=6 -f replicaset myapp-rcset`

Save object config to file
`kubectl get replicaset <repliaceset name> -o=yaml > updated-replicaset.yaml`

`kubectl replace replicaset <repliaceset name> -f updated-replicaset.yaml`


## Deployment

A Deployment in Kubernetes is a resource that allows users to manage and control the lifecycle of applications running in a Kubernetes cluster

- allow rolling upgrade
- undo changes if required
- automatically create a replicaset

deployment definition
dep-def.yml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: myapp-rcset
    labels:
        app: myapp
        type: front
spec:
    template:
        metadata:
            name: myapp-pod
            labels:
                app: myapp
                type: front
                ver: 1
        spec:
            containers:
                - name: nginx-container
                image: nginx
    replicas: 3
    selector:
        matchLabels:
            type: front
    
```

-  Get all components  
    <pre>kubectl get all</pre>


 
