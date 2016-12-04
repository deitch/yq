export DOCKER_REG_USERNAME ?=
export DOCKER_REG_PASSWORD ?=


export GIT_SHA = $(shell git rev-parse --short HEAD)
export BUILD_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)
export APP_VERSION ?=  $(shell git describe --abbrev=0 --tags 2>/dev/null || echo '.unknown')


DEPLOY_IMAGE_NAME ?= deitch/yq
BUILD_IMAGE_NAME ?= yq_build

.PHONY: build push

build:
	docker build -t $(BUILD_IMAGE_NAME) -f Dockerfile.build .
	docker run -v $(PWD)/dist:/vol $(BUILD_IMAGE_NAME) cp yq /vol
	docker build -t $(DEPLOY_IMAGE_NAME) .

push:
	# build the minimal image we need and extract it
	docker push $(DEPLOY_IMAGE_NAME)

tests:
	IMAGE=$(DEPLOY_IMAGE_NAME) ./test.sh
