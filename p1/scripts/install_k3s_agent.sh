#!/bin/sh

sudo apt-get update
sudo apt-get install -y curl net-tools

echo "Using token: $K3S_TOKEN"

curl -sfL https://get.k3s.io | sh -s agent \
  --server https://$SERVER_IP:6443 \
  --node-ip=$(hostname -I | awk '{print $2}') \
  --token "$K3S_TOKEN"

sudo mkdir -p /home/vagrant/.kube
sudo cp /vagrant/kubeconfig /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube