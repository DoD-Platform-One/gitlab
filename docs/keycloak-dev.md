# Deploying GitLab with a Dev Instance of Keycloak

## Prerequisites

1. You will need to deploy a cluster using the [k3d-dev.sh](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/docs/community/development/aws-k3d-script.md) script, leveraging the [Keycloak testing environment instructions](https://repo1.dso.mil/big-bang/product/packages/keycloak/-/blob/main/docs/DEVELOPMENT_MAINTENANCE.md?ref_type=heads#testing-environment-setup).

## Deploying

After following the [Keycloak testing environment instructions](https://repo1.dso.mil/big-bang/product/packages/keycloak/-/blob/main/docs/DEVELOPMENT_MAINTENANCE.md?ref_type=heads#testing-environment-setup) to deploy keycloak, use the following instructions to integrate it with Gitlab.

1. Deploy BigBang:

    ```bash
    helm upgrade -i bigbang ./chart -n bigbang --create-namespace -f ./registry-values.yaml -f ./chart/ingress-certs.yaml -f ./path/to/keycloak-dev-values.yaml -f ./overrides.yaml
    ```

    Wait for Keycloak pods to be ready before proceeding.
1. Run sshuttle to connect to your cluster's private network (command was provided once the `k3d-dev.sh` script completed.)
1. Run the following command and copy the results:

    ```bash
    curl https://keycloak.dev.bigbang.mil/auth/realms/baby-yoda/protocol/saml/descriptor
    ```

1. Add the following to `overrides.yaml`:

```yaml
addons:
  gitlab:
    enabled: true
    sso:
      enabled: true
      label: "Platform One SSO"
      client_id: "platform1_a8604cc9-f5e9-4656-802d-d05624370245_bb8-gitlab"  
```

1. Upgrade BigBang:

    ```bash
    helm upgrade -i bigbang ./chart -n bigbang --create-namespace -f ./registry-values.yaml -f ./chart/ingress-certs.yaml -f ./keycloak-dev-values.yaml -f ./overrides.yaml 
    ```

1. Create a new user account on [keycloak](https://keycloak.dev.bigbang.mil)
1. After creating your account, log in to the Keycloak admin console: (`admin/password`) <https://keycloak.dev.bigbang.mil/auth/admin/master/console/>
1. Switch to the baby-yoda realm.
1. Click on "Users" on the left navigation bar and select your user. Be sure to do the following: Switch "Email verified" to "Yes", remove all "Required user actions", and join the "Impact Level 2 Authorized" group.
1. Login to Gitlab using SSO and the user you just configured.

## OmniAuth oidc-provider SSO setup

- Reference [keycloak.md](https://repo1.dso.mil/big-bang/product/packages/gitlab/-/blob/main/docs/keycloak.md?ref_type=heads) for omniauth global configuration and more override examples.
