##################################
9.12 Troubleshooting and Debugging
##################################

**Diagnosing and Fixing Kubernetes Issues**

Effective troubleshooting requires systematic approaches and the right tools to identify and resolve problems quickly.

===================
Pod Troubleshooting
===================

**Common Pod Issues**

.. code-block:: bash

    # Check pod status
    kubectl get pods
    kubectl describe pod problematic-pod
    kubectl logs problematic-pod
    kubectl logs problematic-pod --previous
    
    # Multiple containers
    kubectl logs pod-name -c container-name
    kubectl exec -it pod-name -c container-name -- sh

**Pod Debugging**

.. code-block:: yaml

    # Debug pod with tools
    apiVersion: v1
    kind: Pod
    metadata:
      name: debug-pod
    spec:
      containers:
      - name: debug
        image: nicolaka/netshoot
        command: ["sleep", "3600"]

.. code-block:: bash

    # Debug running pod
    kubectl debug pod-name -it --image=busybox

======================
Service and Networking
======================

**Network Connectivity Issues**

.. code-block:: bash

    # Test service connectivity
    kubectl run test-pod --image=busybox --rm -it -- sh
    nslookup service-name
    wget -qO- service-name:port
    
    # Check endpoints
    kubectl get endpoints service-name
    kubectl describe service service-name

**Network Policy Debugging**

.. code-block:: bash

    # Check network policies
    kubectl get networkpolicies
    kubectl describe networkpolicy policy-name
    
    # Test connectivity between pods
    kubectl exec pod1 -- ping pod2-ip

===============
Resource Issues
===============

**Resource Constraints**

.. code-block:: bash

    # Check resource usage
    kubectl top nodes
    kubectl top pods --all-namespaces
    kubectl describe node node-name
    
    # Check events for resource issues
    kubectl get events --sort-by=.metadata.creationTimestamp
    kubectl describe pod pending-pod

**Storage Issues**

.. code-block:: bash

    # Check PVC status
    kubectl get pvc
    kubectl describe pvc my-pvc
    kubectl get pv
    
    # Check storage class
    kubectl get storageclass
    kubectl describe storageclass standard

==================
Application Issues
==================

**Health Check Failures**

.. code-block:: bash

    # Check probe configurations
    kubectl describe pod app-pod
    kubectl logs app-pod
    
    # Test health endpoints manually
    kubectl port-forward pod/app-pod 8080:8080
    curl localhost:8080/health

**Configuration Problems**

.. code-block:: bash

    # Check ConfigMaps and Secrets
    kubectl get configmaps
    kubectl describe configmap app-config
    kubectl get secrets
    
    # Verify environment variables
    kubectl exec pod-name -- env

====================
Cluster-Level Issues
====================

**Node Problems**

.. code-block:: bash

    # Check node status
    kubectl get nodes
    kubectl describe node node-name
    kubectl get events --field-selector involvedObject.kind=Node
    
    # Check node resources
    kubectl top node node-name

**API Server Issues**

.. code-block:: bash

    # Check cluster components
    kubectl get componentstatuses
    kubectl cluster-info
    kubectl get events --all-namespaces

============================
Essential Debugging Commands
============================

.. code-block:: bash

    # General debugging
    kubectl get events --sort-by=.metadata.creationTimestamp
    kubectl describe <resource-type> <resource-name>
    kubectl logs -f deployment/app-name
    
    # Resource inspection
    kubectl get <resource> -o yaml
    kubectl get <resource> -o wide
    kubectl top nodes/pods
    
    # Interactive debugging
    kubectl exec -it pod-name -- /bin/bash
    kubectl port-forward pod/pod-name 8080:8080
    kubectl debug node/node-name -it --image=busybox

============
What's Next?
============

Finally, we'll explore **Kubernetes Operators** for extending Kubernetes functionality.
