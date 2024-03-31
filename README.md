# k3s_private_registry

## Install

- Log onto your k3s node where u want to install docker-registry.

- Prepare files:
```
git clone https://github.com/Blackout76/k3s_private_registry.git

cd k3s_private_registry

chmod +x install.sh
```

- Edit `install.sh` first var section. 

- Install: `sudo ./install.sh`

- Get tls certs: `sudo kubectl apply -f deploys/docker-domain-cert.yaml`


## Manage

Get catalog: got to `https://<your domain>/v2/_catalog/`
Check certificate detail: `sudo kubectl describe -n docker-registry Certificate tls-docker-registry`
