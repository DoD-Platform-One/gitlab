## Deploying GitLab with a Dev Instance of Keycloak
### Prerequisites
1. You will need a K8s development environment with two `Gateway` resources configured. One for `passthrough` and the other for `public`. Use the `k3d-dev.sh` script with the `-m` flag to deploy a dev cluster with MetalLB.

1. You will need the following values file saved locally: `keycloak-dev-values.yaml` ([link](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/docs/assets/configs/example/keycloak-dev-values.yaml?ref_type=heads)). 

### Deploying 
Before deploying GitLab and configuring SSO, you need to deploy the dev instance of Keycloak. Use the overrides file below.

1. `overrides.yaml`:
    ```yaml
    clusterAuditor:
      enabled: false
    gatekeeper:
      enabled: false
    istio:
      enabled: true
    istioOperator:
      enabled: true
    kiali:
     enabled: false
    kyverno:
      enabled: false
    kyvernoPolicies:
      enabled: false
    kyvernoReporter:
      enabled: false
    promtail:
      enabled: false
    loki:
      enabled: false
    neuvector:
      enabled: false
    tempo:
      enabled: false
    monitoring:
      enabled: false
    grafana:
      enabled: false
    twistlock:
      enabled: false
    eckOperator:
      enabled: false

    addons:
      keycloak:
        enabled: true 
    ````
1. Deploy BigBang:
    ```bash
    $ helm upgrade -i bigbang ./chart -n bigbang --create-namespace -f ./registry-values.yaml -f ./chart/ingress-certs.yaml -f ./keycloak-dev-values.yaml -f ./overrides.yaml
    ```
    Wait for Keycloak pods to be ready before proceeding.
1. Run sshuttle to connect to your cluster's private network (command was provided once the `k3d-dev.sh` script completed.)
1. Run the following command and copy the results:
    ```bash
    $ curl https://keycloak.dev.bigbang.mil/auth/realms/baby-yoda/protocol/saml/descriptor
    ```
1. Add the following to `overrides.yaml`:
   ```yaml
   addons:
     gitlab:
       enabled: true
       sso:
         enabled: true
         # client_id takien from baby-yoda dev realm: https://repo1.dso.mil/big-bang/product/packages/keycloak/-/blob/main/chart/resources/dev/baby-yoda.json?ref_type=heads#L830
         client_id: dev_00eb8904-5b88-4c68-ad67-cec0d2e07aa6_gitlab
   sso: # derived from docs/assets/configs/example/dev-sso-values.yaml
     name: Keycloak Dev SSO
     url: https://keycloak.dev.bigbang.mil/auth/realms/baby-yoda
     saml:
       metadata: <paste output of curl command here>
     certificateAuthority:
       cert: |
         -----BEGIN CERTIFICATE-----
         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
         -----END CERTIFICATE-----
   ```
1. Upgrade BigBang:
    ```bash
    $ helm upgrade -i bigbang ./chart -n bigbang --create-namespace -f ./registry-values.yaml -f ./chart/ingress-certs.yaml -f ./keycloak-dev-values.yaml -f ./overrides.yaml 
    ```
1. Login to the Keycloak admin console: (`admin/password`) https://keycloak.dev.bigbang.mil/auth/admin/master/console/
1. Switch to the baby-yoda realm. 
1. Create a new user. Be sure to do the following: Switch "Email verified" to "Yes", join the "Impact Level 2 Authorized" group, remove all "Required user actions" (do this after the user is created), create a password (disable "Temporary").
1. Login to Gitlab using SSO and the user you just configured.
1. Setup MFA.
