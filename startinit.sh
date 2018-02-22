#!/bin/bash

# fix database permissions
chown -R www-data:www-data /srv/webvirtcloud/data/

# execute migrations
/sbin/setuser www-data /srv/webvirtcloud/venv/bin/python /srv/webvirtcloud/manage.py migrate

# generate ssh keys if necessary
if [ ! -f /var/www/.ssh/id_rsa ]; then
	mkdir -p /var/www/.ssh/
	ssh-keygen -b 4096 -t rsa -C webvirtcloud -N '' -f /var/www/.ssh/id_rsa
fi
echo ""
echo "Your WebVirtCloud public key:"
cat /var/www/.ssh/id_rsa.pub
echo ""

# set public port
if [ -n "$PUBLIC_PORT" ]; then
	sed -r -i "s/(\\s*listen )[0-9]+;/\\1${PUBLIC_PORT};/" /etc/nginx/conf.d/webvirtcloud.conf

	[ -n "$VNC_PORT" ] || VNC_PORT=$PUBLIC_PORT
fi

# set vnc port
if [ -n "$VNC_PORT" ]; then
	sed -i "s/WS_PUBLIC_PORT = [0-9]\+/WS_PUBLIC_PORT = $VNC_PORT/" /srv/webvirtcloud/webvirtcloud/settings.py
else
	sed -i 's/WS_PUBLIC_PORT = [0-9]\+/WS_PUBLIC_PORT = 80/' /srv/webvirtcloud/webvirtcloud/settings.py
fi

# fix ssh permissions
chown -R www-data:www-data /var/www/.ssh/
chmod 0700 /var/www/.ssh
chmod 0600 /var/www/.ssh/*
