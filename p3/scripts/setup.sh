#!/bin/bash

# install docker for Kali Linux
apt-get update

apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# For Kali Linux, use Docker's Debian repository instead of Ubuntu
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

# For Kali Linux, you can use the following packages
apt-get install -y docker.io

# Alternatively, try installing moby packages if docker.io fails
if [ $? -ne 0 ]; then
    apt-get install -y moby-engine moby-cli moby-containerd
fi

# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

# install k3d
wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

# create cluster
k3d cluster create iotcluster -p "8888:30081"

# create namespaces
kubectl create namespace argocd
kubectl create namespace dev

# setup argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD pods to be ready
echo "Waiting for ArgoCD pods to start..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd