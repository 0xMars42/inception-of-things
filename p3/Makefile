# Inception of Things P3 Makefile

# Variables
KUBECTL = kubectl
K3D = k3d
SCRIPTS_DIR = ./scripts
CONFS_DIR = ./confs

# Default target
all: setup install-argocd deploy-app

# Setup the K3D cluster and namespaces
setup:
	@echo "Setting up K3D cluster and namespaces..."
	@bash $(SCRIPTS_DIR)/setup.sh
	@echo "Waiting for ArgoCD to initialize..."
	@sleep 30

# Install ArgoCD
install-argocd:
	@echo "Installing ArgoCD..."
	@bash $(SCRIPTS_DIR)/install-argocd.sh

# Deploy the application v1
deploy-app-v1:
	@echo "Deploying application v1..."
	@$(KUBECTL) apply -f $(CONFS_DIR)/app/v1/willapp.yaml

# Deploy the application v2
deploy-app-v2:
	@echo "Deploying application v2..."
	@$(KUBECTL) apply -f $(CONFS_DIR)/app/v2/deployment.yaml

# Deploy both versions
deploy-app: deploy-app-v1 deploy-app-v2

# Check the status of ArgoCD
check-argocd:
	@echo "Checking ArgoCD status..."
	@$(KUBECTL) get pods -n argocd
	@$(KUBECTL) get svc -n argocd

# Check the status of the application
check-app:
	@echo "Checking application status..."
	@$(KUBECTL) get pods -n dev
	@$(KUBECTL) get svc -n dev

# Access ArgoCD UI
access-argocd:
	@echo "Accessing ArgoCD UI..."
	@bash -c "kubectl port-forward svc/argocd-server -n argocd 8080:443 &"
	@echo "ArgoCD UI is available at https://localhost:8080"
	@echo "Username: admin"
	@echo -n "Password: "
	@$(KUBECTL) -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	@echo ""

# Clean up
clean:
	@echo "Cleaning up..."
	@$(K3D) cluster delete iotcluster

# Help
help:
	@echo "Available targets:"
	@echo "  all             - Setup cluster, install ArgoCD, and deploy apps"
	@echo "  setup           - Setup K3D cluster and namespaces"
	@echo "  install-argocd  - Install ArgoCD"
	@echo "  deploy-app-v1   - Deploy application v1"
	@echo "  deploy-app-v2   - Deploy application v2"
	@echo "  deploy-app      - Deploy both app versions"
	@echo "  check-argocd    - Check ArgoCD status"
	@echo "  check-app       - Check application status"
	@echo "  access-argocd   - Access ArgoCD UI"
	@echo "  clean           - Clean up resources"
	@echo "  help            - Show this help message"

.PHONY: all setup install-argocd deploy-app-v1 deploy-app-v2 deploy-app check-argocd check-app access-argocd clean help