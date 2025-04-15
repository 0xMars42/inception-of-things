#!/bin/bash
GREEN="\033[32m"
RESET="\033[0m"

# Récupérer le mot de passe GitLab
GITLAB_PASS=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode)
echo -e "${GREEN}Mot de passe GitLab récupéré.${RESET}"

# Vérifier si le namespace argocd existe
if ! kubectl get namespace | grep -q "argocd"; then
    echo -e "${GREEN}Création du namespace argocd...${RESET}"
    kubectl create namespace argocd
fi

# Installer ArgoCD s'il n'est pas déjà installé
if ! kubectl get pods -n argocd | grep -q "argocd-server"; then
    echo -e "${GREEN}Installation d'ArgoCD...${RESET}"
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    echo -e "${GREEN}Attente du démarrage d'ArgoCD...${RESET}"
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
fi

# Créer le namespace dev s'il n'existe pas
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

# Créer l'application ArgoCD qui pointe vers votre dépôt GitLab
echo -e "${GREEN}Configuration de l'application ArgoCD...${RESET}"
cat > argocd-app.yaml << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd-wilapp
  namespace: argocd
spec:
  destination:
    namespace: dev
    server: https://kubernetes.default.svc
  project: default
  source:
    repoURL: http://gitlab.jmastora.local/root/git-clc.git
    path: .
    targetRevision: main
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

kubectl apply -f argocd-app.yaml

# Configurer le port-forwarding pour ArgoCD
echo -e "${GREEN}Configuration du port-forwarding pour ArgoCD...${RESET}"
nohup kubectl port-forward svc/argocd-server -n argocd 8080:443 >> argocdlogs.log 2>&1 &

# Afficher les informations de connexion ArgoCD
echo -e "${GREEN}ArgoCD est configuré et accessible sur http://localhost:8080${RESET}"
echo -e "${GREEN}Utilisateur: admin${RESET}"
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo -e "${GREEN}Mot de passe: ${ARGOCD_PASS}${RESET}"

echo -e "${GREEN}Configuration terminée.${RESET}"