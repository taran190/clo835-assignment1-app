#!/bin/bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REGISTRY

docker network create appnet --driver bridge || true

docker run -d --name mysql --network appnet \
  -e MYSQL_ROOT_PASSWORD=pw -e MYSQL_DATABASE=employees \
  $REGISTRY/clo835-mysql:latest

docker run -d --name blue --network appnet -p 8081:8080 \
  -e DBHOST=mysql -e DBPORT=3306 -e DBUSER=root -e DBPWD=pw -e DATABASE=employees -e APP_COLOR=blue \
  $REGISTRY/clo835-app:latest

docker run -d --name pink --network appnet -p 8082:8080 \
  -e DBHOST=mysql -e DBPORT=3306 -e DBUSER=root -e DBPWD=pw -e DATABASE=employees -e APP_COLOR=pink \
  $REGISTRY/clo835-app:latest

docker run -d --name lime --network appnet -p 8083:8080 \
  -e DBHOST=mysql -e DBPORT=3306 -e DBUSER=root -e DBPWD=pw -e DATABASE=employees -e APP_COLOR=lime \
  $REGISTRY/clo835-app:latest

