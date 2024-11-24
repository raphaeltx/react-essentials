#!/bin/bash

set -e

DEPLOYMENT_FILE="k8s/deployment.yaml"
SERVICE_FILE="k8s/service.yaml"
INGRESS_FILE="k8s/ingress.yaml"

printf "Undeploying Kubernetes resources...\n"

kubectl delete -f $INGRESS_FILE
kubectl delete -f $SERVICE_FILE
kubectl delete -f $DEPLOYMENT_FILE

IMAGE_NAME="react-essentials"
printf "Removing Docker image from Kind cluster: $IMAGE_NAME...\n"
kind unload docker-image $IMAGE_NAME

printf "Removing local Docker image: $IMAGE_NAME...\n"
docker rmi $IMAGE_NAME || printf "Local image $IMAGE_NAME not found.\n"

if grep -q "react-essentials.local" /etc/hosts; then
    printf "Removing 'react-essentials.local' from /etc/hosts...\n"
    sudo sed -i '/react-essentials.local/d' /etc/hosts
else
    printf "'react-essentials.local' not found in /etc/hosts\n"
    exit 1
fi

printf "Verifying pod status...\n"
kubectl get pods

printf "Cleaning up stopped Docker containers...\n"
docker container prune -f

printf "Cleaning up unused Docker images...\n"
docker image prune -f

printf "Undeployment and cleanup completed!\n"
