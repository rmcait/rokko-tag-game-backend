# cSpell:words nvmrc
# ============================================================
# Cloud Functions local development helper Makefile (Cross-Platform)
# ============================================================

FUNCTIONS_DIR := functions
NVMRC_FILE := .nvmrc
NODE_REQUIRED := 22
FIREBASE_EMULATOR_ARGS := --only functions
NPM := npm --prefix $(FUNCTIONS_DIR)
PS := powershell -NoLogo -NoProfile -Command

# Detect OS (Linux/macOS → use bash, Windows → use PowerShell)
OSFLAG := $(shell uname 2>/dev/null || echo Windows_NT)

.PHONY: init ensure-node install build lint clean emulators

init: ensure-node install build emulators

# ============================================================
# macOS / Linux (bash構文)
# ============================================================
ifeq ($(OSFLAG),Linux)
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
	cd $(FUNCTIONS_DIR) && npx firebase emulators:start $(FIREBASE_EMULATOR_ARGS)

# ============================================================
# Windows PowerShell (非WSL)
# ============================================================
else
ensure-node:
	@$(PS) "if (!(Get-Command node -ErrorAction SilentlyContinue)) { \
		Write-Host '[error] Node.js is not installed. Please install version $(NODE_REQUIRED).x'; exit 1 }"
	@$(PS) "if (!(Test-Path '$(NVMRC_FILE)')) { \
		Write-Host '[warn] $(NVMRC_FILE) not found. Using fallback $(NODE_REQUIRED).x requirement.' }"
	@$(PS) "$$current = (node -v).Trim('v').Split('.')[0]; \
	if ($$current -ne '$(NODE_REQUIRED)') { \
		Write-Host ('[error] Detected Node.js version ' + $$current + '.x, but $(NODE_REQUIRED).x is required.'); \
		exit 1 }"

install:
	@$(PS) "cd '$(FUNCTIONS_DIR)'; npm ci"

build:
	@$(PS) "cd '$(FUNCTIONS_DIR)'; npm run build"

lint:
	@$(PS) "cd '$(FUNCTIONS_DIR)'; npm run lint"

clean:
	@$(PS) "if (Test-Path '$(FUNCTIONS_DIR)/node_modules') { Remove-Item -Recurse -Force '$(FUNCTIONS_DIR)/node_modules' }"
	@$(PS) "if (Test-Path '$(FUNCTIONS_DIR)/lib') { Remove-Item -Recurse -Force '$(FUNCTIONS_DIR)/lib' }"

emulators:
	@$(PS) "cd '$(FUNCTIONS_DIR)'; npx firebase emulators:start $(FIREBASE_EMULATOR_ARGS)"
endif
