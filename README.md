# koha-docker-ubuntu
This is an attempt to make a koha docker image for those who don't want to install gazillions of perl modules in their servers.

Start the container by:

* docker compose up

You will get an error from the container, regarding permissions for mariadb. That is when you need to run the chown at the bottom.

Get get the UI password

* docker exec -ti koha /opt/getpassword.sh

IMPORTANT: Do not forget to chown 101:101 MYLOCALDIR
