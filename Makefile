# Makefile for OpenTofu AKS GitOps Management

.PHONY: init-dev init-staging init-prod plan-dev plan-staging plan-prod apply-dev apply-staging apply-prod destroy-dev destroy-staging destroy-prod bootstrap-dev bootstrap-staging bootstrap-prod clean fmt validate

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
