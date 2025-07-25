<p align="center">
  <img src="https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.svg"
       alt="Kubernetes Logo" width="140">
</p>

<h1 align="center">Application Lifecycle Management</h1>

## Rolling updates and Rollbacks

**Deployment Strategy**

1. `Recreate`: Deleting all older version pods together and then create them with new version. This kind of strategy involve application downtime.

```yaml
## in deployment definition file

spec:
  strategy:
    type: Recreate
```

2. `RollingUpdate`: Deletion older pods one by one and creating the newer version pods simultaneously. Default mode of upgrade.

```yaml
## in deployment definition file

spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
```

**commands**

```
## check rollout status
kubectl rollout status deployment/my-depl1

kubectl rollout history deployment/my-depl1

##upgrade image on deployement
kubectl apply -f deployement.yml   ## updating image version in definition file

## using command to set the image on deployement.
kubectl set image deployement/my-depl1 nginx=nginx:1.9.1
```

**Rollback**

`kubectl rollout undo deployement/my-depl1`


## Application - 

### Commands and Arguments

Defining commands and arguments at pod level can be done using the field `command` and `args` under spec section in pod definition file.

```yaml
spec:
    containers:
    - name: ubuntu
      image: ubuntu
      command: ["sleep"]
      args: ["5"]
```

### ENV Variables
- defining ENV variables in pod definition file.
```yaml
spec:
    containers:
    - name: web-color
      image: webapp
      env:
        - name: APP_COLOR    ## ENV variable name
          value: ping        ## ENV variable value
```

#### Using Config Map

- use to pass configurational data to pods in key pair format

```bash
APP_COLOR: blue
APP_MODE: prod
```
##### Creating Config Map

- imperative way of creating config Map

  `kubectl create configmap app-config --from-literal=APP_COLOR=blue --from-literal=APP_MODE=prod`

  `kubectl create config app-config --from-file=app_config.properties`

- declarative way
```yaml
## config-map.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_COLOR: blue
  APP_MODE: prod

## create using kubectl create command
kubectl create -f config-map.yaml

## get config-map
kubectl get configmaps

kubectl describe configmaps
```

##### ConfigMap in Pods

```yaml
spec:
    containers:
    - name: web-color
      image: webapp
      envFrom: 
        - configMapRef:
          name: app-config
```
### Secrets

- a way to store passwords and sensitive information in kubernetes.

```yaml
kubectl create secret generic app-secret --from-literal=DB_Host=mysql

kubectl create secret generic app-secret --from-file=app_secret.properties
```

- declarative way
```yaml
## app_secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app_secret
data:
  DB_Host: mysql
  DB_Password: paswrd
```

- We should not have the plain text in secret values in definition file. 
  `echo -n mysql | base64`

- adding secrets in Pods
```yaml
spec:
    containers:
    - name: web-color
      image: webapp
      envFrom: 
        - secretRef:
          name: app-secret
```

- Single Secret to pod

```yaml
spec:
    containers:
    - name: web-color
      image: webapp
      env: 
        - secretRef:
          name: DB_Password
          valueFrom:
            secretKeyRef:
              name: app_secret
              key: DB_Password
```

### InitContainers

- In a multi-container pod, each container is expected to run a process that stays alive as long as the POD's lifecycle. If any of them fails, the POD restarts.

- An initContainer is configured in a pod like all other containers, except that it is specified inside a initContainers section,  like this:

```yaml
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox
    command: ['sh', '-c', 'git clone <some-repository-that-will-be-used-by-application> ; done;']
```

- When a POD is first created the initContainer is run, and the process in the initContainer must run to a completion before the real container hosting the application starts. 

## Autoscaling

### HPA

- Horizontal pod autoscaler, add\remove pods to deployment based on matrices. Rely on metric servers to get the resource metrices.

- HPA comes inbuilt in Kubernetes since version 1.23


`kubectl autoscale deployment deply-1 --cpu-percent=50 --min=1 --max=10`

`kubectl get hpa`

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 1
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

### VPA 

- Vertical pod autoscaler, add\remove cpu or memory to pod, based on the matrices. It is not a built in component.

- Incase of update of resources in pod, default behaviour is to recreate the pod and have the required resources.

- In-pace resize of the pods are now available in v1.27 alpha release, which is by-default is disabled state.



    `FEATURE_GATES=InPlacePodVerticalScaling=true`

```yaml
spec:
    containers
    - name: nginx
      image: nginx
      resizepolicy:
        - resourceName: cpu
          restartPolicy: NotRequired
        - resourceName: memory
          restartPolicy: RestartContainer
```


