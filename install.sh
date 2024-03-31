#!/bin/bash

############### VAR SECTION ###############

NAMESPACE="docker-registry"
DOMAIN=""
CERT_MAIL="" # must be a valid email
DOCKER_LOGIN="docker"
DOCKER_PASSWORD="docker"
DOCKER_PORT=30500 # unused port in your cluster
MASTER_NODENAME="aqua-master" # must be same as current node where u install docker registry
STORAGE_NAME="$NAMESPACE"
STORAGE_SPACE="10Gi"

###########################################


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
mkdir "/volumes/$STORAGE_NAME"
chmod -R 777 "/volumes/$STORAGE_NAME"

MANIFEST="temp.yaml"
cat << EOF >> "$MANIFEST"
apiVersion: v1
kind: PersistentVolume
metadata:
  name: "$STORAGE_NAME-pv"
spec:
  capacity:
    storage: "$STORAGE_SPACE"
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/volumes/$STORAGE_NAME"
EOF
kubectl apply -f temp.yaml
rm temp.yaml

echo "Deploy docker registry"
file_contents=$(<deploys/docker-registry.yaml)
file_contents=${file_contents//__NAMESPACE__/$NAMESPACE}
file_contents=${file_contents//__MASTER_NODENAME__/$MASTER_NODENAME}
file_contents=${file_contents//__DOCKER_PORT__/$DOCKER_PORT}
echo "$file_contents" > deploys/docker-registry.yaml
kubectl apply -f deploys/docker-registry.yaml

echo "Deploy docker domain tls"
file_contents=$(<deploys/docker-domain-cert.yaml)
file_contents=${file_contents//__NAMESPACE__/$NAMESPACE}
file_contents=${file_contents//__DOMAIN__/$DOMAIN}
file_contents=${file_contents//__MAIL__/$CERT_MAIL}
echo "$file_contents" > deploys/docker-domain-cert.yaml
#kubectl apply -f deploys/docker-domain-cert.yaml

echo "Deploy docker ingress"
file_contents=$(<deploys/docker-ingress.yaml)
file_contents=${file_contents//__NAMESPACE__/$NAMESPACE}
file_contents=${file_contents//__DOCKER_PORT__/$DOCKER_PORT}
file_contents=${file_contents//__DOMAIN__/$DOMAIN}
echo "$file_contents" > deploys/docker-ingress.yaml
kubectl apply -f deploys/docker-ingress.yaml