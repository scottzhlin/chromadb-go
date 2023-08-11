
IMPI=impi
REPO=github.com/scottzhlin/chromadb/

ALL_GO_MOD_DIRS := $(shell find . -type f -name 'go.mod' -exec dirname {} \; | sort)

.PHONY: all

all: fmt build test impi lint

.PHONY: precommit
precommit: build lint impi fmt test

.PHONY: fmt
fmt:

.PHONY: impi
impi: install-tools
	@$(IMPI) --local $(REPO) --scheme stdThirdPartyLocal ./...

.PHONY: lint
lint: install-tools
	set -e; for dir in $(ALL_GO_MOD_DIRS); do \
	  echo "golangci-lint in $${dir}"; \
	  (cd "$${dir}" && \
	    golangci-lint run --fix && \
	    golangci-lint run); \
	done
	set -e; for dir in $(ALL_GO_MOD_DIRS); do \
	  echo "go mod tidy in $${dir}"; \
	  (cd "$${dir}" && \
	    go mod tidy); \
	done

.PHONY: build
build:
	@go build -v ./...
	@echo "build chromadb-go success!"

.PHONY: fmt
fmt: install-tools
	gofmt -w -s .
	goimports -w -local $(REPO) ./

.PHONY: test
test: unit-test

.PHONY: unit-test
unit-test:
	go test -v ./...

.PHONY: install-tools
install-tools:
	@which golangci-lint > /dev/null || (echo 'install golangci-lint' && go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.53.3)
	@which misspell > /dev/null || (echo 'install misspell' && go install github.com/client9/misspell/cmd/misspell@latest)
	@which impi > /dev/null || (echo 'install impi' && go install github.com/pavius/impi/cmd/impi@latest)
	@which goimports > /dev/null || (echo 'install goimports' && go install golang.org/x/tools/cmd/goimports@latest)