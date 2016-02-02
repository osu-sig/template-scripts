#!/bin/bash
#
# based on:
# http://www.virtxpert.com/preparing-ubuntu-template-virtual-machines/

service rsyslog stop
service auditd stop
apt-get clean
logrotate -f /etc/logrotate.conf
find /var/log -name "*.gz" -type f -delete
cat /dev/null > /var/log/audit/audit.log
cat /dev/null > /var/log/wtmp
cat /dev/null > /var/log/lastlog
rm -rf /tmp/*
rm -rf /var/tmp/*
rm –rf /etc/ssh/*key*
rm –rf ~/.ssh/authorized_keys
cat > /etc/network/interfaces << EOF
auto lo
iface lo inet loopback

#allow-hotplug eth0
#iface eth0 inet static
    #address 128.193.15.22
    #netmask 255.255.255.128
    #gateway 128.193.15.1
    # dns-* options are implemented by the resolvconf package, if installed
    #dns-nameservers 128.193.15.12 128.193.15.13
EOF

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

history -c
history -w
echo "Delete this script and then poweroff."
