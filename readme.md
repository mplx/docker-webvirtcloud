# WebVirtCloud on Docker

retspen's WebVirtCloud is a web interface to Linux KVM virtualization and can be found on [github](https://github.com/retspen/webvirtcloud).

## [Docker Hub](https://hub.docker.com/r/mplx/docker-webvirtcloud/) Version Tag

Tag                                                                           | Description
----------------------------------------------------------------------------- | -----------
[x.y.z](https://github.com/mplx/docker-webvirtcloud/blob/master/CHANGELOG.md) | images matching git tags; semantic versioning
latest                                                                        | build with latest semver tag
master                                                                        | build from latest commit in master branch

## Persistent Data

To get persistent data (database, ssh key) you need to mount container side directories `/srv/webvirtcloud/data` and `/var/www/.ssh` (i.e. `-v /srv/webvirtcloud/data:/srv/webvirtcloud/data`).

- an existing database (`db.sqlite3`) will be used and upgraded by webvirtcloud's migrations
- an existing ssh key will be used otherwise one will be created (4096 bit RSA)
- warning: do not mount your ~/.ssh as key source - permissions will be updated to container needs!

## Run Container

### pull/update

```bash
docker pull mplx/docker-webvirtcloud:latest
```

### docker cli

```bash    
docker run -d \
    -p 80:80 \
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
    volumes:
      - /srv/webvirtcloud/data:/srv/webvirtcloud/data
      - /srv/webvirtcloud/ssh:/var/www/.ssh
```

## Strict Host Checking

Before adding a KVM target system ("Computes" > "SSH Connection") you have to add the public key to the target system and establish a test connection so the host key is added to `known_hosts` file. Failing to do so will result in error `Host key verification failed`.

```bash
docker exec -i -t <container> /sbin/setuser www-data ssh <user>@<fqdn>
```

If you don't care about strict host checking you might disable it by adding these settings to file `config` in your ssh target volume instead:

```
StrictHostKeyChecking=no
UserKnownHostsFile=/dev/null
```

## Public Port `PUBLIC_PORT`

nginx uses port 80 by default. If you require another port you can change this via `PUBLIC_PORT` (e.g. `docker run ... -e PUBLIC_PORT=443 ...`). Webvirtcloud uses `PUBLIC_PORT` for redirections (e.g. to login page) therefore it should be set when the web UI is accessed via a port other than 80 or 443.

## novncd `VNC_HOST`, `VNC_PORT`

External websocket host (`VNC_HOST`) and/or port (`VNC_PORT`) to proxy websocket connects for vnc/spice. Port defaults to port 80 (or `PUBLIC_PORT` if set). If you require another host/port (i.e. you're using webvirtcloud behind a SSL proxy ) you'll have to set up the appropiate host and/or port (`docker run ... -e VNC_PORT=443 ...`).

## Proxy

webvirtcloud is fully operational behind a proxy.

i.e. `jwilder/nginx-proxy` with `jrcs/letsencrypt-nginx-proxy-companion`:

```bash
...
    environment:
      - VNC_HOST=external-host.domain.tld
      - VNC_PORT=443
      - VIRTUAL_HOST=webvirtcloud.domain.tld
      - VIRTUAL_PORT=80
      - LETSENCRYPT_HOST=webvirtcloud.domain.tld
      - LETSENCRYPT_EMAIL=some@email.tld
...
```

## Contributing Guidelines

Contributions welcome! When submitting your first pull request please add your _author email_ (the one you use to make commits) to the [contributors](CONTRIBUTORS) file which contains a Contributor License Agreement (CLA).

## License

Licensed under [MIT License](LICENSE).
