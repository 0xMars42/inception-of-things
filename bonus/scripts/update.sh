#!/bin/bash
GREEN="\033[32m"
RESET="\033[0m"

# Récupérer le mot de passe GitLab
GITLAB_PASS=$(sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode)

# Configurer les identifiants Git
sudo echo "machine gitlab.jmastora.local
login root
password ${GITLAB_PASS}" > ~/.netrc
sudo mv ~/.netrc /root/
sudo chmod 600 /root/.netrc

# Supprimer d'abord le répertoire git_repo s'il existe déjà
sudo rm -rf git_repo

# Cloner le dépôt de GitLab
sudo git clone http://gitlab.jmastora.local/root/git_clc.git git_repo

# Copier le fichier de déploiement dans le dépôt
sudo cp confs/deployment.yaml git_repo/

# Pousser les modifications vers GitLab
cd git_repo
sudo git add .
sudo git commit -m "update deployment"
sudo git push
cd ..

# Appliquer la configuration directement
sudo kubectl apply -f confs/deployment.yaml

# Port-forwarding
echo -e "${GREEN}PORT-FORWARD : sudo kubectl port-forward svc/svc-wil -n dev 8888:8080${RESET}"