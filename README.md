# k3s_private_registry

## Install

```
git clone https://github.com/Blackout76/k3s_private_registry.git

cd k3s_private_registry

chmod +x install.sh

sudo ./install.sh
```

## access

Catalog: got to `https://<your domain>/v2/_catalog/`
Certificate detail: `sudo kubectl describe -n docker-registry Certificate tls-docker-registry`