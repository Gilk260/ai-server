.PHONY: plan apply destroy fmt validate init refresh console output state-list help dev prod

# --- Configuration ---
VALID_ENVS := dev prod
TOFU       := tofu

# Extract environment from command line (dev or prod passed as a target)
ENV := $(strip $(filter $(VALID_ENVS),$(MAKECMDGOALS)))

PLANFILE      := .plan-$(ENV).tfplan
TFVARS        := environments/$(ENV).tfvars
SECRET_TFVARS := environments/$(ENV).secret.tfvars
VAR_FILES     := -var-file=$(TFVARS) -var-file=$(SECRET_TFVARS)

# Color codes
RED    := \033[0;31m
GREEN  := \033[0;32m
YELLOW := \033[1;33m
CYAN   := \033[0;36m
BOLD   := \033[1m
RESET  := \033[0m

# --- Guards ---
define require_env
	@[ -n "$(ENV)" ] || { printf "$(RED)Usage: make $(1) <dev|prod>$(RESET)\n"; exit 1; }
endef

define check_var_files
	@test -f $(TFVARS) || { printf "$(RED)Missing: $(TFVARS)$(RESET)\n"; exit 1; }
	@test -f $(SECRET_TFVARS) || { printf "$(RED)Missing: $(SECRET_TFVARS)$(RESET)\n"; exit 1; }
endef

define banner
	@printf "\n$(BOLD)══════════════════════════════════════════$(RESET)\n"
	@printf "$(CYAN)  Action:      $(BOLD)%s$(RESET)\n" "$(1)"
	@printf "$(CYAN)  Environment: $(BOLD)%s$(RESET)\n" "$(ENV)"
	@printf "$(CYAN)  Var files:   $(RESET)%s\n" "$(TFVARS)"
	@printf "$(CYAN)               $(RESET)%s\n" "$(SECRET_TFVARS)"
	@printf "$(CYAN)  Plan file:   $(RESET)%s\n" "$(PLANFILE)"
	@printf "$(BOLD)══════════════════════════════════════════$(RESET)\n\n"
endef

define confirm_destructive
	@printf "$(RED)$(BOLD)⚠  You are about to $(1) the $(ENV) environment$(RESET)\n"
	@printf "$(YELLOW)   Type '$(ENV)' to confirm: $(RESET)"
	@read ans && [ "$$ans" = "$(ENV)" ] || { printf "$(RED)Aborted.$(RESET)\n"; exit 1; }
	@echo ""
endef

define select_workspace
	@$(TOFU) workspace select $(ENV)
endef

# Consume env targets silently
dev prod:
	@:

# --- Targets ---

plan: ## Plan and save to .plan-<env>.tfplan
	$(call require_env,plan)
	$(check_var_files)
	$(call banner,plan)
	$(select_workspace)
	$(TOFU) plan $(VAR_FILES) -out=$(PLANFILE)
	@printf "\n$(GREEN)Plan saved to $(BOLD)$(PLANFILE)$(RESET)\n"
	@printf "$(CYAN)Review, then run: $(BOLD)make apply $(ENV)$(RESET)\n"

apply: ## Apply a saved plan (requires confirmation)
	$(call require_env,apply)
	@test -f $(PLANFILE) || { printf "$(RED)No plan file found: $(PLANFILE)$(RESET)\n"; printf "$(CYAN)Run 'make plan $(ENV)' first.$(RESET)\n"; exit 1; }
	$(call banner,apply)
	@printf "$(CYAN)Applying saved plan: $(BOLD)$(PLANFILE)$(RESET)\n"
	@printf "$(CYAN)Plan created: $(BOLD)$$(stat -c '%y' $(PLANFILE) 2>/dev/null | cut -d. -f1)$(RESET)\n\n"
	$(call confirm_destructive,APPLY to)
	$(select_workspace)
	$(TOFU) apply $(PLANFILE)
	@rm -f $(PLANFILE)
	@printf "\n$(GREEN)Plan file cleaned up.$(RESET)\n"

destroy: ## Destroy resources (requires confirmation)
	$(call require_env,destroy)
	$(check_var_files)
	$(call banner,destroy)
	$(call confirm_destructive,DESTROY)
	$(select_workspace)
	$(TOFU) destroy $(VAR_FILES)

refresh: ## Refresh state
	$(call require_env,refresh)
	$(check_var_files)
	$(call banner,refresh)
	$(select_workspace)
	$(TOFU) refresh $(VAR_FILES)

validate: ## Validate configuration
	$(call require_env,validate)
	$(call banner,validate)
	$(select_workspace)
	$(TOFU) validate

console: ## Interactive console
	$(call require_env,console)
	$(check_var_files)
	$(call banner,console)
	$(select_workspace)
	$(TOFU) console $(VAR_FILES)

output: ## Show outputs
	$(call require_env,output)
	$(call banner,output)
	$(select_workspace)
	$(TOFU) output

state-list: ## List resources in state
	$(call require_env,state-list)
	$(call banner,state list)
	$(select_workspace)
	$(TOFU) state list

init: ## Initialize tofu
	$(TOFU) init

fmt: ## Format code
	@$(TOFU) fmt -recursive

help: ## Show this help
	@printf "$(BOLD)tf — OpenTofu workspace wrapper$(RESET)\n\n"
	@printf "$(CYAN)Usage:$(RESET) make <action> <dev|prod>\n\n"
	@printf "$(BOLD)Targets:$(RESET)\n"
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-14s$(RESET) %s\n", $$1, $$2}'
	@printf "\n$(BOLD)Examples:$(RESET)\n"
	@printf "  make plan dev\n"
	@printf "  make apply prod\n"
	@printf "  make state-list dev\n"
	@printf "  make fmt\n"
