#!/bin/bash

# Check deployment status
echo "Checking deployment status..."
kubectl get pods -n dev

# Check application version
echo ""
echo "Current application version in deployment:"
kubectl get deployment playground -n dev -o jsonpath="{.spec.template.spec.containers[0].image}" | awk -F':' '{print $2}'

# Check if application is accessible
echo ""
echo "Testing application response:"
curl http://localhost:8889/

# Check Argo CD application status
echo ""
echo "Argo CD application status:"
kubectl get application myapp -n argocd -o jsonpath="{.status.sync.status}" && echo ""
