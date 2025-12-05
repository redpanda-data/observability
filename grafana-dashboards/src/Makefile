.PHONY: all install clean build

JSONNET_BIN := jsonnet
JB_BIN := jb
OUTPUT_DIR := ..
VENDOR_DIR := vendor

all: install build

install:
	@echo "Installing grafonnet dependencies..."
	@$(JB_BIN) install

build:
	@echo "Building dashboards..."
	@$(JSONNET_BIN) -J $(VENDOR_DIR) -o $(OUTPUT_DIR)/Redpanda-Serverless-Dashboard.json dashboards/serverless.jsonnet
	@echo "Dashboard generated successfully!"
