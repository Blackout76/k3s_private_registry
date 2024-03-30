#!/bin/bash

echo "Enter domain name:"
# DOMAIN=""
read DOMAIN

echo "Enter valid email (domain certs):"
# CERT_MAIL=""
read CERT_MAIL

echo "Enter docker username:"
# DOCKER_LOGIN="docker"
read LOGIN

echo "Enter docker password:"
# DOCKER_PASSWORD="docker"
read PASSWORD

echo "Enter docker registry port:"
# DOCKER_PORT=30500
read DOCKER_PORT

echo "Enter docker registry volume path:"
# DOCKER_PVC="/volumes/docker_registry"
read DOCKER_PVC


apt-get install apache2-utils -Y

mkdir -p ./registry/certs ./registry/auth

openssl req -x509 -newkey rsa:4096 -days 3650 -nodes -sha256 -keyout registry/certs/tls.key -out registry/certs/tls.crt -subj "/CN=docker-registry"
htpasswd -Bbn "$DOCKER_LOGIN" "$DOCKER_PASSWORD" > registry/auth/htpasswd

echo ""
echo "Kubernetes deployment ..."

echo "Creating namespace"
kubectl create namespace docker-registry

echo "Generating certs secret"
kubectl create secret tls docker-registry-certs-secret --cert=registry/certs/tls.crt --key=registry/certs/tls.key --namespace docker-registry

echo "Generating auth secret"
kubectl create secret generic docker-registry-auth-secret --from-file=registry/auth/htpasswd --namespace docker-registry

echo "Deploy storage"
file_contents=$(<deploys/docker-storage.yaml)
echo "${file_contents//__DOCKER_PVC__/$DOCKER_PVC}" > deploys/docker-storage.yaml
kubectl apply -f deploys/docker-storage.yaml

echo "Deploy docker registry"
file_contents=$(<deploys/docker-registry.yaml)
echo "${file_contents//__DOCKER_PORT__/$DOCKER_PORT}" > deploys/docker-registry.yaml
kubectl apply -f deploys/docker-registry.yaml

echo "Deploy docker domain tls"
file_contents=$(<deploys/docker-domain-cert.yaml)
file_contents=${file_contents//__DOMAIN__/$DOMAIN}
file_contents=${file_contents//__MAIL__/$CERT_MAIL}
echo "$file_contents" > deploys/docker-domain-cert.yaml
kubectl apply -f deploys/docker-domain-cert.yaml

echo "Deploy docker ingress"
file_contents=$(<deploys/docker-ingress.yaml)
echo "${file_contents//__DOCKER_PORT__/$DOCKER_PORT}" > deploys/docker-ingress.yaml
kubectl apply -f deploys/docker-ingress.yaml