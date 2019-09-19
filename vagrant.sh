#!/usr/bin/env bash

yum update curl
yum -y install yum-utils yum-config-manager
rpm --import https://rpms.remirepo.net/RPM-GPG-KEY-remi
rpm -vih http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
rpm -Uvh https://mirrors.tuna.tsinghua.edu.cn/remi/enterprise/remi-release-7.rpm

cat >> /etc/yum.repos.d/nginx.repo <<\EOF
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

yum-config-manager --enable nginx-stable
yum-config-manager --enable remi-php56

yum clean all && yum makecache

yum -y --enablerepo=remi-php56 install php php-fpm php-mongodb php-gd php-redis php-gd php-pdo php-pdo_mysql php-bcmath php-mbstring php-mcrypt
yum -y install nginx
