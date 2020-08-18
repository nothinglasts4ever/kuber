#!/bin/bash

mvn clean spring-boot:build-image -Djdk.tls.client.protocols="TLSv1.2" -Dhttps.protocols="TLSv1.2"

kubectl delete -f .k8s/client-app-deployment.yaml
kubectl create -f .k8s/client-app-deployment.yaml

#minikube service client-app