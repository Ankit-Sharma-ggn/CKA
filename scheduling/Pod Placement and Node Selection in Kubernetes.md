# Pod Placement and Node Selection in Kubernetes

## Labels and Selectors

- `Labels`: To distingusih and categories object within cluster, kubernetes uses labels.

- `selector`: to filter objects and get the details of desired objects in cluster, kubernetes uses selectors.

```yaml
#labels definition in pod config file.
metadata:
    name: myapp-pod
    labels:
        app: myapp
        type: web-app
        tier: frontend
```

- List pod based on labels
    `kubectl get pods --selector app=myapp`

- select all object based on lables
    `kubectl get all --sekector app=myapp,tier=frontend`

- Another use of labels and selectors in kubernetes, is to bind objects i.e pods with repliacset.
```yaml
# repliace set definition, this should match the labels on pod
spec:
    selector:
        matchLabels:
        app: app1
```

## Taints
- tainting a node means, applying a taint on node so no pod without toleration can be schedule on this node.

- add taints on node
    `kubetcl taint node node01 app=blue:<taint-effect>`

    `kubetcl taint node node01 app=blue:NoSchedule`

check for taints
    `kubectl decribe node node01 | grep Taint`

remove taint on node
    `kubetcl taint node node01 app=blue:NoSchedule-`

There are 3 kind of taint-effetc:-
1. `NoSchedule`: No pod will be schedule except for the pods with toloeration
2. `PreferNoSchedule`: Prefer not to schedule pods, but no guarantee.
3. `NoExecute`: No new pod will be schedule and running pods will be evicted.

## Toleration
- to run a pod on tainte nodes, we need to add tolerations on pod. 

i.e

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: app
    labels:
        app: nginx
spec:
    containers:
    -   name: ng
        image: nginx
    tolerations:
    - key: "app"
      operator: "Equal"
      value: "blue"
      effect: "NoSchedule"
```

## Node Selectors

- for selection of nodes for the pods, we can use labels to define the node selection.

- labeling a node
    ```
    kubectl label nodes <node-name> <label-key>=<label-value>

    kubectl label nodes node01 size=Large
    ```

```yaml
## Pod configuration file for scheduling the pod on the node where we have label size=Large
apiVersion: v1
kind: Pod
metadata:
    name: myapp-pod
spec:
    containers:
    -   name: data-pr
        image: web-data
    nodeSelector:
        size: Large
```

Limitations with Node Selectors:-
    a. We cannot have or, and and not expressions configured for Node Selectors.
        NOT Large
        Large and Medium

## Node Affinity

- a feature that allows you to control which nodes a pod is eligible to be scheduled on, based on the labels of the nodes.

-  It is a more flexible and expressive way to constrain pod placement compared to nodeSelector,

Node affinity comes in two main forms:

### RequiredDuringSchedulingIgnoredDuringExecution:

- This is a "hard" rule.
- If the node does not match the specified affinity rules, the pod will not be scheduled on that node.
- Once the pod is running, the rule is "ignored during execution," meaning the pod will not be evicted if the node's labels change and no longer match the affinity rule.

### PreferredDuringSchedulingIgnoredDuringExecution:

- This is a "soft" rule.
- The scheduler will try to place the pod on a node that matches the affinity rule, but it is not mandatory. If no nodes match, the pod can still be scheduled on other nodes.
- Like the "required" rule, it is "ignored during execution," so the pod will not be evicted if the node's labels change.

```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: region
            operator: In
            values:
            - us-west-1
```
