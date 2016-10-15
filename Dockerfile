# docker build -t mplx/webvirtcloud .
FROM phusion/baseimage:0.9.19

MAINTAINER geki007
MAINTAINER mplx

EXPOSE 80
EXPOSE 6080

CMD ["/sbin/my_init"]

RUN apt-get update -qqy && \
    DEBIAN_FRONTEND=noninteractive apt-get -qyy install \
    -o APT::Install-Suggests=false \
    python-virtualenv \
    python-dev \
    libxml2-dev \
    libvirt-dev \
    zlib1g-dev \
    nginx \
    supervisor \
    libsasl2-modules \
    unzip \
    curl && \
    mkdir -p /srv

WORKDIR /srv

ENV COMMITID=aa2a996e3f765ee0a3c593026d7b674f15ec9086

RUN curl -L -o $COMMITID.zip https://github.com/retspen/webvirtcloud/archive/$COMMITID.zip && \
    unzip $COMMITID.zip && \
    rm -f $COMMITID.zip && \
    mv webvirtcloud-$COMMITID webvirtcloud && \
    cp webvirtcloud/conf/supervisor/webvirtcloud.conf /etc/supervisor/conf.d && \
    cp webvirtcloud/conf/nginx/webvirtcloud.conf /etc/nginx/conf.d && \
    chown -R www-data:www-data /srv/webvirtcloud/ && \
    cd /srv/webvirtcloud/ && \
    mkdir data && \
    sed -i "s|'db.sqlite3'|'data/db.sqlite3'|" webvirtcloud/settings.py && \
    virtualenv venv && \
    . venv/bin/activate && \
    venv/bin/pip install -r conf/requirements.txt && \
    chown -R www-data:www-data /srv/webvirtcloud/ && \
    rm /etc/nginx/sites-enabled/default && \
    echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
    chown -R www-data:www-data /var/lib/nginx && \
    mkdir /etc/service/nginx && \
    mkdir /etc/service/nginx-log-forwarder && \
    mkdir /etc/service/webvirtcloud && \
    mkdir /etc/service/novnc && \
    cp conf/runit/nginx /etc/service/nginx/run && \
    cp conf/runit/nginx-log-forwarder /etc/service/nginx-log-forwarder/run && \
    cp conf/runit/novncd.sh /etc/service/novnc/run && \
    cp conf/runit/webvirtcloud.sh /etc/service/webvirtcloud/run && \
    sed -i '/cd \/srv\/webvirtcloud/a /bin/bash /srv/startinit.sh' /etc/service/webvirtcloud/run && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY startinit.sh /srv/startinit.sh
