export DOCKER_REG_USERNAME ?=
export DOCKER_REG_PASSWORD ?=


export GIT_SHA = $(shell git rev-parse --short HEAD)
export BUILD_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)
export APP_VERSION ?=  $(shell git describe --exact-match 2>/dev/null)


BASE_DEPLOY_IMAGE_NAME ?= deitch/yq
BUILD_IMAGE_NAME ?= yq_build

ifneq ($(strip $(APP_VERSION)),)
DEPLOY_IMAGE_NAME ?= $(BASE_DEPLOY_IMAGE_NAME):$(APP_VERSION)
else
DEPLOY_IMAGE_NAME ?= $(BASE_DEPLOY_IMAGE_NAME)
endif

.PHONY: build push

build:
	docker build -t $(BUILD_IMAGE_NAME) -f Dockerfile.build .
	# build the minimal image we need and extract it
	docker run -v $(PWD)/dist:/vol $(BUILD_IMAGE_NAME) sh -c 'cp yq* /vol'
	docker build -t $(DEPLOY_IMAGE_NAME) .

push:
# push to docker registry and push the binary itself to github - but only if this last commit was tagged
ifneq ($(strip $(APP_VERSION)),)
	github-release release -u deitch -r yq --tag $(APP_VERSION)
	github-release upload -u deitch -r yq --tag $(APP_VERSION) --name yq-darwin-amd64 --file dist/yq-darwin-amd64
	github-release upload -u deitch -r yq --tag $(APP_VERSION) --name yq-linux-amd64 --file dist/yq-linux-amd64
	github-release upload -u deitch -r yq --tag $(APP_VERSION) --name yq-windows-amd64 --file dist/yq-windows-amd64.exe
	docker push $(DEPLOY_IMAGE_NAME)
endif

tests:
	IMAGE=$(DEPLOY_IMAGE_NAME) ./test.sh
