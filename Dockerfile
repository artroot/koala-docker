FROM debian:latest

MAINTAINER Arem Semenishch <art90com@gmail.com>

ENV DEBIAN_FRONTEND noninteractive 

RUN     apt-get -y update

RUN apt-get install -y wget git zip unzip curl apache2 php7.0 php7.0-curl libapache2-mod-php7.0 php7.0-cli php-cli-prompt php-composer-semver php-composer-spdx-licenses php7.0-xml php7.0-common php7.0-mbstring php7.0-gd php7.0-intl php7.0-json php7.0-mysql php7.0-mcrypt php7.0-zip composer supervisor

RUN apt-get install -y mysql-server mysql-client mysql-common

RUN cd /var/www/ && git clone https://github.com/artroot/koala.git 
RUN cd /var/www/koala && composer install

RUN mkdir /var/www/koala/runtime/cache
RUN chmod -R 777 /var/www/koala/web/assets
RUN chmod -R 777 /var/www/koala/runtime
RUN chmod -R +rw /var/www/koala/assets

RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

RUN rm /etc/apache2/sites-enabled/000-default.conf
ADD koala.conf /etc/apache2/sites-enabled/koala.conf

ADD database-setup.sh /tmp/database-setup.sh
RUN chmod 755 /tmp/database-setup.sh

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf 

EXPOSE 80

RUN /tmp/database-setup.sh
RUN rm /tmp/database-setup.sh

CMD ["/usr/bin/supervisord"]
