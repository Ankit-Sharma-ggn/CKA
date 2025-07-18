<p align="center">
  <img src="https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.svg"
       alt="Kubernetes Logo" width="140">
</p>

<h1 align="center">Security</h1>

## Authentication

- kubernetes rely on third party app, certificates or ldap solutions to manage user access.

- kube-apiserver authenticate the requests.

- way to manage user access

1. **static password files**: csv file with password, user-name and userid's, and then update the kube-apiserver settings to add option `--basic-auth-file=user-details.csv`.

    `curl -v -k https://master-node-ip:6443/api/v1/pods -u "user1:password123"`
    
2. **Static Token file**: simillar to password file, we can have a static token file for authentication , `--token-auth-file=user-token-details.csv`

    `curl -v -k https://master-node-ip:6443/api/v1/pods -header "Authorization: Bearer KpjsedsddsdfHwe@sexcfded"`

3. **Certificates**

	🔐 [Learn More About Certificates in Kubernetes](Certificate.md)
                            
4. Identity Services, i.e ldap


## Kubeconfig

- The kubeconfig file is a configuration file used by Kubernetes to manage access to clusters. It contains information about clusters, users, and contexts, enabling seamless interaction with Kubernetes clusters using the kubectl command-line tool.

- default location of the file - $HOME/.kube/config

- current-context: value of default user and cluster details when no context is sepcified.

```yaml
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
```

- kubectl commands to edit or view the kubeconfig
```
    kubectl config view

    kubectl config use-context prod-user@prod

    ### adding multiple config files
    export KUBECONFIG=~/.kube/config:/path/to/another/kubeconfig.yaml

    ## The last file in the list (i.e., rightmost one) takes precedence for current-context


```

## Authorization

### Authorization Mode

- Authorization in Kubernetes determines whether a user or service account is allowed to perform a specific action on a resource. After a user is authenticated, Kubernetes uses authorization modes to decide whether the request should be allowed or denied.

**Key Authorization Modes**
Kubernetes supports several authorization modes, which can be enabled individually or in combination. Below are the primary modes:

1. ⚙️ Node Authorization
- Specifically used for **kubelets (nodes)** to interact with the Kubernetes API.
- Ensures that nodes can only access resources they are responsible for (e.g., pods scheduled on them).

---

2. 🔐 RBAC (Role-Based Access Control)
- Most commonly used mode in Kubernetes.
- Grants permissions to **users or service accounts** based on **roles and role bindings**.

📁 RBAC Scope
- **Namespace level**: via `Role` and `RoleBinding`.
- **Cluster-wide**: via `ClusterRole` and `ClusterRoleBinding`.

---

3. 🏷️ ABAC (Attribute-Based Access Control)
- Uses a **JSON or CSV policy file** to define access rules.
- Each request is evaluated against the policy file to determine if it is allowed.

> ⚠️ **Note**: ABAC is less flexible and harder to manage than RBAC.

---

4. 🌐 Webhook Authorization
- Delegates authorization to an **external service**.
- Kubernetes sends the request to the webhook, which returns an **allow** or **deny** decision.
- Useful for **custom logic** and **external policy engines**.

---

5. ✅ AlwaysAllow
- Allows **all requests** unconditionally.
- Ideal for **testing** or **non-production** environments.

---

6. ❌ AlwaysDeny
- Denies **all requests** unconditionally.
- Rarely used, but useful for **debugging** or **special lockdown scenarios**.
---

#### 🔐 RBAC (Role-Based Access Control)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "create", "update"]
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: devuser-developer-binding
subject:
  - kind: User
    name: dev-user
    apiGroup: rbac.authorization.k8s.io/v1
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io/v1
```

- commands for ref

```
kubectl get roles

kubetcl get rolebindings

kubectl describe role <role-name>

### check access on resources

kubectl auth can-i create deployment

kubectl auth can-i create pods --as dev-user


```

**Cluster Role and Cluster role bindinsgs**

For the scope of resources, that is beyond the namespace scope, i.e nodes, certificatesigningrequests.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-admin
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list", "create", "delete"]
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-role-binding
subject:
  - kind: User
    name: clus-admin-user
    apiGroup: rbac.authorization.k8s.io/v1
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io/v1
```

#### Service Accounts

```
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

### Image Security

Image FQDN >> docker.io/library/nginx (Registry/UserorAccount/Image)

- use images from private repository.

- In spec section use Image full path and create a docker-registry secret to store repository credentials.

```
### create a secrets with private registry details
kubectl create secret docker-registry regcred \
--docker-server= private-registry.io \
--docker-username= registry-user \
--docker-password= regist-pass \
--docker-email= reg-us@org.com


### in pod specifications, provide Image full registry path and imagepull secret
spec:
  containers:
  - name: nginx
    image: private-registry.io/apps/internal-image
  imagePullSecrets:
  - name: regcred


```
``
