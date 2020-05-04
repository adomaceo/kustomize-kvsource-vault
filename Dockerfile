FROM golang:alpine

WORKDIR /code

RUN apk --no-cache add curl bash gettext g++ git

RUN GO111MODULE=on go get sigs.k8s.io/kustomize/kustomize/v3@v3.2.1

COPY * ./

RUN go build -buildmode plugin -o /opt/kustomize/plugin/kvSources/SecretsFromVault.so ./SecretsFromVault.go 

FROM alpine

COPY --from=0 /opt/kustomize/plugin/kvSources/SecretsFromVault.so /opt/kustomize/plugin/kustomize.config.realgeeks.com/v1beta1/secretsfromvault/SecretsFromVault.so
COPY --from=0 /go/bin/kustomize /usr/bin/kustomize

WORKDIR /working 

ENV XDG_CONFIG_HOME=/opt

ENTRYPOINT ["/usr/bin/kustomize", "build", "--enable_alpha_plugins"]
