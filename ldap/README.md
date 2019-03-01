#  LDAP

## The ldap Dockerfile

	FROM ubuntu:18.04
  
	RUN apt-get update
	RUN apt-get install -y dialog apt-utils

	RUN echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections

	RUN apt-get install -y \
   		slapd \
    	ldap-utils \
    	vim
    	
	ENTRYPOINT ["/var/lib/ldap/slapd.sh"]
	
	
## The slapd.sh file

	#!/bin/bash
	/etc/init.d/slapd start
	SLAP_PID=$(echo $$)

	while :
	do
		sleep 60;
		if [ ! -n "$SLAP_PID" -a -e /proc/$PID ]; then
			echo "LDAP process is dead"
			exit 1
		fi 
	done


## The docker run command:

`docker run -d -p 389:389 -v /opt/LDAP/etc/ldap:/etc/ldap -v /opt/LDAP/ldap:/var/lib/ldap -ti navionics/ldap:latest`


## Disaster recovery (and install)

In a LDAP Container follow these steps:

`dpkg-reconfigure slapd`

This will open a screen with steps options to configure the ldap server.



	- "Omit OpenLDAP server configuration": No
	
	- DNS domain name: example.com
	- Organization name: example
	
	- Administrator password: type one and repeat it
	(this will be the admin pass that should be provided for handling the ldap and is not part of the organization)
	
	- Database backend to use: MDB (the last and default option)
	
	- Do you want the database to be removed when slapd is purged?: No
	- There are still files in /var/lib/ldap... Move old database?: Yes


After that, the ldap will refuse to restart, should be killed and started.

At this point, a backup ldif starting from the branch after the company can be loaded.

**This method is not really and efficient backup way if the LDAP is too big, but works ok for our current size, yet files for the docker container should be keept as well**

### To load an LDIF:

`ldapadd -H ldap://ldaphost.example.com -w ADMIN_PASS -x -D "cn=admin,dc=example,dc=com" 
 -f ldif_file.ldif`
 
 
### To dump an LDIF:

`ldapsearch -Wx -D "cn=admin,dc=example,dc=com" -b "dc=example,dc=com" -H ldap://ldaphost.example.com -LLL > ldif_file.ldif`

This will request the admin pass, and will dump the whole ldap as an ldif.