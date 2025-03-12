#!/bin/bash

# Check if version parameter is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v2"
    exit 1
fi

VERSION=$1

# Check if version is v1 or v2
if [ "$VERSION" != "v1" ] && [ "$VERSION" != "v2" ]; then
    echo "Error: Version must be either v1 or v2"
    exit 1
fi

# Update the deployment file
echo "Updating deployment.yaml to use version $VERSION..."
if [ -f "confs/app/deployment.yaml" ]; then
    sed -i "s|image: wil42/playground:.*|image: wil42/playground:$VERSION|g" confs/app/deployment.yaml
    echo "Deployment file updated successfully!"
    
    echo "Current version in deployment.yaml:"
    grep "image: wil42/playground" confs/app/deployment.yaml
else
    echo "Error: deployment.yaml not found"
    exit 1
fi

# Commit and push changes if inside a git repository
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Git repository detected. Would you like to commit and push the changes? (y/n)"
    read answer
    
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        git add confs/app/deployment.yaml
        git commit -m "Update application to $VERSION"
        git push
        echo "Changes committed and pushed to repository"
    else
        echo "Changes not committed. You can manually commit and push to trigger Argo CD sync."
    fi
else
    echo "Not inside a git repository. Manual commit and push required to trigger Argo CD sync."
fi

echo "Wait for Argo CD to detect and sync the changes..."
