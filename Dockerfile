FROM alpine:3.4
MAINTAINER Avi Deitcher <https://github.com/deitch>

COPY . /usr/src/install

ENTRYPOINT ["/usr/src/install/yq"]
