.PHONY: all build clean test

CLANG ?= clang
LLC ?= llc
GO ?= go
BPF_SRC = bpf/podtrace.bpf.c
BPF_OBJ = bpf/podtrace.bpf.o
BINARY = bin/podtrace

BPF_CFLAGS = -O2 -g -target bpf -D__TARGET_ARCH_x86 -mcpu=v3

all: build

$(BPF_OBJ): $(BPF_SRC)
	@mkdir -p $(dir $(BPF_OBJ))
	$(CLANG) $(BPF_CFLAGS) -Ibpf -I. -c $(BPF_SRC) -o $(BPF_OBJ)

build: $(BPF_OBJ)
	@mkdir -p bin
	$(GO) build -o $(BINARY) ./cmd/podtrace

clean:
	rm -f $(BPF_OBJ)
	rm -f $(BINARY)
	rm -rf bin

deps:
	$(GO) mod download
	$(GO) mod tidy

test:
	@echo "Tests not yet implemented"

build-setup: build
	@echo "Setting capabilities..."
	@sudo ./scripts/setup-capabilities.sh || (echo "Warning: Failed to set capabilities. Run manually: sudo ./scripts/setup-capabilities.sh" && exit 1)

help:
	@echo "Available targets:"
	@echo "  all         - Build everything (default)"
	@echo "  build       - Build the Go binary"
	@echo "  build-setup - Build and set capabilities (requires sudo)"
	@echo "  clean       - Remove build artifacts"
	@echo "  deps        - Download and tidy Go dependencies"
	@echo "  test        - Run tests"
