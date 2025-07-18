# CircleLayer Token Makefile

-include .env

FORGE := ~/.foundry/bin/forge
CAST := ~/.foundry/bin/cast

.PHONY: help setup build test coverage gas-report deploy clean

help:
	@echo "Commands: setup install build test coverage gas-report deploy-mainnet clean"

setup:
	@mkdir -p reports coverage-reports

install:
	$(FORGE) install

build:
	$(FORGE) build --evm-version paris

test:
	$(FORGE) test --evm-version paris --fork-url $(MAINNET_RPC_URL) --fuzz-runs 3000

test-verbose:
	$(FORGE) test -vvv --evm-version paris --fork-url $(MAINNET_RPC_URL) --fuzz-runs 3000

coverage:
	$(FORGE) coverage --evm-version paris --fork-url $(MAINNET_RPC_URL) --fuzz-runs 3000

coverage-html:
	$(FORGE) coverage --evm-version paris --fork-url $(MAINNET_RPC_URL) --report lcov --fuzz-runs 3000
	@if command -v genhtml >/dev/null 2>&1; then \
		genhtml lcov.info --output-directory coverage-reports/html; \
	else \
		echo "Install lcov: sudo apt-get install lcov"; \
	fi

gas-report:
	$(FORGE) test --gas-report --evm-version paris --fork-url $(MAINNET_RPC_URL)

deploy-mainnet:
	@read -p "Deploy to mainnet? (y/N): " confirm && [ "$$confirm" = "y" ]
	$(FORGE) script script/DeployCircleLayerToken.s.sol --rpc-url $(MAINNET_RPC_URL) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY)

clean:
	$(FORGE) clean
	rm -rf coverage-reports reports lcov.info 