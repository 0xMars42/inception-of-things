#!/bin/bash

# Install Argo CD CLI
echo "Installing Argo CD CLI..."
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd-linux-amd64
sudo mv argocd-linux-amd64 /usr/local/bin/argocd

# Get Argo CD password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Argo CD initial admin password: $ARGOCD_PASSWORD"

# Login to Argo CD
echo "Logging in to Argo CD..."
argocd login localhost:8081 --username admin --password $ARGOCD_PASSWORD --insecure

echo "Successfully logged in to Argo CD!"
