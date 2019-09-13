#!/usr/bin/env bash

# deploy the persistent volumes
kubectl apply -f persistent-volumes/kbs-enm-persistent-volumes
kubectl apply -f persistent-volumes/kbs-nodes-persistent-volumes

# deploys the persistent volume claims, pods and services
kubectl apply -f deployments/kbs-enm
sleep 5
kubectl apply -f deployments/kbs-nodes

# list running pods
kubectl get pods
