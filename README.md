# Strichliste (WIP)

**Attention**: Don't use this yet. This docker container still uses the deprecated sqlite which will lead to errors when using the split invoice function. 

This is a already set up, ready to go docker container for the strichliste service (https://www.strichliste.org/).
The container uses the strichliste-backend (https://github.com/strichliste/strichliste-backend) and strichliste-web-frontend (https://github.com/strichliste/strichliste-web-frontend) repositories.

The Dockerfile as well as the configuration files are taken/based on the docker branch of sti-ip (https://github.com/stp-ip/server).

## Quick setup

This repository was created to be cloned and run with only minimal configuration needed.
To get started you simply clone this repository,
```git clone https://github.com/strichliste/strichliste-docker.git```

go into the strichliste directory and execute
```docker-compose up -d```
to start the container.

If you migrate from an older version of this repository you might need to rebuild the container to be able to use the new features:
```docker-compose up --build -d```

This creates a docker container based on alpine linux which contains the sourcefiles of https://github.com/strichliste/server. 
As default the service is running on localhost:8080

## Traefik configuration
To use traefik (https://traefik.io/) the docker-compose file has comments for the necessary configuration which should make it easy to setup.
