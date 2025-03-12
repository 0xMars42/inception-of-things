#!/bin/sh

sudo apt-get update
sudo apt-get install -y curl net-tools

echo "Using token: $K3S_TOKEN"

curl -sfL https://get.k3s.io | sh -s server \
  --flannel-iface=eth1 \
  --token "$K3S_TOKEN" \
  --write-kubeconfig-mode 644

sudo mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo sed -i 's/127.0.0.1/192.168.56.110/g' /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube

sudo cp /home/vagrant/.kube/config /vagrant/kubeconfig