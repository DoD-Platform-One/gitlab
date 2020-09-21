### Prerequisites

The integration assumes that keycloak is deployed with master realm and a client named gitlab exist. The secret is used in the gitlab keycloak configuration.

If the client gitlab doesn't exist in keycloak, please create the client gitlab 

Get the bearer token for keycloak - the username and password is the credentials for keycloak

export ACCESS_TOKEN=$(curl \
-d "client_id=admin-cli" \
-d "username=$username" \
-d "password=$password" \
-d "grant_type=password" \
"https://keycloak.fences.dsop.io/auth/realms/master/protocol/openid-connect/token" | jq -r '.access_token')

curl -v -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
 -d '{ "clientId": "gitlab" ,   "redirectUris":  ["https://code.fences.dsop.io/users/auth/openid_connect/callback" ]}' \
  $APP_URL/auth/admin/realms/$realmname/clients
  

### GitLab configuration for keycloak


The configuration used for keycloak 
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
                "issuer": "https://keycloak.fences.dsop.io/auth/realms/master",
                "client_auth_method": "query",
                "discovery": true,
                "uid_field": "preferred_username",
                "client_options": {
                        "identifier": "gitlab",
                        "secret": "<get the secret id>",
                        "redirect_uri": "https://code.fences.dsop.io/users/auth/openid_connect/callback",
                        "end_session_endpoint": "https://keycloak.fences.dsop.io/auth/realms/master/protocol/openid-connect/logout"
                }
        }
}

```
Create sops ecrypted file for the above configuration using command

sops  filename 

For the demonstration, the file name used is oidc_provider.enc.json

sops oidc_provider.enc.json

Include the encrypted filename in generator.yaml.

```
apiVersion: goabout.com/v1beta1
kind: SopsSecretGenerator
metadata:
  name: s3-creds
  namespace: gitlab
disableNameSuffixHash: true
files:
  - provider=oidc_provider.enc.json
```

Include the secret in generator

```
  generators:
  - s3-creds-generator.yaml
```

Modify your helm chart values.yaml to include the credentials in gitlab configuration

```
appConfig:
    
    omniauth:
      enabled: true
      autoSignInWithProvider: openid_connect
      allowSingleSignOn: ['openid_connect']
      blockAutoCreatedUsers: false
      providers:
        - secret: s3-creds
          key: provider
```

