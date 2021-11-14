#!/bin/bash
# Stop on errors
set -e

mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

#Run cron daemon
/usr/sbin/cron &

if [ ! -z "$LOCAL_MYSQL" ] && [ "$LOCAL_MYSQL" == "true" ];then
    su - mysql -s /bin/bash -c "/usr/sbin/mysqld --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib/x86_64-linux-gnu/mariadb19/plugin --user=mysql --skip-log-error --pid-file=/run/mysqld/mysqld.pid --socket=/var/run/mysqld/mysqld.sock" &
fi

koha-create --create-db library

/usr/sbin/apachectl  -D FOREGROUND -k start
