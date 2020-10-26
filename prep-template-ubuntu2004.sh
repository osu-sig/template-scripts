#!/bin/bash
#
# based on:
# http://www.virtxpert.com/preparing-ubuntu-template-virtual-machines/

# apt-get install open-vm-tools python-minimal aptitude

systemctl stop rsyslog.service
systemctl  stop audit.service
apt purge cloud-init && sudo apt autoremove
rm -rf /etc/cloud
apt-get clean
logrotate -f /etc/logrotate.conf
find /var/log -name "*.gz" -type f -delete
find /var/log -name "*.1" -type f -delete
cat /dev/null > /var/log/audit/audit.log
cat /dev/null > /var/log/wtmp
cat /dev/null > /var/log/lastlog
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /etc/ssh/*key*
rm -rf ~/.ssh/authorized_keys
rm -rf /etc/netplan/00*
cat /dev/null > /etc/hostname

cat > /etc/hosts << EOF
127.0.0.1   localhost

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

chage -d 0 root
passwd -d root

echo "Delete this script and run:"
echo "history -c"
echo "history -w"
echo "poweroff"
