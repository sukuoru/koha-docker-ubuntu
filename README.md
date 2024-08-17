# koha-docker-ubuntu
This is an attempt to make a koha docker image for those who don't want to install gazillions of perl modules in their servers.

Start the container by:

*  git clone https://github.com/sukuoru/koha-docker-ubuntu
*  cd koha-docker-ubuntu
*  docker compose up
*  after permission error:
*  sudo chown 101:101 -R local

You will get an error from the container, regarding permissions for mariadb. That is when you need to run the chown at the bottom.

Get get the UI password

* docker exec -ti koha /opt/getpassword.sh

IMPORTANT: Do not forget to chown 101:101 MYLOCALDIR
