#!/usr/bin/env bash

yum -y install yum-utils yum-config-manager
rpm -vih http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
rpm -Uvh https://mirrors.tuna.tsinghua.edu.cn/remi/enterprise/remi-release-7.rpm

cat >> /etc/yum.repos.d/nginx.repo <<EOF
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
EOF

sed -i 's/\/\/\//\//' /etc/yum.repos.d/nginx.repo
yum clean all && yum makecache
yum-config-manager --enable nginx-stable
yum-config-manager --enable remi-php56
yum --enablerepo=remi56 install php php-fpm php-mongodb php-gd php-redis
yum install nginx
