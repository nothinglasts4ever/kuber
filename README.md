## Standalone Docker Deployment
### Dockerfile
To create docker image for Spring Boot app use the following Dockerfile: 
```bash
FROM openjdk:8-jdk-alpine
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
ARG DEPENDENCY=target/dependency
COPY ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY ${DEPENDENCY}/META-INF /app/META-INF
COPY ${DEPENDENCY}/BOOT-INF/classes /app
ENTRYPOINT ["java","-cp","app:app/lib/*","com.example.demo.WebApplication"]
```
### Run script
To build the app using Maven, create Docker image and start it use the following bash script:
```bash
#!/bin/bash

cd ..
mvn clean
mvn spring-boot:build-image -Dspring-boot.build-image.imageName=db-app
docker run -p 8080:8080 db-app
```
## Introducing Kubernetes
### Kubernetes Deployment
Here is service and deployment config for the app:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: db-app
spec:
  selector:
    app: db-app
  ports:
    - protocol: TCP
      port: 8080
      nodePort: 30083
  type: LoadBalancer
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-app
spec:
  selector:
    matchLabels:
      app: db-app
  replicas: 1
  template:
    metadata:
      labels:
        app: db-app
    spec:
      containers:
        - name: db-app
          image: db-app:latest
          imagePullPolicy: Never
          ports:
            - containerPort: 8080
```
### Run Script
First you need to start Minikube:
```bash
minikube start
minikube dashboard
```
Here is the bash script to build and deploy the app in Kubernetes
```bash
#!/bin/bash

eval $(minikube docker-env)
mvn clean
mvn spring-boot:build-image -Dspring-boot.build-image.imageName=db-app
kubectl delete -f db-app-deployment.yaml
kubectl create -f db-app-deployment.yaml
kubectl get pods
```
You can access to the app endpoint using the following command:
```bash
minikube service web-app
```
## Adding Database
### Introducing ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-app
  labels:
    app: web-app
data:
  POSTGRES_DB: web
  POSTGRES_USER: user
  POSTGRES_PASSWORD: p455w0rd
```
### Postgres Deployment
```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  selector:
    app: postgres
  ports:
    - port: 5432
  type: NodePort
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
  selector:
    matchLabels:
      app: postgres
  replicas: 1
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:12
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 5432
          envFrom:
            - configMapRef:
                name: web-app
          volumeMounts:
            - mountPath: /var/lib/postgresql/data
              name: web-data
      volumes:
        - hostPath:
            path: "/home/docker/pgdata"
          name: web-data
```
### Application Deployment
Add ConfigMap to the app deployment:
```yaml
    spec:
      containers:
          envFrom:
            - configMapRef:
                name: web-app
```
### Run Script
Add the following snippet to the run script:
```bash
kubectl delete configmap web-app
kubectl create -f web-app-configmap.yaml
kubectl create -f web-app-deployment.yaml
```
## Introducing Ingress ?
## Adding Secrets 