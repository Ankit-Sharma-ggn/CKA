## Ingress

* help developers to create single externally accessible url for user to route traffic to different services based on requested urls path.

- help developers to create single externally accessible url for user to route traffic to different services based on requested urls path.

- works as layer 7 loadbalancer.

- you solution we deploy for ingress is called as **ingress controller**, few example of such solutions i.e haproxy, traefik, nginx

- configuration of the ingress controller is done by **ingress resources**.

- components required for deployment
    1. Nginx deployment
    2. Service ( nodeport)
    3. Configmap for env variables\configuration
    4. service account