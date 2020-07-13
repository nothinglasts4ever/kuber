#!/bin/bash

eval $(minikube docker-env)
cd db-app
./run_pg.sh
./run.sh
cd ../client-app
./run.sh

kubectl get pods