#!/bin/bash
# Stop on errors
set -e

mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

#Run cron daemon
/usr/sbin/cron &

if [ ! -z "$REMOTE_DB" ] && [ "$REMOTE_DB" == "true" ];then
    echo
else
    su - mysql -s /bin/bash -c "/usr/sbin/mysqld --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib/x86_64-linux-gnu/mariadb19/plugin --user=mysql --skip-log-error --pid-file=/run/mysqld/mysqld.pid --socket=/var/run/mysqld/mysqld.sock" &
fi

# Wait for mysql to start
sleep 5

#if [ ! -z "$MYSQL_HOST"] &&
#    [ ! -z "$MYSQL_USER" ] &&
#    [ ! -z "$MYSQL_PASS" ] &&
#    [ ! -z "$MYSQL_ADMIN_PASS"] &&
#    [ ! -z "$MYSQL_PORT" ];then
#    sed -i -e "s///g" /etc/koha/koha-sites.conf
#fi

if [ ! -z "$NO_MEMCACHED"  ] && [ "$NO_MEMCACHED" == "true" ];then
    sed -i -e 's/USE_MEMCACHED="yes"/USE_MEMCACHED="no"/g' /etc/koha/koha-sites.conf
    sed -i -e 's/MEMCACHED_SERVERS=.*/MEMCACHED_SERVERS=""/g' /etc/koha/koha-sites.conf
else
    memcached -u memcache -d
fi

# Dockerize koha-create aka don't start apache from it
sed -i -e 's/service apache2 restart/#service apache2 restart/g' /usr/sbin/koha-create

koha-create --create-db library
# Ignore the memcached error
koha-translate --install tr-TR || true

sed -i -e 's|ErrorLog.*|ErrorLog /dev/stderr|g' /etc/apache2/sites-enabled/library.conf
/usr/sbin/apachectl  -D FOREGROUND -k start
