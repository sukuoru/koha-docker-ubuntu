#!/bin/bash
# Stop on errors
set -e

mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

#Run cron daemon
/usr/sbin/cron &

if [ ! -z "$REMOTE_DB" ] && [ "$REMOTE_DB" == "true" ];then
    # TODO
    echo
else
    echo 'Starting mysql db...'
    if [ ! -d "/var/lib/mysql/mysql" ];then
        mysql_install_db
    fi
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
    echo 'Starting memcache...'
    memcached -u memcache -d
fi


# Grep exits with 1 when not found
koha_db_present=$(echo "show databases" | mysql | grep koha_library || true)
if [ "$koha_db_present" == "" ];then
    echo "Creating koha library..."
    koha-create --create-db library

    if [ ! -z "$INSTALL_LANG" ];then
        # Ignore the memcached error
	echo "Creating translations...."
        koha-translate --install $INSTALL_LANG || true
    fi
fi

/usr/sbin/apachectl  -D FOREGROUND -k start
