#!/bin/bash

# fix database permissions
echo "Fixing permissions..."
chown -R www-data:www-data /srv/webvirtcloud/data/

# disabling django debug
echo "Disable debug mode..."
sed -i 's/DEBUG = True/DEBUG = False/' /srv/webvirtcloud/webvirtcloud/settings.py

# generate and set secret key if empty
echo "Secret key..."
SECRETKEY=$(cat /proc/sys/kernel/random/uuid)
sed -i "s/SECRET_KEY = ''/SECRET_KEY = '$SECRETKEY'/" /srv/webvirtcloud/webvirtcloud/settings.py

# execute migrations
echo "Executing migrations..."
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
	echo "Setting public port..."
	sed -r -i "s/(\\s*listen )[0-9]+;/\\1${PUBLIC_PORT};/" /etc/nginx/conf.d/webvirtcloud.conf
	[ -n "$VNC_PORT" ] || VNC_PORT=$PUBLIC_PORT
fi

# set vnc host
echo "Setting VNC external host..."
if [ -n "$VNC_HOST" ]; then
	sed -i "s/WS_PUBLIC_HOST = None/WS_PUBLIC_HOST = '$VNC_HOST'/" /srv/webvirtcloud/webvirtcloud/settings.py
fi

# set vnc port
echo "Setting VNC port..."
if [ -n "$VNC_PORT" ]; then
	sed -i "s/WS_PUBLIC_PORT = [0-9]\+/WS_PUBLIC_PORT = $VNC_PORT/" /srv/webvirtcloud/webvirtcloud/settings.py
else
	sed -i 's/WS_PUBLIC_PORT = [0-9]\+/WS_PUBLIC_PORT = 80/' /srv/webvirtcloud/webvirtcloud/settings.py
fi

# fix ssh permissions
echo "Fixing ssh permissions..."
chown -R www-data:www-data /var/www/.ssh/
chmod 0700 /var/www/.ssh
chmod 0600 /var/www/.ssh/*
