#!/bin/bash
MARIADB_REPL_PASSWORD=`cat $MARIADB_REPLICATION_PASSWORD_FILE`
#MARIADB_REPLICATION_USER
MARIADB_PASSWORD=`cat $MARIADB_PASSWORD_FILE`
#MARIADB_USER
#SERVER1
#SERVER2
#SERVER3
#we can add new servers by adding before \[serverX\]
#  \[server3\]\ntype=server\nport=3306\naddress=$SERVER3\nssl_ca=/run/secrets/ca\nssl_cert=/run/secrets/server-cert-2\nssl_key=/run/secrets/server-key-2\nssl=true\n
TEMPCNF=$(sed -e "s/address=127.0.0.1/address=$SERVER1/;
s/# proxy_protocol=true/proxy_protocol=true/g;
s/port=4006/port=3306/g;
s/user=monitor_user/user=$MARIADB_REPLICATION_USER/g;
s/password=monitor_pw/password=$MARIADB_REPL_PASSWORD/g;
s/# auto_rejoin=true/auto_rejoin=true/g;
s/# cooperative_monitoring_locks=majority_of_all/cooperative_monitoring_locks=majority_of_running/g;
s/# replication_user=<username used for replication>/replication_user=$MARIADB_REPLICATION_USER/g;
s/# replication_password=<password used for replication>/replication_password=$MARIADB_REPL_PASSWORD/g;
s/user=service_user/user=$MARIADB_USER/g;
s/password=service_pw/password=$MARIADB_PASSWORD/g;
s/servers=server1/servers=server1,server2,server3/g;
/\[server1\]/i\[server3\]\ntype=server\nport=3306\naddress=$SERVER3\nssl_ca=/run/secrets/ca\nssl_cert=/run/secrets/server-cert-2\nssl_key=/run/secrets/server-key-2\nssl=true\n\[server2\]\ntype=server\nport=3306\naddress=$SERVER2\nssl_ca=/run/secrets/ca\nssl_cert=/run/secrets/server-cert\nssl_key=/run/secrets/server-key\nssl=true
/\[maxscale\]/aadmin_secure_gui=false\nadmin_host=0.0.0.0
/\[Read-Write-Listener\]/aproxy_protocol_networks=*
/\[Read-Write-Service\]/aenable_root_user=true" /etc/maxscale.cnf)
echo "$TEMPCNF" > /etc/maxscale.cnf
unset TEMPCNF
exec $@
