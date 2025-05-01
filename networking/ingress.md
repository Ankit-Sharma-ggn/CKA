## Ingress

Make your HTTP (or HTTPS) network service available using a protocol-aware configuration mechanism, that understands web concepts like URIs, hostnames, paths, and more. The Ingress concept lets you map traffic to different backends based on rules you define via the Kubernetes API.

- help developers to create single externally accessible url for user to route traffic to different services based on requested urls path.

- works as layer 7 loadbalancer.

- solution we deploy for ingress is called as **ingress controller**, few example of such solutions i.e haproxy, traefik, nginx

- configuration of the ingress controller is done as yaml files which is called as **ingress resources**.

- **Visual** 

    Flow: - External User ➔ LoadBalancer ➔ Ingress Controller ➔ Looks at Ingress Resources ➔ Routes to correct Service ➔ Pod

- components required for deployment
    1. Nginx deployment
    2. Service ( nodeport)
    3. Configmap for env variables\configuration
    4. service account with permissions

Now, in k8s version 1.20+ we can create an Ingress resource from the imperative way like this:-

```
kubectl create ingress <ingress-name> --rule="host/path=service:port"

Example - kubectl create ingress ingress-test --rule="wear.my-online-store.com/wear*=wear-service:80"
```

Ingress rule

## Types of Ingress 

### 1. Ingress backed by a single Service

- specifying a default backend with no rules.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-ingress
spec:
  defaultBackend:
    service:
      name: test
      port:
        number: 80
```

### 2. Simple fanout

A fanout configuration routes traffic from a single IP address to more than one Service, based on the HTTP URI being requested

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simple-fanout-example
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - path: /foo
        pathType: Prefix
        backend:
          service:
            name: service1
            port:
              number: 4200
      - path: /bar
        pathType: Prefix
        backend:
          service:
            name: service2
            port:
              number: 8080
```
exercices on ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
  name: ingress-pay
  namespace: critical-space
spec:
  rules:
  - http:
      paths:
      - path: /pay
        pathType: Prefix
        backend:
          service:
            name: pay-service
            port:
              number: 8282
