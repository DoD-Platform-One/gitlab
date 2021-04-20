### Prerequisites

The integration assumes that keycloak is deployed with a realm other than master (eg: baby-yoda) and a client within named gitlab. The secret is used in the gitlab keycloak configuration.

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
      "redirect_uri": "https://code.bigbang.dev/users/auth/openid_connect/callback",
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

If all your configuration is correct you will be able to deploy and use SSO auth for Gitlab!
