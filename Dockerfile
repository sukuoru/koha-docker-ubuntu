FROM debian:bullseye
MAINTAINER Aldemir Akpinar <aldemir.akpinar@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive
RUN sed -i -e's/ main/ main contrib non-free/g' /etc/apt/sources.list

RUN apt-get update && apt-get install -y tzdata mariadb-client gnupg curl mariadb-server memcached

RUN echo "deb http://debian.koha-community.org/koha stable main" | tee -a  /etc/apt/sources.list

RUN curl https://debian.koha-community.org/koha/gpg.asc | apt-key add -

RUN apt-get update && apt-get install -y koha-common && apt-get clean

RUN sed -i -e 's/DOMAIN=.*/DOMAIN=".mydomain.org"/g' /etc/koha/koha-sites.conf
RUN sed -i -e 's/INTRASUFFIX=.*/INTRASUFFIX="-admin"/g' /etc/koha/koha-sites.conf
RUN sed -i -e 's/OPACSUFFIX=.*/OPACSUFFIX="-opac"/g' /etc/koha/koha-sites.conf
RUN sed -i -e 's/INTRAPORT="80"/INTRAPORT="8080"/g' /etc/koha/koha-sites.conf
RUN sed -i -e 's/OPACPORT=.*/OPACPORT="8081"/g' /etc/koha/koha-sites.conf

RUN echo "LISTEN 8080" >> /etc/apache2/ports.conf && echo "LISTEN 8081" >> /etc/apache2/ports.conf

RUN a2enmod rewrite && a2enmod cgi && a2enmod deflate

COPY entrypoint.sh /opt/
COPY getpassword.sh /opt/
ENTRYPOINT /opt/entrypoint.sh
