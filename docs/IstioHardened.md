# Istio Hardened
Big Bang has added the `.Values.istio.hardened` map attibute to the values of applications that can be istio-injected (when `.Values.istio.enabled` is `true`).  This document walks through the impact of setting `.Values.istio.hardened: true` on how traffic is managed within a given istio-injected package.

## Prerequisites
In order for `.Values.istio.hardened.enabled: true` to have any impact, the package must also have `.Values.istio.enabled: true` set.  This is because all of the resources created by setting `.Values.istio.hardened.enabled: true` are applied to the istio service mesh, which includes istio sidecar proxies.  If there are no istio proxies, then no mesh components exist in the namespace and therefore istio Kubernetes resources in the namespace will not effect anything.

## REGISTRY_ONLY Istio Sidecar resources
When `.Values.istio.hardened.enabled: true` is set, a `Sidecar` resource is applied to the package's namespace that sets the outboundTrafficPolicy of the Sidecar to `REGISTRY_ONLY`.  What this means is that for pods with an istio-proxy running as a "sidecar", the only egress traffic allowed is for traffic that is destinated for a service that exists within the istio service mesh registry.

By default, all Kubernetes Services are added to this registry.  However, cluster-external hostnames, IP addresses, and other endpoints will NOT be reachable with this Sidecar in place.  For example, if an application attempts to reach out to the Kubernetes API Service at `kubernetes.default.svc.cluster.local` (or any of it's SANs), the request will not be blocked by the Sidecar.  Conversely, if the application attempts to reach out to s3.us-gov-west-1.amazonaws.com, the request with fail unless there is a ServiceEntry (see below) that adds s3.us-gov-west-1.amazonaws.com to the service mesh registry. This Sidecar is added in order to provide defense in depth, working alongside NetworkPolicies to prevent data exfiltration by malicious actors.

## ServiceEntry Istio resources
Because some applications have well-documented requirements to reach out to cluster external endpoints (S3 is one common example), Big Bang has added ServiceEntries to get those endpoints included in the Istio service registry.  If we missed one, please open an issue detailing what endpoint needs to be whitelisted with a ServiceEntry.  Alternatively, you can create your own whitelisted endpoints by using the `.Values.istio.hardened.customServiceEntries` list, which will generate a ServiceEntry according to the `.spec` map you set.

> `customServiceEntries` is there for *edge cases* that may be specific to your requirements, and not all `customServiceEntries` may be appropriate for all Big Bang users.

### Example customServiceEntry
To create a ServiceEntry for google, the corresponding customServiceEntry attribute could be set:
```yaml
istio:
  enabled: true
  hardened:
    enabled: true
    customServiceEntries:
      - name: "allow-google"
        enabled: true
        spec:
          exportTo:
            - "."
          hosts:
            - google.com
          location: MESH_EXTERNAL
          ports:
            - number: 443
              protocol: TLS
              name: https
          resolution: DNS
```

This would result in the following ServiceEntry being created:
```yaml
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: allow-google
  namespace: my-app-namespace
spec:
  exportTo:
    - "."
  hosts:
  - google.com
  location: MESH_EXTERNAL
  ports:
  - name: https
    number: 443
    protocol: TLS
  resolution: DNS
```

For more information on writting ServiceEntries, see [this documentation](https://istio.io/latest/docs/reference/config/networking/service-entry/)