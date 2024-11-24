#!/bin/bash

set -e

IMAGE_NAME="react-essentials"

undo_changes() {
    sorce ./undeploy_local.sh
}

if [[ ! -f "Dockerfile" || ! -f "k8s/deployment.yaml" || ! -f "k8s/service.yaml" || ! -f "k8s/ingress.yaml" ]]; then
    printf "Required files (Dockerfile, k8s/deployment.yaml, k8s/service.yaml, k8s/ingress.yaml) are missing.\n"
    exit 1
fi

printf "Building Docker image...\n"
docker build -t $IMAGE_NAME .

printf "Loading Docker image into Kind...\n"
kind load docker-image $IMAGE_NAME:latest --name kind || undo_changes

printf "Applying Kubernetes resources...\n"
kubectl apply -f k8s/deployment.yaml || undo_changes
kubectl apply -f k8s/service.yaml || undo_changes
kubectl apply -f k8s/ingress.yaml || undo_changes

printf "Updating /etc/hosts...\n"
printf "127.0.0.1 react-essentials.local" | sudo tee -a /etc/hosts || undo_changes

printf "Deployment successful! You can access the app at http://react-essentials.local\n"
