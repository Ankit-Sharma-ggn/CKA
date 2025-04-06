# Storage

## Volumes
A volume in Kubernetes is a directory accessible to containers in a pod, used to store and share data. Unlike container storage, volumes persist data beyond the container's lifecycle within the pod's lifespan.

example > [volumes.yaml](https://github.com/Ankit-Sharma-ggn/CKA/blob/main/storage/volumes.yaml) 

## Persistent Volumes

* large pool of volume to be use by pods\container deployed by users.
* Access Modes "accessModes"
    1. ReadOnlyMany - 
    2. ReadWriteOnce
    3. ReadWriteMany

example > [pv.yaml](https://github.com/Ankit-Sharma-ggn/CKA/blob/main/storage/pv.yaml)

## Persistent Volume Claims

* a way to request storage for container in kubernetes, it is bound to one PV at a time based on availiablity of
  capacity, access mode, volume modes and storage class.

* labels can be specified for binding 

* if no capacity is available, pvc will remain in pending state.

<pre> kubectl delete persistentvolumeclaim "myclaim" </pre>

* persistentVolumeReclaimPolicy - to decide what to do with pv after pvc deletion. We have three options
    1. Retain - pv will not be deleted and data will remain there
    2. Delete - pv will deleted with pvc deletion
    3. recycle - pv will be recycle and made available for other pvc

## Storage Class in Kubernetes

* When working with persistent storage in Kubernetes, it's important to understand the difference between manual provisioning and dynamic provisioning of volumes.

### ❌ Without StorageClass ( static provisioning )

* You must manually create the PersistentVolume (PV) in advance. The storage (e.g., AWS EBS, GCP Persistent Disk) must be provisioned outside of Kubernetes. Your PersistentVolumeClaim (PVC) will only bind if a matching PV is available. This process is static and requires manual intervention.

### ✅ With StorageClass ( Dynamic provisioning)
* Kubernetes handles dynamic provisioning of storage. When a PVC is created, Kubernetes automatically provisions the underlying storage (e.g., EBS, PD).

* No need to manually create PV objects.

* You simply define the StorageClass, and Kubernetes takes care of the rest.

* a simple storage class defination
    <pre>
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
    name: google-storage
    provisioner: kubernetes.io/gce-pd
    </pre>

* how to use it in a pvc to create a pv automatically
    <pre> 
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
    name: my-pvc
    namespace: default
    spec:
    accessModes:
        - ReadWriteOnce
    resources:
        requests:
        storage: 1Gi
    storageClassName: google-storage
    </pre>
