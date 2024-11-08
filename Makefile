# Makefile
TF="tofu"

# ANSI color codes
GREEN = \033[32m
RED = \033[31m
RESET = \033[0m

# Define the AWS profile as a variable
AWS_PROFILE ?= acloud

# Set AWS_PROFILE for AWS CLI commands
export AWS_PROFILE

# Set the environment variable (default is "prod")
ENV ?= dev

# info block
HEADER := Provisioning environment: $(ENV) using profile $(AWS_PROFILE)

# reconfigure for prod/dev
reconfig:
	@echo "$(if $(filter dev,$(ENV)),$(GREEN),$(RED))$(HEADER)$(RESET)"
#	# $(TF) init -reconfigure -var-file=$(ENV).tfvars -backend-config=$(ENV)-backend.conf
	$(TF) init -reconfigure -var-file=$(ENV).tfvars

# Target: init
init:
	@echo "$(if $(filter dev,$(ENV)),$(GREEN),$(RED))$(HEADER)$(RESET)"
	$(TF) init -var-file=$(ENV).tfvars

plan:
	@echo "$(if $(filter dev,$(ENV)),$(GREEN),$(RED))$(HEADER)$(RESET)"
	$(TF) plan -var-file=$(ENV).tfvars

apply:
	@echo "$(if $(filter dev,$(ENV)),$(GREEN),$(RED))$(HEADER)$(RESET)"
	$(TF) apply -var-file=$(ENV).tfvars

destroy:
	@echo "$(if $(filter dev,$(ENV)),$(GREEN),$(RED))$(HEADER)$(RESET)"
	$(TF) destroy -var-file=$(ENV).tfvars
# Vim modeline
# vim: syntax=make ts=8 sw=8 noet
