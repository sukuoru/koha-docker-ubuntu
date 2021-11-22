#!/bin/bash

echo "Current details for koha:"
echo "Username: koha_library"
echo -n "Password: "
xmlstarlet sel -t -v 'yazgfs/config/pass' /etc/koha/sites/library/koha-conf.xml;echo
