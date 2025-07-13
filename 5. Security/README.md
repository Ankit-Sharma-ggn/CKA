<p align="center">
  <img src="https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.svg"
       alt="Kubernetes Logo" width="140">
</p>

<h1 align="center">Security</h1>

## Authentication

- kubernetes rely on third party app, certificates or ldap solutions to manage user access.

- kube-apiserver authenticate the requests.

- way to manager user access
    1. **static password files**: csv file with password, user-name and userid's, and then update the kube-apiserver settings to add option `--basic-auth-file=user-details.csv`

    `curl -v -k https://master-node-ip:6443/api/v1/pods -u "user1:password123"`
    
    2. **Static Token file**: simillar to password file, we can have a static token file for authentication, `--token-auth-file=user-token-details.csv`

    `curl -v -k https://master-node-ip:6443/api/v1/pods -header "Authorization: Bearer KpjsedsddsdfHwe@sexcfded"`

    3. Certificates 

      ## link -> ![Certificates](Certificate.md)
                            
    4. Identity Services, i.e ldap

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
