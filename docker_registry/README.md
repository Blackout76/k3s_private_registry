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


- Then u must ceclare this private docker registry in your cluster with:
    - name
    - url: **must be** 127.0.0.1:DOCKER_PORT
    - auth user: DOCKER_LOGIN
    - auth pwd: DOCKER_PASSWORD

- And finaly add namespace access for this registry


## Manage

Get catalog: got to `https://<your domain>/v2/_catalog/`
Check certificate detail: `sudo kubectl describe -n docker-registry Certificate tls-docker-registry`
Update https tls: `sudo kubectl apply -f domain-certs/update_namespace.sh`
