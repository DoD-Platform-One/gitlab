# Modifications made to upstream chart

##  chart/charts/*.tgz
- run ```helm dependency update``` and commit the downloaded archives
- comment the *.tgz from the .gitignore file
- commit the tar archives that were downloaded from the helm dependency update command

## chart/values.yaml
- disable all internal services other than postgres, minio, and redis
- add BigBang additional values at bottom of values.yaml
- add prometheus exporter:  gitlab.gitlab-exporter
- add default bigbang.dev hostnames for global.hosts
- add IronBank hardened images
- add pullSecrets for each IronBank image
- add default bigbag.dev hostnames at global.hosts
- add customCAs (the cert files and secrets need to be added in the next 2 steps for this to work)

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

# chart/templates/upgrade_check_hook.yaml
- add annotation to to conditionally disable istio injection
    lines 38-41
    ```
    {{- if .Values.global.istio.enabled }}  
      annotations:
        sidecar.istio.io/inject: "false"
    {{- end }}
    ```

## chart/charts/gitlab/charts/gitlab-exporter/templates/bigbang/service-monitor.yaml
- add ServiceMonitor to Gitlab sub-chart ```gitlab-exporterr``` to enable prometheus monitoring
  
## chart/tests/*
- add helm test scripts

## chart/templates/tests/*
- add templates for helm tests

## chart/.helmignore
- change `scripts/` to `/scripts/` so that the helm test scripts are not ignored

# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [5.3.1-bb.4] - 2021-10-29
- Add check for AWS IAM profile to update the egress-kube-api network policy to allow access to AWS metadata endpoint
- Add specific NetworkPolicy templates for 4 pods to hit AWS metadata endpoint to use IAM Role

## [5.3.1-bb.3] - 2021-10-29
- increase resoures for gitaly
- conditionally disable istio injection for the upgrade-check job
- modify minio sub-chart to conditionally disable istio injection for the create-buckets job

## [5.3.1-bb.2] - 2021-10-17
- Update rolling upgrade job with variable for release tag

## [5.3.1-bb.1] - 2021-10-15
- Updated README.md
- Renamed docs/README.md to docs/overview.md

## [5.3.1-bb.0] - 2021-10-08
- upgrade Gitlab to application version 14.3.1 helm chart version v5.3.1
- If upgrading from 13.12.9 to 14.3.1 must first upgrade to 14.0.5 see Gitlab documentation
   https://docs.gitlab.com/ee/update/#upgrade-paths

## [5.0.5-bb.0] - 2021-10-01
- upgrade Gitlab to application version 14.0.5 helm chart version v5.0.5
- notice: this upgrade requires postgresql 12 or higher

## [4.12.9-bb.6] - 2021-09-16
- Updated test.sh with ENV variables from test-values
- Updated Cypress tests with ENV variables from test-values
- Added bbtest conditional for test-services

## [4.12.9-bb.5] - 2021-09-09
- Updated tests to add labels for `app: gitlab`, workaround for a bug (likely) in gluon
- Updated to latest gluon

## [4.12.9-bb.4] - 2021-09-08
- Fix helmignore issue with scripts/ folder

## [4.12.9-bb.3] - 2021-08-31
- VirtualService modifications to optionally allow use of multiple hosts

## [4.12.9-bb.2] - 2021-08-30
- Set resource limits and make requests and limis equal to achive quality of service

## [4.12.9-bb.1] - 2021-08-12
- update change log.

## [4.12.9-bb.0] - 2021-08-12
- upgrade Gitlab to application version 13.12.9 helm chart version 4.12.9

## [4.10.3-bb.14] - 2021-07-15
- add openshift toggle. conditionally modify networkpolicy for dns

## [4.10.3-bb.13] - 2021-07-15
- fix networkPolicies to allow egress to kube api server

## [4.10.3-bb.12] - 2021-07-01
- fix networkPolicies to allow monitoring for gitlab-runner

## [4.10.3-bb.11] - 2021-07-01
- fix flux helmrelease errors because gitlab chart duplicates lables

## [4.10.3-bb.10] - 2021-06-18
- more restrictive network policies to limit by podSelector

## [4.10.3-bb.9] - 2021-06-16
- updated Iron Bank UBI from 8.3 to 8.4

## [4.10.3-bb.8] - 2021-06-04
- network policy to allow sso egress
- turn off ingress in subcharts by default

## [4.10.3-bb.7] - 2021-06-01
- more network policy updates
- upgrade test library

## [4.10.3-bb.6] - 2021-05-27
- more network policy updates

## [4.10.3-bb.5] - 2021-05-26
- add optional network policies

## [4.10.3-bb.4] - 2021-05-26
- limit default user permissions

## [4.10.3-bb.3] - 2021-05-25
- no code changes
## [4.10.3-bb.2] - 2021-05-10
- add helm tests for CI pipelines
- remove unneeded registry.host key in values.yaml
- documentation about backing up the gitlab-rails secret
- ironbank image for praefect (praefect is disabled by default)
## [4.10.3-bb.1] - 2021-05-03
- add ServiceMonitor to fix prometheus monitoring

## [4.10.3-bb.0] - 2021-04-21
- upgrade Gitlab to application version 13.10.3 chart version 4.10.3

## [4.8.0-bb.3] - 2021-03-09
- add support for CAC signed commits with DoD certificate authorities
- update changelog

## [4.8.0-bb.2] - 2021-03-04
- increment chart version in Chart.yaml

## [4.8.0-bb.1] - 2021-03-04
- use correct IronBank image for certificates

## [4.8.0-bb.0] - 2021-02-12
- upgrade Gitlab to application version 13.8.0 chart version 4.8.0 

## [4.7.2-bb.0] - 2021-01-20
- upgrade Gitlab to application version 13.7.2 chart version 4.7.2

## [4.2.0-bb.0] - 2021-01-16
- initial release with support for BigBang

## [0.0.0-bb.0] - 2020-12-22
- pre-bigbang
- Upstream gitlab version - v4.2.0

