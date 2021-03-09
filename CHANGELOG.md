# Modifications made to upstream chart
## chart/values.yaml
- disable all internal services other than postgres, minio, and redis
- add BigBang additional values at bottom of values.yaml
- add IronBank hardened images
- add pullSecrets for each IronBank image
- add customCAs

##  chart/charts/*.tgz
- run ```helm dependency update``` and commit the downloaded archives
## chart/requirements.yaml
- change all external dependency links to point to the local file system

## chart/templates/bigbang/*
- add istio virtual service
- add Secrets for DoD certificate authorities

## chart/bigbang/*
- add DoD approved CA certificates

## chart/templates/_certificates.tpl
- hack to support pki certificate location within the RedHat UBI image. Is different than Debian based images. Add to definition of ```gitlab.certificates.volumeMount```  
    lines 81-87
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


# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

