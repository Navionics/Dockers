FROM ubuntu:18.04
  
RUN apt-get update
RUN apt-get install -y dialog apt-utils

RUN echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections

RUN apt-get install -y \
    slapd \
    ldap-utils \
    vim

ENTRYPOINT ["/var/lib/ldap/slapd.sh"]
