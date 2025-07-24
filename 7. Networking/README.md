<p align="center">
  <img src="https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.svg"
       alt="Kubernetes Logo" width="140">
</p>

<h1 align="center">📦 Kubernetes Networking</h1>

## Network Namespaces

- An isloated network stack that allows process ( containers) to have their own network interface, routing tables.

- Each container runs in its own network namespace, which means:

    a. It can have a unique IP address

    b. It does not share network interfaces with the host or other containers

    c. You can apply firewall and routing rules independently

    d. Containers can communicate through virtual interfaces (veth pairs)

```
## 🔍 View Network Namespaces
ip netns list

## ➕ Create a Network Namespace
ip netns add blue

## 🔍 View Network interfaces on host
ip link

## 🔍 View Network interfaces on namespace
ip netns exec blue ip link
ip -n blue link

## add a link
ip link add veth-red type veth peer name veth-blue

## add the link to the network interfaces
ip link set veth-red netsh red
ip link set veth-blue netsh blue

## assign ip to both interfaces
ip -n red addr add 192.168.15.1 dev veth-red
ip -n blue addr add 192.168.15.2 dev veth-blue

## bring the interfaces up
ip -n red link set veth-red up
ip -n blue link set veth-blue up

```

## Cluster Networking

List of all the ports for cluster working - [Ports and Protocols](https://kubernetes.io/docs/reference/networking/ports-and-protocols/)

[]()

## Pod Networking