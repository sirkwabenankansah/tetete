# SPDX-FileCopyrightText: 2024 Accen
.DEFAULT_GOAL := help

.PHONY: help
help: ## Display this help information
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort | awk 'BEGIN {FS = ":.*?## "}; \
	{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: customize
customize: ## Run the ansible playbook to customize the workload
	MOUNT_VOL='${CURDIR}:/extra_playbooks' ansible-playbook /extra_playbooks/customize_workload.yml

.PHONY: prepare
prepare: ## Run the ansible playbook to prepare the inventory for the workload
	MOUNT_VOL='${CURDIR}:/extra_playbooks' ansible-playbook /extra_playbooks/prepare_for_deployment.yml

.PHONY: build-package
build-package: dist ## Create a tar file of the platform-compatible code
	tar -czf platform_compatible.tar.gz stratus/

dist: ## Prepare the distribution directory
	mkdir -p stratus
	cp -r Makefile README.md customize_workload.yml files prepare_for_deployment.yml tasks templates vars stratus/
