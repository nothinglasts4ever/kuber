#!/bin/bash

eval $(minikube docker-env)

kubectl delete configmap postgres-config
kubectl create -f .k8s/postgres-configmap.yaml

kubectl delete -f .k8s/postgres-deployment.yaml
kubectl create -f .k8s/postgres-deployment.yaml