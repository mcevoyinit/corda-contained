#!/bin/sh

set -eux

kubectl delete --all pvc --grace-period=0 --force
kubectl delete --all statefulsets --grace-period=0 --force
kubectl delete --all deployments --grace-period=0 --force
kubectl delete --all services --grace-period=0 --force
kubectl delete --all pods --grace-period=0 --force
kubectl delete --all jobs --grace-period=0 --force
kubectl delete --all pv --grace-period=0 --force


while :; do
  sleep 5
  n=$(kubectl get pods | wc -l)
  if [[ n -eq 0 ]]; then
    break
  fi
done

kubectl delete --all persistentvolumeclaims