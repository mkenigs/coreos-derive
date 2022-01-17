export GO111MODULE=on

# Canonical version of this in https://github.com/coreos/coreos-assembler/blob/6eb97016f4dab7d13aa00ae10846f26c1cd1cb02/Makefile#L19
GOARCH:=$(shell uname -m)
ifeq ($(GOARCH),x86_64)
        GOARCH=amd64
else ifeq ($(GOARCH),aarch64)
        GOARCH=arm64
else ifeq ($(patsubst armv%,arm,$(GOARCH)),arm)
        GOARCH=arm
else ifeq ($(patsubst i%86,386,$(GOARCH)),386)
        GOARCH=386
endif
GOFLAGS:=-mod=vendor
VERSION:=$(shell git describe --dirty --always)


ignition2rpm: 
	go build -ldflags "-X main.Version=$(VERSION)" -o bin/merge-ignition cmd/merge-ignition/main.go	
.PHONY: merge-ignition

vendor: 
	@go mod vendor
	@go mod tidy
.PHONY: vendor 

test:
	for x in *.sh; do bash -n $$x; done
.PHONY: test
