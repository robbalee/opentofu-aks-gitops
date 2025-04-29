# Makefile for OpenTofu AKS GitOps Management

.PHONY: init-dev init-staging init-prod plan-dev plan-staging plan-prod apply-dev apply-staging apply-prod destroy-dev destroy-staging destroy-prod bootstrap-dev bootstrap-staging bootstrap-prod clean fmt validate test test-infra test-k8s test-gitops test-scripts test-env-diffs fmt-check validate-dev validate-staging validate-prod

# Variables
ENVIRONMENT ?= dev
PROJECT_NAME ?= aksflux
LOCATION ?= eastus
GITHUB_USER ?= your-github-username
GITHUB_REPO ?= opentofu-aks-gitops

# OpenTofu initialization
init-dev:
	@echo "Initializing OpenTofu for development environment"
	./scripts/init-opentofu.sh dev $(PROJECT_NAME) $(LOCATION)

init-staging:
	@echo "Initializing OpenTofu for staging environment"
	./scripts/init-opentofu.sh staging $(PROJECT_NAME) $(LOCATION)

init-prod:
	@echo "Initializing OpenTofu for production environment"
	./scripts/init-opentofu.sh prod $(PROJECT_NAME) $(LOCATION)

# OpenTofu planning
plan-dev:
	@echo "Planning OpenTofu for development environment"
	cd infrastructure/environments/dev && tofu plan -out=tfplan

plan-staging:
	@echo "Planning OpenTofu for staging environment"
	cd infrastructure/environments/staging && tofu plan -out=tfplan

plan-prod:
	@echo "Planning OpenTofu for production environment"
	cd infrastructure/environments/prod && tofu plan -out=tfplan

# OpenTofu apply
apply-dev:
	@echo "Applying OpenTofu for development environment"
	cd infrastructure/environments/dev && tofu apply tfplan

apply-staging:
	@echo "Applying OpenTofu for staging environment"
	cd infrastructure/environments/staging && tofu apply tfplan

apply-prod:
	@echo "Applying OpenTofu for production environment"
	cd infrastructure/environments/prod && tofu apply tfplan

# OpenTofu destroy
destroy-dev:
	@echo "Destroying development environment"
	cd infrastructure/environments/dev && tofu destroy -auto-approve

destroy-staging:
	@echo "Destroying staging environment"
	cd infrastructure/environments/staging && tofu destroy -auto-approve

destroy-prod:
	@echo "Destroying production environment"
	cd infrastructure/environments/prod && tofu destroy -auto-approve

# Flux bootstrap
bootstrap-dev:
	@echo "Bootstrapping Flux for development environment"
	./scripts/bootstrap-flux.sh dev $(GITHUB_USER) $(GITHUB_REPO)

bootstrap-staging:
	@echo "Bootstrapping Flux for staging environment"
	./scripts/bootstrap-flux.sh staging $(GITHUB_USER) $(GITHUB_REPO)

bootstrap-prod:
	@echo "Bootstrapping Flux for production environment"
	./scripts/bootstrap-flux.sh prod $(GITHUB_USER) $(GITHUB_REPO)

# Clean up
clean:
	@echo "Cleaning up local OpenTofu files"
	find . -name ".terraform" -type d -exec rm -rf {} +
	find . -name "*.tfstate" -type f -delete
	find . -name "*.tfstate.backup" -type f -delete
	find . -name ".terraform.lock.hcl" -type f -delete
	find . -name "tfplan" -type f -delete

# Format OpenTofu files
fmt:
	@echo "Formatting OpenTofu files"
	cd infrastructure && tofu fmt -recursive

# Validate OpenTofu files
validate:
	@echo "Validating OpenTofu files"
	cd infrastructure && tofu validate

# Environment-specific validation
validate-dev:
	@echo "Validating OpenTofu files for development environment"
	cd infrastructure/environments/dev && tofu validate

validate-staging:
	@echo "Validating OpenTofu files for staging environment"
	cd infrastructure/environments/staging && tofu validate

validate-prod:
	@echo "Validating OpenTofu files for production environment"
	cd infrastructure/environments/prod && tofu validate

# Format check without modifying files
fmt-check:
	@echo "Checking OpenTofu formatting"
	cd infrastructure && tofu fmt -check -recursive

# Testing targets
test: test-infra test-k8s test-gitops test-scripts test-env-diffs
	@echo "All tests completed"

# Infrastructure tests
test-infra: validate fmt-check
	@echo "Infrastructure tests completed"

# Kubernetes manifest tests
test-k8s:
	@echo "Testing Kubernetes manifests"
	@for env in dev staging prod; do \
		echo "Building Kustomize for $$env environment..."; \
		kustomize build kubernetes/clusters/$$env > /dev/null || exit 1; \
		echo "Kustomize build for $$env environment successful"; \
	done
	@echo "All Kubernetes manifests built successfully"

# GitOps configuration tests
test-gitops:
	@echo "Testing GitOps configuration"
	@if command -v flux &> /dev/null; then \
		echo "Validating Flux installation prerequisites..."; \
		flux check --pre || echo "Note: Some Flux checks may fail without a connected Kubernetes cluster"; \
	else \
		echo "Skipping Flux validation - Flux CLI not installed"; \
	fi

# Shell script validation
test-scripts:
	@echo "Testing shell scripts"
	@if command -v shellcheck &> /dev/null; then \
		echo "Validating shell scripts with shellcheck..."; \
		shellcheck scripts/*.sh || echo "Warning: Shell scripts have some issues to fix"; \
	else \
		echo "Skipping shellcheck validation - shellcheck not installed"; \
	fi
	@echo "Running basic syntax check on shell scripts..."
	@for script in scripts/*.sh; do \
		bash -n "$$script" || exit 1; \
		echo "Syntax check passed for $$script"; \
	done

# Environment diff checking
test-env-diffs:
	@echo "Checking differences between environments"
	@echo "Comparing dev vs staging Kustomize output..."
	@diff_count=$$(diff -u <(kustomize build kubernetes/clusters/dev 2>/dev/null || echo "Build failed") \
						<(kustomize build kubernetes/clusters/staging 2>/dev/null || echo "Build failed") | grep -c "^[-+]" || true); \
	echo "Found $$diff_count differences between dev and staging"
	@echo "Comparing staging vs prod Kustomize output..."
	@diff_count=$$(diff -u <(kustomize build kubernetes/clusters/staging 2>/dev/null || echo "Build failed") \
						<(kustomize build kubernetes/clusters/prod 2>/dev/null || echo "Build failed") | grep -c "^[-+]" || true); \
	echo "Found $$diff_count differences between staging and prod"
