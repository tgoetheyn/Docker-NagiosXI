FROM centos:6 
MAINTAINER cbpeckles

# get stuff from the interwebs
RUN yum -y install wget tar; yum clean all
RUN mkdir /tmp/nagiosxi \
    && wget -qO- https://assets.nagios.com/downloads/nagiosxi/5/xi-5.4.13.tar.gz \
    | tar xz -C /tmp
WORKDIR /tmp/nagiosxi

# overwrite custom config file
ADD config.cfg xi-sys.cfg

# start building
RUN ./init.sh \
    && . ./xi-sys.cfg \
	&& umask 0022 \
	&& . ./functions.sh \
	&& log="install.log"
RUN export INTERACTIVE="False" \
    && export INSTALL_PATH=`pwd`
RUN . ./functions.sh \
    && run_sub ./0-repos noupdate
RUN . ./functions.sh \
    && run_sub ./1-prereqs
RUN . ./functions.sh \
    && run_sub ./2-usersgroups
RUN . ./functions.sh \
    && run_sub ./3-dbservers
RUN . ./functions.sh \
    && run_sub ./4-services
RUN . ./functions.sh \
    && run_sub ./5-sudoers
RUN sed -i.bak s/selinux/sudoers/g 9-dbbackups
RUN . ./functions.sh \
    && run_sub ./9-dbbackups
RUN . ./functions.sh \
    && run_sub ./10-phplimits
RUN . ./functions.sh \
    && run_sub ./11-sourceguardian
RUN . ./functions.sh \
    && run_sub ./12-mrtg
RUN . ./functions.sh \
    && run_sub ./13-timezone

ADD scripts/NDOUTILS-POST subcomponents/ndoutils/post-install
ADD scripts/install subcomponents/ndoutils/install
RUN chmod 755 subcomponents/ndoutils/post-install \
    && chmod 755 subcomponents/ndoutils/install \
	&& . ./functions.sh \
	&& run_sub ./A-subcomponents
RUN service mysqld start \
    && . ./functions.sh \
	&& run_sub ./B-installxi
RUN . ./functions.sh \
    && run_sub ./C-cronjobs
RUN . ./functions.sh \
    && run_sub ./D-chkconfigalldaemons
RUN service mysqld start \
    && . ./functions.sh \
	&& run_sub ./E-importnagiosql
RUN . ./functions.sh \
    && run_sub ./F-startdaemons
RUN . ./functions.sh \
    && run_sub ./Z-webroot

RUN yum clean all

RUN mkdir /data
RUN mkdir /data/perfdata
RUN mkdir /data/mysql
RUN ln -sf /data/perfdata /usr/local/nagios/share/perfdata

#RUN ln -sf /data/mysql /var/lib/mysql
#RUN service mysqld stop
RUN cp -rpf /var/lib/mysql /data/mysql
RUN mv /var/lib/mysql /var/lib/mysql.bak
RUN sed -i.bak 's|/var/lib/mysql|/data/mysql|' /etc/my.cnf
RUN sed -i.bak 's|/var/lib/mysql|/data/mysql|' /usr/local/nagiosxi/scripts/repairmysql.sh
RUN sed -i.bak 's|/var/lib/mysql|/data/mysql|' /usr/local/nagiosxi/scripts/repair_databases.sh
RUN echo [client] >> /etc/my.cnf
RUN echo port=3306 >> /etc/my.cnf
RUN echo socket=/data/mysql/mysql.sock >> /etc/my.cnf
RUN rm /var/lib/mysql.bak
#RUN service mysqld start

# set startup script
ADD start.sh /start.sh
RUN chmod 755 /start.sh
EXPOSE 80 5666 5667

CMD ["/start.sh"]
