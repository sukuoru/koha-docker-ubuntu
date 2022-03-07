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

# Koha-create doesn't have to do everything all by itself!
RUN sed -i -e 's/die "User/echo/' /usr/sbin/koha-create
RUN sed -i -e 's/die "Group/echo/' /usr/sbin/koha-create
RUN sed -i -e '/if getent.*/,+3d' /usr/sbin/koha-create
RUN sed -i -e '/adduser.*/,+3d' /usr/sbin/koha-create
RUN sed -i -e '/generate_config_file $APACHE_CONFIGFILE/,+1d' /usr/sbin/koha-create
RUN sed -i -e '/# Reconfigure Apache./,+7d' /usr/sbin/koha-create

RUN echo "LISTEN 8080" >> /etc/apache2/ports.conf && echo "LISTEN 8081" >> /etc/apache2/ports.conf

RUN a2enmod rewrite && a2enmod cgi && a2enmod deflate

COPY entrypoint.sh /opt/
COPY getpassword.sh /opt/

# Deb post install creates the db files
RUN rm -rf /var/lib/mysql/*
# Create a directory to store stateful files
COPY library.conf /etc/apache2/sites-available
RUN ln -s /etc/apache2/sites-available/library.conf /etc/apache2/sites-enabled/library.conf

# Create koha user manualy and only during docker build
RUN adduser --no-create-home --disabled-login \
        --gecos "Koha instance library-koha" \
        --home /var/lib/koha/library \
        --quiet library-koha

ENTRYPOINT /opt/entrypoint.sh
