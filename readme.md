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

## strict host checking

Before adding a kvm target system ("Computes" > "SSH Connection") you have to add the public key to the target system and establish a test connection so the host key is added to `known_hosts` file. Failing to do so will result in error `Host key verification failed`.

```bash
docker exec -i -t <container> /sbin/setuser www-data ssh <user>@<fqdn>
```

If you don't care about strict host checking you might disable it by adding these settings to file `config` in your ssh target volume instead:

```
StrictHostKeyChecking=no
UserKnownHostsFile=/dev/null 
```
