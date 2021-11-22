# koha-docker
This is an attempt to make a koha docker image for those who don't want to install gazillions of perl modules in their servers.

Start the container by:

* docker run -v MYLOCALDIR:/var/lib/mysql -p 8081:8081 -p 8080 -d --name koha ghcr.io/aldemira/koha-docker:main

Get get the UI password

* docker exec -ti koha /opt/getpassword.sh
