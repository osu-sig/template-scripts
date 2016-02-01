#!/bin/bash
# Configure CentOS enough to run Ansible

setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# get list of ifaces
ip link list
IFACES=(`ip -o link list | cut -f2 -d' ' | sed -e 's/://'`)
echo "Enter interface number (not name) to configure"
read IFACE
# bash arrays are 0 indexed, list of ifaces is not
let IFACE-=1
IFACENAME=${IFACES[$IFACE]}

echo "IP address?"
read IPADDR
echo "Netmask?"
read NETMASK
echo "Gateway?"
read GATEWAY

echo "FQDN?"
read FQDN

# write it out
cat > /etc/sysconfig/network-scripts/ifcfg-$IFACENAME << EOF
# $IFACENAME
DEVICE=$IFACENAME
ONBOOT=yes
IPADDR=$IPADDR
NETMASK=$NETMASK
GATEWAY=$GATEWAY
DNS=128.193.15.12
DNS2=128.193.15.13
TYPE=Ethernet
EOF

cat > /etc/resolv.conf << EOF
nameserver 128.193.15.12
nameserver 128.193.15.13
EOF

SPLITNAME=(${FQDN//\./ })
SHORTNAME=${SPLITNAME[0]}

cat > /etc/hosts << EOF
127.0.0.1	localhost	$FQDN $SHORTNAME
::1	localhost	$FQDN   $SHORTNAME	localhost6
EOF

echo $SHORTNAME > /etc/hostname

# possible alternative to cat-ing above
#sed -i "s/^127\.0\.0\.1.*/127.0.0.1	localhost	$FQDN	$SHORTNAME/g" hosts

ifup $IFACENAME

mkdir /root/.ssh
chmod 0700 /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKNr5x9CttPmNd/sAOxWHfNvnGqDQR+ms110S277rZp1yqnZndh/NEJG2x63FJoCvXwebq+tRRY6zgvyhspIVNr4bfAaUzzm+0e69zcVCCHbzmt5YMZ2qJd+DT4QTRaJOy1FGvkfS9cd7sevmJfmx6EU49ebtgIqZWS9tFp1hB7LwyMDYTCYTYcICrSj1emGrkT6pyA6q/DdtDau7tIAP6SFD7oFPYlE8bswsySKkiI8DQ27QvaOtXLo4Pa/Fo0s10c+b9wJ/wf9PT7I1FnUpD6uxACuEYkino/pSEl3fg8o8dIogoAFWq682gXabQmSpHTQzgSID9dbFripv8as4T ansible@ansible-vd01.sig.oregonstate.edu" > /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys

echo "A reboot is suggested to ensure all settings take effect."
