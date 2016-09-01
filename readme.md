# webvirtcloud on docker

## persistent data

To get persistent data (database, ssh key) you need to mount server side directories `/srv/webvirtcloud/data` and `/var/www/.ssh`.  
Existing databases will be upgraded by webvirtclouds migrations, an existing ssh key will be used otherwise one will be created (4096bit RSA).

## run container

### docker cli
```bash    
docker run -d \
    -p 80:80 \
    -p 6080:6080 \
    -v /srv/webvirtcloud/data:/srv/webvirtcloud/data \
    -v /srv/webvirtcloud/ssh:/var/www/.ssh \
    --name webvirtcloud \
    mplx/webvirtcloud:latest
```

### docker compose
```yml
version: '2'
services:
  webvirtcloud:
    image: mplx/webvirtcloud
    ports:
      - "80:80"
      - "6080:6080"
    volumes:
      - /srv/webvirtcloud/data:/srv/webvirtcloud/data
      - /srv/webvirtcloud/ssh:/var/www/.ssh
```
