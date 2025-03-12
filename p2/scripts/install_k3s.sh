#!/bin/bash

# Installer K3s avec la bonne interface
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=192.168.56.110 --flannel-iface=enp0s8" sh -
sleep 20

# Configurer kubectl
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc
sed -i -e "s/127.0.0.1/192.168.56.110/g" /home/vagrant/.kube/config

# Appliquer les configurations
kubectl apply -f /vagrant/confs/app1-deployment.yaml
kubectl apply -f /vagrant/confs/app2-deployment.yaml
kubectl apply -f /vagrant/confs/app3-deployment.yaml
kubectl apply -f /vagrant/confs/ingress.yaml

# Ajouter les entrées dans /etc/hosts
echo "192.168.56.110 app1.com app2.com app3.com" >> /etc/hosts
