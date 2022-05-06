# Dockerfile for registry.dso.mil/platform-one/big-bang/apps/developer-tools/gitlab/bbtests:0.0.4

FROM registry1.dso.mil/ironbank/google/golang/golang-1.16:1.16

# install crane
RUN go install github.com/google/go-containerregistry/cmd/crane@v0.8.0

# make crane command world executable
RUN chmod -R +x /go

CMD ["/bin/bash"]