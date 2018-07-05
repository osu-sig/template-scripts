#!/bin/bash

# stop logging services
/sbin/service rsyslog stop
/sbin/service auditd stop

# tear down networking
for IFCFG in $(find /etc/sysconfig/network-scripts -name 'ifcfg-eth*')
do
  FILENAME=`basename $IFCFG`
  DEVICE=${FILENAME#*-}
  /bin/cat > $IFCFG << EOF
# Make sure to set ONBOOT=yes
# $DEVICE
DEVICE=$DEVICE
ONBOOT=no
IPADDR=
NETMASK=255.255.
GATEWAY=
DNS=128.193.15.12
DNS2=128.193.15.13
TYPE=Ethernet
EOF
done
/bin/cat /dev/null > /etc/hostname

# remove old kernels
/bin/package-cleanup -y --oldkernels --count=1

# clean yum cache
/bin/yum clean all
/bin/rm -rf /var/cache/yum

# clean logs
/usr/sbin/logrotate -f /etc/logrotate.conf
/bin/rm -f /var/log/*-???????? /var/log/*.gz
/bin/rm -f /var/log/dmesg.old
/bin/rm -rf /var/log/anaconda
/bin/cat /dev/null > /var/log/audit/audit.log
/bin/cat /dev/null > /var/log/wtmp
/bin/cat /dev/null > /var/log/lastlog
/bin/cat /dev/null > /var/log/grubby

# clean tmp
/bin/rm -rf /tmp/*
/bin/rm -rf /var/tmp/*

# remove udev rules
/bin/rm -f /etc/udev/rules.d/70*

# remove ssh host keys
/bin/rm -f /etc/ssh/*key*

# remove root's shell history
/bin/rm -f ~root/.bash_history
unset HISTFILE

# remove root's ssh history
/bin/rm -rf ~root/.ssh/
/bin/rm -f ~root/anaconda-ks.cfg

# remove root's password
passwd -d root

# remind user of final steps
echo $'\n\n\n'
echo "Delete this script and run:"
echo "history -cw"
echo "init 0"
