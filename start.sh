#!/bin/bash
/usr/sbin/init

# starting services

/sbin/service mysqld start
/sbin/service httpd start
/sbin/service ajaxterm start
/sbin/service crond start
/sbin/service xinetd start
/sbin/service ndo2db start
/sbin/service npcd start
/sbin/service nagios start
/sbin/service rsyslog start

#repair database to ensure consistency

/usr/local/nagiosxi/scripts/repair_databases.sh

/sbin/service crond restart

# welcome everyone

cat <<-EOF

	Welcome to Nagios XI

	You can access the Nagios XI web interface by visiting:
	    http://your_ip/nagiosxi/

EOF

# We need to know what the API key is for CI tests
echo "UPDATE nagiosxi.xi_users SET api_key='APIkey123456' WHERE username='nagiosadmin';" | mysql -u root -pnagiosxi

tail -F /usr/local/nagios/var/nagios.log

