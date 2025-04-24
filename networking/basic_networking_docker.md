# Basic Networking - Docker

## Networking options

1. None - container is not connected to anyother container or host network.

<pre> docker run --network none nginx</pre>

2. Host - container is attached to the host network.

    a.  If port 80 is exposed on conatiner, the host port 80 get attached to the container and any request on host port 80 will be forwarded to container.

    b. No 2 container can be attached to one port in host networking.  

3. 