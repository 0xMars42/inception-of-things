#!/bin/bash

# create user name and root for gitlab
GITLAB_PASS=$(sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode)
sudo echo "machine gitlab.k3d.gitlab.com
login root
password ${GITLAB_PASS}" > ~/.netrc
sudo mv ~/.netrc /root/
sudo chmod 600 /root/.netrc

# clone repo
sudo git clone http://gitlab.k3d.gitlab.com/root/git_clc.git git_repo

# clone repo from github
sudo git clone https://github.com/0xMars42/42iot.git git_clc

# copy from git_clc and git_repo
sudo mv git_clc/manifests git_repo/

# del repo from github
sudo rm -rf git_clc/

cd git_repo
sudo git add *
sudo git commit -m "update"
sudo git push
cd ..

sudo kubectl apply -f ../confs/deploy.yaml

# Warning port-forward
echo "${GREEN}PORT-FORWARD : sudo kubectl port-forward svc/svc-wil -n dev 8888:8080${RESET}"