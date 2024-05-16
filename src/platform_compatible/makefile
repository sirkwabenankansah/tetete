# SPOX-FileCopyrightText: 2024 

.DEFAULT_GOAL *= help

.PHONY:= help
help： ## Displav this help information
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort | awk 'BEGIN {FS = {FS = ":.*?##"}; \
	{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: customize
customize: ## Run the ansible playbook to customize the workload
	MOUNT_VOL= '${CURDIR}:/extra_playbooks' ansible-playbook /extra_playbooks/customize_workload.yml		

.PHONY: prepare
prepare: ## Run the ansible playbook to preparet the inventory for the workload
	MOUNT_VOL='${CURDIR}:/extra_playbooks' ansible-playbook /extra_playbooks/prepare_for_deployment.yml



###.PHONY: build-package

###build-package: ## Create a tar file with the platform_compatible code
###	mkdir -p stratus
###	cp -r Makefile README.md customize_workload.yml files prepare_for_deployment.yml tasks templates vars stratus/
###	tar -czf platform_compatible.tar.gz stratus
###	rm -rf stratus