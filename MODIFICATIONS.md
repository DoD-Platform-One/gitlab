# Modifications made to upstream chart

##  chart/charts/*.tgz
- run ```helm dependency update ./chart``` and commit the downloaded archives
- comment the ```charts/*.tgz``` from the .gitignore file
- comment the ```requirements.lock``` in the .gitignore file.
- commit the tar archives that were downloaded from the helm dependency update command. And also commit the requirements.lock that was generated.

## chart/values.yaml
- disable all internal services other than postgres, minio, and redis
- add BigBang additional values at bottom of values.yaml
- add prometheus exporter:  gitlab.gitlab-exporter
- add default bigbang.dev hostnames for global.hosts
- add IronBank hardened images
- add pullSecrets for each IronBank image
- add default bigbag.dev hostnames at global.hosts
- add customCAs (the cert files and secrets need to be added in the next 2 steps for this to work)
- add `postgresqlConfiguration`, `pgHbaConfiguration`, `securityContext`, `postgresqlDataDir` and `persistence` to get IB image working with postgres subchart

## chart/bigbang/*
- add DoD approved CA certificates (recursive copy directory from previous release)

## chart/templates/bigbang/*
- add istio virtual service  (temporarily disable istio in values.yaml to test)
- add Secrets for DoD certificate authorities

## chart/templates/_certificates.tpl
- hack to support pki certificate location within the RedHat UBI image. Is different than Debian based images. Add to definition of ```gitlab.certificates.volumeMount```  
    the volumeMount definition is at the end of the file
    ```
    - name: etc-ssl-certs
      mountPath: /etc/pki/tls/certs/
      readOnly: true
    - name: etc-ssl-certs
      mountPath: /etc/pki/tls/cert.pem
      subPath: ca-bundle.crt
      readOnly: true
    ```

## chart/charts/minio/templates/_helper_create_buckets.sh
- hack the MinIO sub-chart to work with newer mc version in IronBank image   
    line 65  
    ```
    /usr/bin/mc policy set $POLICY myminio/$BUCKET
    ```
    
## chart/charts/minio/templates/create-buckets-job.yaml    
- hack the MinIO sub-chart to add annotation to to conditionally disable istio injection   
    lines 22-25
    ```
    {{- if .Values.global.istio.enabled }}  
    annotations:
      sidecar.istio.io/inject: "false"
    {{- end }}
    ```
## gitlab/chart/templates/shared-secrets/self-signed-cert-job.yml
- add curl to quit isto proxy
  lines 107-113
  ```
  {{- if and .Values.global.istio.enabled (eq .Values.global.istio.injection "enabled") }}
  # Stop istio sidecar container so gitlab can continue installing
  until curl -fsI http://localhost:15021/healthz/ready; do echo "Waiting for Istio sidecar proxy..."; sleep 3; done;
  sleep 5
  echo "Istio proxy container is ready. Now stop the istio proxy..."
  curl -X POST http://localhost:15020/quitquitquit
  {{- end }}
  ```

## gitlab/chart/templates/shared-secrets/_generate_secrets.sh.tpl
- add curl to quit isto proxy
  lines 198-205
  ```
  {{ if and .Values.global.istio.enabled (eq .Values.global.istio.injection "enabled") }}
  # Stop istio sidecar container so gitlab can continue installing
  until curl -fsI http://localhost:15021/healthz/ready; do echo "Waiting for Istio sidecar proxy..."; sleep 3; done;
  sleep 5
  echo "Istio proxy container is ready. Now stop the istio proxy..."
  echo "curl -X POST http://localhost:15020/quitquitquit"
  curl -X POST http://localhost:15020/quitquitquit
  {{ end }}
  ```

## chart/templates/_runcheck.tpl
- add curl to quit isto proxy
  lines 78-84
  ```
  {{- if and .Values.global.istio.enabled (eq .Values.global.istio.injection "enabled") }}
  # Stop istio sidecar container so gitlab can continue installing
  until curl -fsI http://localhost:15021/healthz/ready; do echo "Waiting for Istio sidecar proxy..."; sleep 3; done;
    sleep 5
    echo "Istio proxy container is ready. Now stop the istio proxy..."
  curl -X POST http://localhost:15020/quitquitquit
  {{- end }}
  ```

## chart/charts/gitlab/charts/gitlab-exporter/templates/bigbang/service-monitor.yaml
- add ServiceMonitor to Gitlab sub-chart ```gitlab-exporter``` to enable prometheus monitoring
  
## chart/tests/*
- add helm test scripts

## chart/templates/tests/*
- add templates for helm tests

## chart/.helmignore
- change `scripts/` to `/scripts/` so that the helm test scripts are not ignored

## chart/charts/gitlab/charts/toolbox/templates/backup-job.yaml
- lines 31-33
  ```
    {{- if .Values.global.istio.enabled }}  
      sidecar.istio.io/inject: "false"
    {{- end }}
  ```
