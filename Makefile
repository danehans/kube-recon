all: generate build

PACKAGE=github.com/openshift/cluster-ingress-operator
MAIN_PACKAGE=$(PACKAGE)/cmd/ingress-operator

BIN=$(lastword $(subst /, ,$(MAIN_PACKAGE)))

ifneq ($(DELVE),)
GO_GCFLAGS ?= -gcflags=all="-N -l"
endif

GO=GO111MODULE=on GOFLAGS=-mod=vendor go
GO_BUILD_RECIPE=CGO_ENABLED=0 $(GO) build -o $(BIN) $(GO_GCFLAGS) $(MAIN_PACKAGE)

TEST ?= .*

.PHONY: build
build:
	$(GO_BUILD_RECIPE)

.PHONY: test
test:
	$(GO) test ./...

.PHONY: release-local
release-local:
	hack/release-local.sh
