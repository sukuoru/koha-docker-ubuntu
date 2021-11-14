FROM debian:bullseye
MAINTAINER Aldemir Akpinar <aldemir.akpinar@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive
RUN sed -i -e's/ main/ main contrib non-free/g' /etc/apt/sources.list

RUN apt-get update && apt-get install -y tzdata mariadb-client gnupg curl mariadb-server

RUN echo "deb http://debian.koha-community.org/koha stable main" | tee -a  /etc/apt/sources.list

RUN curl https://debian.koha-community.org/koha/gpg.asc | apt-key add -

RUN apt-get update && apt-get install -y koha-common

#RUN sed -i -e 's/USE_MEMCACHED="yes"/USE_MEMCACHED="no"/g' /etc/koha/koha-sites.conf

# Ignore the memcached error
RUN koha-translate --install tr-TR || true

RUN a2enmod rewrite && a2enmod cgi && a2enmod deflate

COPY entrypoint.sh /opt/
ENTRYPOINT /opt/entrypoint.sh
