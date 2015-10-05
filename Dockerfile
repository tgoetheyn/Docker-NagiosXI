FROM centos:6 
MAINTAINER tgoetheyn

# get stuff from the interwebs
RUN yum -y install wget tar; yum clean all
WORKDIR /tmp
RUN wget http://assets.nagios.com/downloads/nagiosxi/xi-latest.tar.gz
RUN tar xzf xi-latest.tar.gz
WORKDIR nagiosxi

# overwrite custom config file
ADD config.cfg xi-sys.cfg

# start building
RUN ./init.sh && . ./xi-sys.cfg && umask 0022 && . ./functions.sh && log="install.log"
RUN export INTERACTIVE="False" && export INSTALL_PATH=`pwd`
RUN . ./functions.sh && run_sub ./0-repos noupdate
RUN . ./functions.sh && run_sub ./1-prereqs
RUN . ./functions.sh && run_sub ./2-usersgroups
RUN . ./functions.sh && run_sub ./3-dbservers
RUN . ./functions.sh && run_sub ./4-services
RUN . ./functions.sh && run_sub ./5-sudoers
RUN sed -i.bak s/selinux/sudoers/g 9-dbbackups
RUN . ./functions.sh && run_sub ./9-dbbackups
RUN . ./functions.sh && run_sub ./10-phplimits
RUN . ./functions.sh && run_sub ./11-sourceguardian
RUN . ./functions.sh && run_sub ./12-mrtg
RUN . ./functions.sh && run_sub ./13-cacti
RUN . ./functions.sh && run_sub ./14-timezone

ADD scripts/NDOUTILS-POST subcomponents/ndoutils/post-install
RUN chmod 755 subcomponents/ndoutils/post-install && . ./functions.sh && run_sub ./A-subcomponents
RUN service mysqld start && . ./functions.sh && run_sub ./B-installxi
RUN . ./functions.sh && run_sub ./C-cronjobs
RUN . ./functions.sh && run_sub ./D-chkconfigalldaemons
RUN service mysqld start && . ./functions.sh && run_sub ./E-importnagiosql
RUN . ./functions.sh && run_sub ./F-startdaemons
RUN . ./functions.sh && run_sub ./Z-webroot

# set startup script
ADD start.sh /start.sh
RUN chmod 755 /start.sh
EXPOSE 80 5666 5667

CMD ["/start.sh"]
