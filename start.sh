# starting services

/sbin/service mysqld start
/sbin/service httpd start
/sbin/service nagios start

# welcome everyone

cat <<-EOF

	Welcome to Nagios XI

	You can access the Nagios XI web interface by visiting:
	    http://your_ip/nagiosxi/

EOF

