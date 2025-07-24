<p align="center">
  <img src="https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.svg"
       alt="Kubernetes Logo" width="140">
</p>

<h1 align="center">📦 Kubernetes Storage</h1>

🧩 **Container Storage Interface (CSI)**

- The **Container Storage Interface (CSI)** is a standard for exposing storage systems to containerized workloads.  
- It enables support for different storage plug-ins, drivers, and solutions to work with any container runtime, including Docker and containerd.

## Volumes and Mounts

- Volumes provide persistent or shared data to containers. Here's an example using **AWS Elastic Block Store**:

```yaml
spec:
    volumes:
    - name: data-volume
      awsElasticBlockStore:
        volumeID: <volume-id>
        fsType: ext4
```

## 📦 Persistent Volumes (PV)

A **PersistentVolume (PV)** is a piece of storage in the Kubernetes cluster that has been provisioned by an administrator or dynamically through a StorageClass.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
    name: pv-vol1
spec:
    accessModes:
        - ReadWriteOnce
    capacity:
        stprage: 1Gi
    hostPath:
        path: /tmp/data
```

## 📝 Persistent Volume Claims (PVC)

A **PersistentVolumeClaim (PVC)** is a user's request for storage. Kubernetes will match the PVC to an available PV.

- PVC is bound to a PV based on size, access mode, and optionally labels/selectors.
- If no matching PV is available, the claim remains in a `Pending` state.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: pv-myclaim
spec:
    accessModes:
        - ReadWriteOnce
    resources:
        requests:
            storage: 500Mi
```

```yaml
## using PVC in a pod def file
spec:
  containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: myclaim
```
## ⚙️ Dynamic Provisioning with StorageClass

**Dynamic provisioning** allows storage to be created automatically using a StorageClass when a PVC is requested.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
    google-storage
provisioner: kubernetes.io/gce-pd
```

```yaml
## using PVC for dynamic provisioning
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: pv-myclaim
spec:
    accessModes:
        - ReadWriteOnce
    storageClassName: google-storage
    resources:
        requests:
            storage: 500Mi
```