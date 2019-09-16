#!/usr/bin/env bash

# deploy the persistent volumes
kubectl apply -f kbs-enm-persistent-volumes
kubectl apply -f kbs-nodes-persistent-volumes

# deploys the persistent volume claims, pods and services
kubectl apply -f kbs-enm
sleep 5
kubectl apply -f kbs-nodes

# list running pods
kubectl get pods
