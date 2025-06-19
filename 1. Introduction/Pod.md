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
    ```
    kubectl create -f pod-def.yml
    kubectl apply -f pod-def.yml
    ```

- see pods
    <pre>kubectl get pods</pre>

- detail information about pod
    <pre>kubectl describe pod #pod-name# </pre>

- create pods without def file
    <pre>kubectl run nginx --image=nginx</pre>

    <pre>kubectl run redis --image=redis:alpine --labels tier=db</pre>

- Generate POD Manifest YAML file (-o yaml). Don't create it(--dry-run)
    <pre>kubectl run nginx --image=nginx --dry-run=client -o yaml</pre>

- Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run) and save it to a file.
    <pre>kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml</pre>

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

- create replicaset
    <pre>kubectl apply -f rcset-def.yml </pre>


- to update a replicaset
    ```
    kubectl replace -f rcset-def.yml
    kubectl scale --replicas=6 -f rcset-def.yml
    kubectl scale --replicas=6 -f replicaset myapp-rcset
    ```

- Save object config to file
    ```
    kubectl get replicaset <repliaceset name> -o=yaml > updated-replicaset.yaml

    kubectl replace replicaset <repliaceset name> -f updated-replicaset.yaml
    ```


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


## Namespace

- logical separation of resources in kubernetes are done by namespace.
- Admin can set up quotas, roles-permissions, and policies over namespaces.
- resources withing same namespaces can refer each other by name, to reach other service in "dev" namespace the dns name will be <svc-name>.dev.svc.cluster.local.
- default, kube-system - both are created by kubernetes, when it is set-up. Kube-system is for the system service pods i.e controller, dns and others.

```
    kubectl get pods --namespace=kube-system    #List all the pods in kube-system namespace

    kubectl create -f pod-def.yml --namespace=dev  #creating pod in dev namespace

    #Pod Config
    apiVersion: v1
    kind: Pod
    metdata:
        name: myapp-pod
        namespace: dev
        labels:
            app: myapp
    spec:
        containers:
        - name: nginx-container
          image: nginx

    #Namespace Config
    apiVersion: v1
    kind: Namespace
    metdata:
        name: dev

    kubectl create namespace dev         #creating a namespace
    
    kubectl config set-context $(kubectl config current=context) --namespace=dev   #setting current namespace context

    kubect get pods --all-namespaces         #getting all the pods in all the namespaces
```

## Imperative vs Declarative

- Imperative: set of multiple instructions to achieve desired goal. i.e like running multiple commands 

- Decarative: declare the desire config in a file in json or YAML. i.e Pod definition file

Note: imperative commands can help in getting one time tasks done quickly, as well as generate a definition template easily. This would help save considerable amount of time during your exams.

`--dry-run`: By default as soon as the command is run, the resource will be created. If you simply want to test your command , use the `--dry-run=client` option. This will not create the resource, instead, tell you whether the resource can be created and if your command is right.

`-o yaml`: This will output the resource definition in YAML format on screen.

```
    kubectl run nginx --image=nginx --dry-run=client -o yaml

    kubectl run custom-nginx --image=nginx --port=8080   ### 

    kubectl create deployment nginx-dep --image=nginx  --dry-run=client -o yaml

#Create a Service named redis-service of type ClusterIP to expose pod redis on port 6379

    kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml

    
    kubectl create service clusterip redis --tcp=6379:6379 --dry-run=client -o yaml
Note : This will not use the pods labels as selectors, instead it will assume selectors as app=redis
```

## Kubectl apply command
`kubectl apply -f nginx.yaml`  ## create objects

`kubectl apply -f nginx.yaml`  ## update object

steps:
1. check for the existing resources, if it doesn't exist, create the object.
2. Kubernetes create a "Live Object Configuration" and "Last applied configuration (in json)".
3. When there is any further modification in configuration file, the config is compared with live config and changes are applied after comparision. Then changes were updated in last applied config.
4. Last applied config help us to find the fields deleted\removed from config file.

- Location of last applied config:- within live object configuration "metadata>annotations"

- last applied config is only created when apply command is executed.

 
