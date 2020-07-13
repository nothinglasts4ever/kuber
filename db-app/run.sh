#!/bin/bash

eval $(minikube docker-env)
mvn clean install
docker build -t db-app .

kubectl delete configmap db-app
kubectl create configmap db-app --from-file=.k8s/application.yaml

kubectl delete -f .k8s/db-app-deployment.yaml
kubectl create -f .k8s/db-app-deployment.yaml

#minikube service db-app