# 🚀Basic Networking - Docker

## 🔌 Networking Options

List down all the available network 

<pre> docker network ls</pre>

1. <mark>None</mark> - container is not connected to anyother container or host network.

<pre> docker run --network none nginx</pre>

2. Host - container is attached to the host network.
 
    📌 Key Points:

    a. If port 80 is exposed in the container, host port 80 gets attached to it.
    Any request on host port 80 will be forwarded to the container.

    b. Two containers cannot bind to the same port on the host when using host networking.

3. Bridge - Docker creates a private internal network on the host, each      container gets its own IP address within this private network.

    📌 Key Points:
    a. Default network mode for containers if no specific network is mentioned.

    b. Containers can communicate with each other via IP or container name (if connected to the same user-defined bridge network).

    c. To expose ports to the host, use the -p or --publish flag:
    
    <pre> docker run -d -p 8080:80 nginx </pre>

    This maps host port 8080 to container port 80
