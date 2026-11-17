# Common development commands. Run `make help` for an overview.
COMPOSE := docker compose -f deploy/dev/compose.yaml --project-directory deploy/dev

.DEFAULT_GOAL := help
.PHONY: help dev dev-down dev-reset dev-check lint test build fmt helm-lint check

help: ## Show this help
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-12s %s\n", $$1, $$2}'

dev: ## Start the dev stack (Postgres, Keycloak, S3, Valkey, PDFCraft) and create the PDFCraft token
	$(COMPOSE) up -d --wait
	cd deploy/dev && ./init-pdfcraft-token.sh

dev-down: ## Stop the dev stack (data is kept)
	$(COMPOSE) down

dev-reset: ## Stop the dev stack and delete all its data and the PDFCraft token
	$(COMPOSE) down -v
	rm -rf deploy/dev/.secrets

dev-check: ## Smoke test: PDFCraft /health and POST /v1/invoices
	cd deploy/dev && ./check-pdfcraft.sh

fmt: ## Format Rust and TypeScript code
	cd backend && cargo fmt
	cd frontend && npm run format

lint: ## Lint Rust, TypeScript and the Helm chart
	cd backend && cargo fmt --check && cargo clippy --locked --workspace --all-targets -- -D warnings
	cd frontend && npm run lint
	$(MAKE) helm-lint

test: ## Run all tests
	cd backend && cargo test --locked --workspace
	cd frontend && npm test

build: ## Build backend and frontend
	cd backend && cargo build --locked --workspace
	cd frontend && npm run build

helm-lint: ## Lint the Helm charts
	helm lint deploy/helm/fedifinance

check: lint test build ## Lint, test and build everything (as in CI)
