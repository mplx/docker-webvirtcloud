# WebVirtCloud on docker

retspen's WebVirtCloud is a web interface to kvm virtualization and can be found on [github](https://github.com/retspen/webvirtcloud)

## persistent data

To get persistent data (database, ssh key) you need to mount container side directories `/srv/webvirtcloud/data` and `/var/www/.ssh` (i.e. `-v /srv/webvirtcloud/data:/srv/webvirtcloud/data`).

- an existing database (`db.sqlite3`) will be used and upgraded by webvirtcloud's migrations
- an existing ssh key will be used otherwise one will be created (4096 bit RSA)
- warning: do not mount your ~/.ssh as key source - permissions will be updated to container needs!

## run container

### pull

```bash
docker pull mplx/docker-webvirtcloud
```

### docker cli
```bash    
docker run -d \
    -p 80:80 \
    -p 6080:6080 \
    -v /srv/webvirtcloud/data:/srv/webvirtcloud/data \
    -v /srv/webvirtcloud/ssh:/var/www/.ssh \
    --name webvirtcloud \
    mplx/docker-webvirtcloud:latest
```

### docker compose
```yml
version: '2'
services:
  webvirtcloud:
    image: mplx/docker-webvirtcloud
    ports:
      - "80:80"
      - "6080:6080"
    volumes:
      - /srv/webvirtcloud/data:/srv/webvirtcloud/data
      - /srv/webvirtcloud/ssh:/var/www/.ssh
```
