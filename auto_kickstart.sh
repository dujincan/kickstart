#!/bin/bash
# deploy kickstart
# jason
# 2018 11 27
# v1.0

# configure repo
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum makecache

# install service
yum install -y dhcp tftp-server syslinux httpd

# configure dhcp
cat >>/etc/dhcp/dhcpd.conf<<EOF
subnet 172.16.1.0 netmask 255.255.255.0 {
range 172.16.1.100 172.16.1.199;
option subnet-mask 255.255.255.0;
default-lease-time 21600;
max-lease-time 43200;
next-server 172.16.1.201;
filename "/pxelinux.0";
}
EOF

systemctl start dhcpd

# configure tftp server
cp -rf tftpboot /var/lib/
systemctl start tftp.socket

# mount cdrom
mkdir /var/www/html/CentOS7
mount /dev/cdrom /var/www/html/CentOS7

# configure http
cp -rf ks_config /var/www/html/
systemctl start httpd

