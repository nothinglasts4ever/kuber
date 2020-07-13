#!/bin/bash

eval $(minikube docker-env)
mvn clean install
docker build -t client-app .

kubectl delete -f .k8s/client-app-deployment.yaml
kubectl create -f .k8s/client-app-deployment.yaml

#minikube service client-app