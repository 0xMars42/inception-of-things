#!/bin/bash

# Install necessary packages
echo "Installing necessary packages..."
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker
echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Start Docker service
systemctl enable docker
systemctl start docker

# Add current user to docker group
usermod -aG docker $USER
echo "Docker installed successfully!"

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
echo "kubectl installed successfully!"

# Install K3d
echo "Installing K3d..."
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
echo "K3d installed successfully!"

# Create K3d cluster
echo "Creating K3d cluster..."
k3d cluster create mycluster -p "8081:80@loadbalancer" -p "8889:8889@loadbalancer"

# Install Argo CD
echo "Installing Argo CD..."
kubectl create namespace argocd
kubectl create namespace dev
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD to be ready
echo "Waiting for Argo CD to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

# Port forward Argo CD API server
echo "Setting up port forwarding for Argo CD..."
kubectl port-forward svc/argocd-server -n argocd 8081:443 &

# Get the initial password for Argo CD
echo "Getting the initial password for Argo CD..."
sleep 10
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Argo CD initial admin password: $ARGOCD_PASSWORD"

# Apply application configuration
echo "Applying application configuration..."
kubectl apply -f ../confs/application.yaml

echo "Setup completed successfully!"
