# Modifications made to upstream chart

##  chart/charts/*.tgz
- run ```helm dependency update``` and commit the downloaded archives
- comment the *.tgz from the .gitignore file
- commit the tar archives that were downloaded from the helm dependency update command

## chart/requirements.yaml
- change all external dependency links to point to the local file system

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
## chart/charts/gitlab/charts/gitlab-exporter/templates/bigbang/service-monitor.yaml
- add ServiceMonitor to Gitlab sub-chart ```gitlab-exporterr``` to enable prometheus monitoring
  
## chart/tests/*
- add helm test scripts

## chart/templates/tests/*
- add templates for helm tests
# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

