# cSpell:words nvmrc
# ============================================================
# Cloud Functions local development helper Makefile
# ============================================================

FUNCTIONS_DIR := functions
NVMRC_FILE ?= ./.nvmrc
NODE_REQUIRED := $(shell if [ -f $(NVMRC_FILE) ]; then head -n 1 $(NVMRC_FILE); fi)
NODE_REQUIRED ?= 22
FIREBASE_EMULATOR_ARGS ?= --only functions
NPM := npm --prefix $(FUNCTIONS_DIR)

.PHONY: init ensure-node install build lint clean emulators

init: ensure-node install build emulators

ensure-node:
	@if ! command -v node >/dev/null 2>&1; then \
		echo "[error] Node.js is not installed. Please install version $(NODE_REQUIRED).x"; \
		exit 1; \
	fi
	@if [ ! -f "$(NVMRC_FILE)" ]; then \
		echo "[warn] $(NVMRC_FILE) not found. Using fallback $(NODE_REQUIRED).x requirement."; \
	fi
	@NODE_CURRENT=$$(node -v | sed -E 's/v([0-9]+).*/\1/'); \
	if [ "$$NODE_CURRENT" != "$(NODE_REQUIRED)" ]; then \
		echo "[error] Detected Node.js $$NODE_CURRENT.x, but $(NODE_REQUIRED).x is required (per $(NVMRC_FILE))."; \
		echo "        Run 'nvm use $(NODE_REQUIRED)' (or similar) before using these targets."; \
		exit 1; \
	fi

install:
	$(NPM) ci

build:
	$(NPM) run build

lint:
	$(NPM) run lint

clean:
	rm -rf $(FUNCTIONS_DIR)/node_modules $(FUNCTIONS_DIR)/lib

emulators:
	cd $(FUNCTIONS_DIR) && firebase emulators:start $(FIREBASE_EMULATOR_ARGS)
