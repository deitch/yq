FROM alpine:3.4
MAINTAINER Avi Deitcher <https://github.com/deitch>

COPY dist/yq-linux-amd64 /usr/local/bin/yq

ENTRYPOINT ["/usr/local/bin/yq"]
