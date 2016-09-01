#!/bin/bash

# fix database permissions
chown www-data:www-data /srv/webvirtcloud/data/

# execute migrations
/sbin/setuser www-data venv/bin/python manage.py migrate

# generate ssh keys if necessary
if [ ! -f /var/www/.ssh/id_rsa ]; then
	mkdir -p /var/www/.ssh/
	ssh-keygen -b 4096 -t rsa -C webvirtcloud -N '' -f /var/www/.ssh/id_rsa
fi
echo ""
echo "Your WebVirtCloud public key:"
cat /var/www/.ssh/id_rsa.pub
echo ""

# fix ssh permissions	
chown www-data:www-data /var/www/.ssh/
chmod 0700 /var/www/.ssh
chmod 0600 /var/www/.ssh/*
