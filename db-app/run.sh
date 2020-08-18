#!/bin/bash

mvn clean spring-boot:build-image -Djdk.tls.client.protocols="TLSv1.2" -Dhttps.protocols="TLSv1.2"

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