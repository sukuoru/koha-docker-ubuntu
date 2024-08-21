#!/bin/bash
# Stop on errors
set -e

#Run cron daemon
/usr/sbin/cron &

echo "*** Fixing locale error"

echo "LC_ALL=en_US.UTF-8" >> /etc/environment
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "*** Modifying /etc/mysql/koha-common.cnf and /etc/koha/sites/library/koha-conf.xml"

sed -i -e "s/_DB_HOST_/$DB_HOST/g" /etc/mysql/koha-common.cnf
sed -i -e "s/_MYSQL_PASSWORD_/$MYSQL_PASSWORD/g" /etc/mysql/koha-common.cnf
sed -i -e "s/_DB_PORT_/$DB_PORT/g" /etc/mysql/koha-common.cnf
sed -i -e "s/_MYSQL_USER_/$MYSQL_USER/g" /etc/mysql/koha-common.cnf
sed -i -e "s+_TIMEZONE_+$TIMEZONE+g" /etc/koha/sites/library/koha-conf.xml


echo "Checking if MariaDB is alive..."
while ! mysqladmin ping -h"$DB_HOST" --silent; do
    echo "*** Database server still down. Waiting $SLEEP seconds until retry"
    sleep $SLEEP
done

echo "Setting MEMCACHED choice..."
if [ ! -z "$NO_MEMCACHED"  ] && [ "$NO_MEMCACHED" == "true" ];then
    sed -i -e 's/USE_MEMCACHED="yes"/USE_MEMCACHED="no"/g' /etc/koha/koha-sites.conf
    sed -i -e 's/MEMCACHED_SERVERS=.*/MEMCACHED_SERVERS=""/g' /etc/koha/koha-sites.conf
else
    echo 'Starting memcache...'
    memcached -u memcache -d
fi

echo "*** Fixing rabbitmq"
rabbitmq-server start -detached
sleep $SLEEP
rabbitmqctl start_app
rabbitmqctl add_user koha koha
rabbitmqctl set_user_tags koha administrator
rabbitmqctl set_permissions -p / koha ".*" ".*" ".*"

#check for db, if nonexistent then create it
# Grep exits with 1 when not found
koha_db_present=$(mysql -h $DB_HOST -u root -p$DB_ROOT_PASSWORD -e "show databases;" | grep koha_library || true)
if [ "$koha_db_present" == "" ];then
    echo "Creating koha library..."
    koha-create --create-db library
fi

echo "***Fixing db permissions..."
mysql -h $DB_HOST -u root -p${DB_ROOT_PASSWORD} -e "grant all on koha_$LIBRARY_NAME.* to 'koha_$LIBRARY_NAME'@'%' IDENTIFIED BY 'random';"
mysql -h $DB_HOST -u root -p${DB_ROOT_PASSWORD} -e "flush privileges;"

echo "*** Setting lockdir..."
mkdir /var/lock/koha/library
chown library-koha:library-koha /var/lock/koha/library

    if [ ! -z "$INSTALL_LANG" ];then
        # Ignore the memcached error
	echo "Creating translations...."
        koha-translate --install $INSTALL_LANG || true
    fi

echo "Finished! Browse to your Koha instance!"

/usr/sbin/apachectl  -D FOREGROUND -k start
