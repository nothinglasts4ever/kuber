#!/bin/bash

eval $(minikube docker-env)
mvn clean install
docker build -t db-app .

kubectl delete configmap postgres-config
kubectl create -f .k8s/postgres-configmap.yaml

kubectl delete configmap db-app
kubectl create configmap db-app --from-file=.k8s/application.yaml

kubectl delete postgres-secret
kubectl apply -f .k8s/postgres-secret.yaml

kubectl delete -f .k8s/postgres-deployment.yaml
kubectl create -f .k8s/postgres-deployment.yaml

kubectl delete -f .k8s/db-app-deployment.yaml
kubectl create -f .k8s/db-app-deployment.yaml

#minikube service db-app