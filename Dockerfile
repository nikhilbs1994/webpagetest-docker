# FROM debian:jessie-slim
FROM ubuntu

RUN apt-get update && \
  apt-get install -y \
    wget \
    curl \
    python \
    python-pip \
    xvfb \
    imagemagick \
    python-dev \
    zlib1g-dev \
    libjpeg-dev \
    psmisc \
    dbus-x11 \
    sudo \
    kmod \
    ffmpeg \
    net-tools \
    tcpdump \
    traceroute \
    bind9utils \
    software-properties-common 
#    python-software-properties

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  wget -qO- https://deb.opera.com/archive.key | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list


RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    google-chrome-stable \
    google-chrome-beta \
    google-chrome-unstable \
    nodejs

RUN npm install -g lighthouse

RUN pip install \
    dnspython \
    monotonic \
    pillow \
    psutil \
    requests \
    ujson \
    tornado \
    xvfbwrapper \
    marionette_driver

RUN apt-get install -y \
    iproute2

COPY wptagent.py /wptagent/wptagent.py
COPY internal /wptagent/internal
COPY ws4py /wptagent/ws4py

WORKDIR /wptagent

RUN apt-get -y install \    
    apache2

ENV TZ=Asia
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get -y install \
    zip \
    php-fpm \
    php-cli \
    php-xml \
    php-apcu \
    php-gd \
    php-zip \
    php-mbstring \
    php-curl \
    php-sqlite3 

RUN apt-get -y install \    
    beanstalkd \
    libjpeg-turbo-progs \
    libimage-exiftool-perl \
    python-setuptools \
    build-essential \
    python-numpy \
    python-scipy

RUN pip install \
    pyssim

RUN apt-get -y install \    
    nginx

COPY config/php.ini /usr/local/etc/php/
COPY webpagetest/ /var/www/webpagetest/
COPY nginx/sites-available/ /etc/nginx/sites-available/

RUN chmod 777 -R /var/www/webpagetest/tmp/ \
    /var/www/webpagetest/dat/ \
    /var/www/webpagetest/results/ \
    /var/www/webpagetest/work/ \
    /var/www/webpagetest/logs/

RUN sudo echo '# Limits increased for wptagent' | sudo tee -a /etc/security/limits.conf \
    echo '* soft nofile 250000' | sudo tee -a /etc/security/limits.conf \
    echo '* hard nofile 300000' | sudo tee -a /etc/security/limits.conf \
    echo '# wptagent end' | sudo tee -a /etc/security/limits.conf \
    echo '# Settings updated for wptagent' | sudo tee -a /etc/sysctl.conf \
    echo 'net.ipv4.tcp_syn_retries = 4' | sudo tee -a /etc/sysctl.conf \
    echo '# wptagent end' | sudo tee -a /etc/sysctl.conf \
    sudo sysctl -p

RUN export $(dbus-launch)

EXPOSE 80
EXPOSE 99

COPY apache/sites-available/ /etc/apache2/sites-available/

COPY docker/linux-headless/entrypoint.sh /wptagent/entrypoint.sh
COPY browsers.ini /wptagent/browsers.ini


CMD ["/bin/bash", "/wptagent/entrypoint.sh"]
