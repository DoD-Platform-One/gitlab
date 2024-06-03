### Prerequisites

The integration assumes that keycloak is deployed with a realm other than master (eg: baby-yoda) and a client within named gitlab. The secret is used in the gitlab keycloak configuration.

This documentation is geared towards configuring GitLab to work with P1 SSO/`login.dso.mil`. To learn about deploying GtitLab with a dev version of Keycloak, see [keycloak-dev.md](./keycloak-dev.md).

If the client gitlab doesn't exist in keycloak, please create the client gitlab with the following settings:
1.  Create a gitlab OIDC client scope. The scope name is case sensitive and must match the oidc settings that Gitlab was deployed with. Bigbang Gitlab settings are expecting scope name "Gitlab" with a capital G. Use the following mappings:
    
    | Name        | Mapper Type      | Mapper Selection Sub | Token Claim Name   | Claim JSON Type |
    |-------------|------------------|----------------------|--------------------|-----------------|
    | email       | User Property    | email                | email              | String          |
    | profile     | User Attribute   | profile              | N/A                | String          |
    | username    | User Property    | username             | preferred_username | String          |
  
2.  Create a gitlab client 
    - Change the following configuration items
      - access type: confidential _this will enable "Credentials"_
      - Direct Access Grants Enabled: Off
      - Valid Redirect URIs: https://code.${DOMAIN}/users/auth/openid_connect/callback
      - Base URL: https://code.${DOMAIN}
    - Set Client Scopes
      - Default Client Scopes: Gitlab (the client scope you created in the previous step. This is case sensitive.)
      - optional client scopes: N/A
    - Take note of the client secret in the credential tab

### GitLab configuration for keycloak

Reference Gitlab [documentation for SSO](https://docs.gitlab.com/charts/charts/globals.html#omniauth). This is a working example of the json configuration used for keycloak integration. 
```
{
  "name": "openid_connect",
  "label": "Platform One SSO",
  "args": {
    "name": "openid_connect",
    "scope": [
      "Gitlab"
    ],
    "response_type": "code",
    "issuer": "https://login.dso.mil/auth/realms/baby-yoda",
    "client_auth_method": "query",
    "discovery": true,
    "uid_field": "preferred_username",
    "client_options": {
      "identifier": "platform1_a8604cc9-f5e9-4656-802d-d05624370245_bb8-gitlab",
      "secret": "your-secret-here",
      "redirect_uri": "https://code.dev.bigbang.mil/users/auth/openid_connect/callback",
      "end_session_endpoint": "https://login.dso.mil/auth/realms/baby-yoda/protocol/openid-connect/logout"
    }
  }
}
```
Fill in your values and create a json file with the contents in a temporary directory somewhere. You can name the file gitlab-oidc.json. Encode the contents with base64
```
cat gitlab-oidc.enc.json | base64 -w 0
```
The encoded output is what you will use in the next step. The ```-w 0``` insures that the encoded value is a one line string.

### Create a secret in Gitlab namespace for the oidc provider info

Create a secret for the json provider config from the previous step
```
apiVersion: v1
kind: Secret
metadata:
    name: oidc-provider
    namespace: gitlab
data:
    gitlab-oidc.json:  <enter your encoded json config here>
```
Before you commit this secret you can encrypt the base64 encoded data with sops. Only encrypt the data section. Flux needs to be able to read the other fields.

### Gitlab omniauth global configuration

Override the helm chart values.yaml for your environment to include the oidc-provider secret in gitlab ```global.appConfig.omniauth``` definition. The following example is the minimum config that you need.  Refer to Gitlab documentation for more settings. 

```
global:
  ...
  appConfig:
  ...  
    omniauth:
      enabled: true
      # autoSignInWithProvider:
      # syncProfileFromProvider: []
      syncProfileAttributes: ['email']
      allowSingleSignOn: ['openid_connect']
      blockAutoCreatedUsers: false
      # autoLinkLdapUser: false
      # autoLinkSamlUser: false
      # externalProviders: []
      # allowBypassTwoFactor: []
      providers:
        - secret: oidc-provider
          key: gitlab-oidc.json
```
#### Network Policy egress-sso configurable port
- Default egressPort = 443
- Scenerio: If omniauth is "enabled" and you are configuring the controlPlaneCidr to a specific controlplane ip block you will need to update the "Values.networkPolicies.egressPort" to 8443. This port needs to be open for oidc authentication to the keycloak client in the baby-yoda realm.

Example egress-sso Network Policy override:
```yaml
gitlab:
    enabled: true
    git:
      tag: null
      branch: "main" # or your branch you are working.
    sso:
      enabled: true
      label: "Platform One SSO"
      # client_id takien from baby-yoda dev realm: https://repo1.dso.mil/big-bang/product/packages/keycloak/-/blob/main/chart/resources/dev/baby-yoda.json?ref_type=heads#L830
      client_id: dev_00eb8904-5b88-4c68-ad67-cec0d2e07aa6_gitlab
      client_secret: ""
    values:
      gitlab:
      networkPolicies:
        enabled: true
        ingress:
          enabled: true
        controlPlaneCidr: 172.x.x.x/x
        egressPort: 8443 # egressPort defaults to 443 if no value
      global:
        appConfig:
          object_store:
            enabled: true
          defaultCanCreateGroup: true
          omniauth:
            enabled: true  
sso: # derived from https://repo1.dso.mil/big-bang/product/packages/gitlab/-/blob/main/docs/keycloak-dev.md?ref_type=heads
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
- Link to [keycloak-dev.md](https://repo1.dso.mil/big-bang/product/packages/gitlab/-/blob/main/docs/keycloak-dev.md?ref_type=heads) document for complete SSO configuration.

If all your configuration is correct you will be able to deploy and use SSO auth for Gitlab!
