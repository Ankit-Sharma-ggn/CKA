# 🚀Basic Networking - Docker

## 🔌 Networking Options

1. <mark>None</mark> - container is not connected to anyother container or host network.

<pre> docker run --network none nginx</pre>

2. Host - container is attached to the host network.
 
    📌 Key Points:
    If port 80 is exposed in the container, host port 80 gets attached to it.
    Any request on host port 80 will be forwarded to the container.

    Two containers cannot bind to the same port on the host when using host networking.

3. 