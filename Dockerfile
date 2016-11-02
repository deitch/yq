FROM alpine:3.4
MAINTAINER Avi Deitcher <https://github.com/deitch>

COPY yq /usr/local/bin/yq

ENTRYPOINT ["/usr/local/bin/yq"]
