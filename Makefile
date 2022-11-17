ifneq (,)
This makefile requires GNU Make.
endif

.EXPORT_ALL_VARIABLES:

setup_flux:

# Check prerequisits
ifndef GITHUB_USER
	$(error GITHUB_USER is undefined)
endif

ifndef GITHUB_TOKEN
	$(error GITHUB_TOKEN is undefined)
endif

ifeq (, $(shell which kubectl))
	$(error "kubectl cli not found, please install it via https://kubernetes.io/docs/tasks/tools/")
endif

ifeq (, $(shell which flux))
	$(error "flux cli not found")
else
	flux --version
	flux check --pre
	@echo "Attempting to install Flux v0.36.0"
	@read -p "Continue [y/n]? " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy] ]]; \
	then \
		echo "Installing Flux v0.36.0..."; \
		make install_flux; \
	else \
		echo "Skipped installation..."; \
	fi
endif

# Boostrap Flux
	kubectl apply -k flux-system-bootstrap
.PHONY: setup_flux

install_flux:
# Install Flux v0.36.0
	kubectl apply -k flux-install
	kubectl wait --for condition=established --timeout=180s crd/kustomizations.kustomize.toolkit.fluxcd.io
	kubectl wait --for condition=established --timeout=180s crd/alerts.notification.toolkit.fluxcd.io
	kubectl wait --for condition=established --timeout=180s crd/providers.notification.toolkit.fluxcd.io
	kubectl wait --for condition=established --timeout=180s crd/gitrepositories.source.toolkit.fluxcd.io
	flux check
.PHONY: install_flux
