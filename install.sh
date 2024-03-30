#!/bin/bash

echo "Enter domain name:"
DOMAIN="docker.blackout76.tech"
# read DOMAIN
echo "Enter docker user:"
LOGIN="docker"
# read LOGIN
echo "Enter password user:"
PASSWORD="docker"
# read PASSWORD


apt-get install apache2-utils -Y

mkdir -p ./registry/certs ./registry/auth

openssl req -x509 -newkey rsa:4096 -days 3650 -nodes -sha256 -keyout registry/certs/tls.key -out registry/certs/tls.crt -subj "/CN=docker-registry"
htpasswd -Bbn "$LOGIN" "$PASSWORD" > registry/auth/htpasswd

echo ""
echo "Kubernetes deployment ..."

echo "Creating namespace"
kubectl create namespace docker-registry

echo "Generating certs secret"
kubectl create secret tls docker-registry-certs-secret --cert=registry/certs/tls.crt --key=registry/certs/tls.key --namespace docker-registry

echo "Generating auth secret"
kubectl create secret generic docker-registry-auth-secret --from-file=registry/auth/htpasswd --namespace docker-registry

echo "Deploy storage"
kubectl apply -f deploys/docker-storage.yaml

echo "Deploy docker registry"
kubectl apply -f deploys/docker-registry.yaml

echo "Deploy docker domain tls"
kubectl apply -f deploys/docker-domain-cert.yaml

echo "Deploy docker ingress"
kubectl apply -f deploys/docker-ingress.yaml