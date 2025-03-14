# Cibles principales
all: setup deploy

# Installation et configuration
setup:
	@echo "Setting up k3d, Kubernetes and ArgoCD..."
	@sudo scripts/setup.sh

# Installation d'ArgoCD
install-argocd:
	@echo "Installing ArgoCD..."
	@scripts/install-argocd.sh

# Déploiement de l'application
deploy: install-argocd
	@echo "Deploying application with ArgoCD..."
	@kubectl apply -f deployment.yaml

# Nettoyage
clean:
	@echo "Cleaning up..."
	@k3d cluster delete iotcluster 2>/dev/null || true
	@rm -f argocdlogs.log

# Rechargement complet
re: clean all

.PHONY: all setup install-argocd deploy clean re