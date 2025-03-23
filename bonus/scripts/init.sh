#!/bin/bash
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${GREEN}Installation de GitLab pour le projet Inception-of-Things (jmastora)${RESET}"

# install git
sudo apt install git -y

# after install k3d cluster create gitlab namespace
echo -e "${GREEN}Création du namespace gitlab...${RESET}"
sudo kubectl create namespace gitlab --dry-run=client -o yaml | sudo kubectl apply -f -

# install helm - https://helm.sh/
echo -e "${GREEN}Installation de Helm...${RESET}"
sudo snap install helm --classic

# cheking and add host
HOST_ENTRY="127.0.0.1 gitlab.jmastora.local"
HOSTS_FILE="/etc/hosts"
if grep -q "$HOST_ENTRY" "$HOSTS_FILE"; then
    echo -e "${GREEN}L'entrée existe déjà dans $HOSTS_FILE${RESET}"
else
    echo -e "${GREEN}Ajout de l'entrée dans $HOSTS_FILE${RESET}"
    echo "$HOST_ENTRY" | sudo tee -a "$HOSTS_FILE"
fi
 
# deploy gitlab to k3d - https://docs.gitlab.com/charts/installation/deployment.html
#                      - https://gitlab.com/gitlab-org/charts/gitlab/-/tree/master/examples?ref_type=heads
echo -e "${GREEN}Ajout du dépôt Helm de GitLab...${RESET}"
sudo helm repo add gitlab https://charts.gitlab.io/
sudo helm repo update 

echo -e "${GREEN}Déploiement de GitLab (cela peut prendre jusqu'à 10 minutes)...${RESET}"
sudo helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain=jmastora.local \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --timeout 600s

echo -e "${GREEN}Attente du démarrage de GitLab...${RESET}"
sudo kubectl wait --for=condition=ready --timeout=1200s pod -l app=webservice -n gitlab

# password to gitlab (user: root)
echo -e "${GREEN}GITLAB PASSWORD : ${RESET}"
sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode
echo

# port forwarding for GitLab access
echo -e "${GREEN}Configuration du port-forwarding pour GitLab...${RESET}"
echo -e "${GREEN}Accédez à GitLab via : http://gitlab.jmastora.local ou http://localhost:80${RESET}"
sudo kubectl port-forward svc/gitlab-webservice-default -n gitlab 80:8181 2>&1 >/dev/null &

echo -e "${GREEN}Installation terminée avec succès.${RESET}"