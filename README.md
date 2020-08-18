## Usage
* Install and run Minikube from shell *minikube start*
* Run script *./run.sh*
* Run *minikube service client-app* to get service URL
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
      nodePort: 30007
  type: NodePort
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
          imagePullPolicy: IfNotPresent
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
mvn clean install
docker build -t db-app .
kubectl delete -f db-app-deployment.yaml
kubectl create -f db-app-deployment.yaml
```
You can access to the app endpoint using the following command:
```bash
minikube service db-app
```
## Communication Between Services
### Build configuration
Add dependency to the pom.xml:
```xml
<properties>
    <spring-cloud-kubernetes.version>1.1.3.RELEASE</spring-cloud-kubernetes.version>
</properties>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-kubernetes-all</artifactId>
    <version>${spring-cloud-kubernetes.version}</version>
</dependency>
```
### Application configuration
Add the following annotations to Spring Boot app:
```java
@EnableDiscoveryClient
@EnableFeignClients
```
Put service name to properties:
```yaml
db-app:
  url: http://db-app:8080
```
To access to other apps use Feign client:
```java
@FeignClient(url = "${db-app.url}", name = "db-app")
```
## Adding Database
### Introducing ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
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
                name: postgres-config
          volumeMounts:
            - mountPath: /var/lib/postgresql/data
              name: pg-data
      volumes:
        - hostPath:
            path: /tmp/private/docker/pgdata
          name: pg-data
```
### Application Deployment
Add ConfigMap to the app deployment:
```yaml
    spec:
      containers:
          envFrom:
            - configMapRef:
                name: postgres-config
```
### Run Script
Add the following snippet to the run script:
```bash
kubectl delete configmap postgres-config
kubectl create -f .k8s/postgres-configmap.yaml
```
## Adding Secrets 
### Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
data:
  POSTGRES_USER: dXNlcg==
  POSTGRES_PASSWORD: cDQ1NXcwcmQ=
```
### Application Deployment
Add secret to the app deployment:
```yaml
    spec:
      containers:
          envFrom:
            - secretRef:
                name: postgres-secret
```
### Run Script
Add the following snippet to the run script:
```bash
kubectl apply -f .k8s/postgres-secret.yaml
```
## Introducing Buildpacks
Instead of building app with maven and then creating image with docker Buildpacks can be used:
```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <configuration>
        <layers>
            <enabled>true</enabled>
        </layers>
    </configuration>
</plugin>
```
```shell script
mvn clean spring-boot:build-image -Djdk.tls.client.protocols="TLSv1.2" -Dhttps.protocols="TLSv1.2" 
```
TLS settings needed due to Java issue with TLS1.3 connection https://bugs.openjdk.java.net/browse/JDK-8236039