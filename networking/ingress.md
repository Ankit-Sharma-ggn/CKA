## Ingress

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