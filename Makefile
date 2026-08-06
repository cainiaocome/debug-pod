IMAGE ?= ghcr.io/cainiaocome/debug-pod
TAG ?= main
LOCAL_IMAGE ?= debug-pod:local
PREFIX ?= $(HOME)/.local
TOOL_REFRESH ?= $(shell date -u +%s)

.DEFAULT_GOAL := help

.PHONY: help pull build shell install

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*## "; print "Usage: make <target> [TAG=tag]"} /^[a-zA-Z_-]+:.*## / {printf "  %-10s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

pull: ## Pull the published image (defaults to the main branch tag)
	docker pull $(IMAGE):$(TAG)

build: ## Build a local image, always refreshing base images and packages
	docker build --pull --build-arg TOOL_REFRESH=$(TOOL_REFRESH) --tag $(LOCAL_IMAGE) .

shell: ## Open this directory using the published image
	DEBUG_HERE_IMAGE=$(IMAGE):$(TAG) ./debug-here

install: ## Install debug-here under PREFIX/bin
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 0755 debug-here $(DESTDIR)$(PREFIX)/bin/debug-here
