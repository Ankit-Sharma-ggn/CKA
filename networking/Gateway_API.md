## Gateway API

Make network services available by using an extensible, role-oriented, protocol-aware configuration mechanism. Gateway API is an add-on containing API kinds that provide dynamic infrastructure provisioning and advanced traffic routing.

### Design principles
The following principles shaped the design and architecture of Gateway API:

- **Role-oriented**: Gateway API kinds are modeled after organizational roles that are responsible for managing Kubernetes service networking:
    - *Infrastructure Provider*: Manages infrastructure that allows multiple isolated clusters to serve multiple tenants, e.g. a cloud provider.
    - *Cluster Operator*: Manages clusters and is typically concerned with policies, network access, application permissions, etc.
    - *Application Developer*: Manages an application running in a cluster and is typically concerned with application-level configuration and Service composition.

- **Portable**: Gateway API specifications are defined as custom resources and are supported by many implementations.

- **Expressive**: Gateway API kinds support functionality for common traffic routing use cases such as header-based matching, traffic weighting, and others that were only possible in Ingress by using custom annotations.

- **Extensible**: Gateway allows for custom resources to be linked at various layers of the API. This makes granular customization possible at the appropriate places within the API structure.

### Resource model

Gateway API has three stable API kinds:

![Gateway API](.\images\api_gateway.png)

- *GatewayClass*: Defines a set of gateways with common configuration and managed by a controller that implements the class.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: example-class
spec:
  controllerName: example.com/gateway-controller
```

- *Gateway*: Defines an instance of traffic handling infrastructure, such as cloud load balancer.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: example-gateway
spec:
  gatewayClassName: example-class
  listeners:
  - name: http
    protocol: HTTP
    port: 80
```

advance gateway 

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: nginx-gateway
  namespace: nginx-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
      from: All
```

- *HTTPRoute*: Defines HTTP-specific rules for mapping traffic from a Gateway listener to a representation of backend network endpoints. These endpoints are often represented as a Service.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: example-httproute
spec:
  parentRefs:
  - name: example-gateway
  hostnames:
  - "www.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /login
    backendRefs:
    - name: example-svc
      port: 8080
```

advance

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: frontend-route
spec:
  parentRefs:
  - name: nginx-gateway
    namespace: nginx-gateway
  hostnames:
  - "*"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: frontend-svc
      port: 80
```


