#!/usr/bin/env bash

echo -e "\n\n"
echo "███╗   ███╗ █████╗ ███╗   ██╗██╗   ██╗ █████╗ ███╗   ██╗"
echo "████╗ ████║██╔══██╗████╗  ██║╚██╗ ██╔╝██╔══██╗████╗  ██║"
echo "██╔████╔██║███████║██╔██╗ ██║ ╚████╔╝ ███████║██╔██╗ ██║"
echo "██║╚██╔╝██║██╔══██║██║╚██╗██║  ╚██╔╝  ██╔══██║██║╚██╗██║"
echo "██║ ╚═╝ ██║██║  ██║██║ ╚████║   ██║   ██║  ██║██║ ╚████║"
echo "╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝"
echo -e "\n"
echo "https://www.mygctong.com    version: 0.2"
echo "author: yagas <yagas@sina.com>"
echo "copyright (c) 2019 Manyan Network Technology Co. Ltd."
echo -e "\n\n"

packages=""
unzipdir='./unpack'
software='./software'

function checkrpm()
{
	local msg1="\e[1;32mYes\e[0m"
	local msg2="\e[1;31mNo\e[0m"
	local row=`rpm -qa | grep $1 | wc -l`
	local message="\e[1;32mYes\e[0m"
	
	echo -e "check $1 ...\t\c"
	
	if [ l = 0 ]; then
		message="\e[1;31mNo\e[0m"
		packages="$packages $1"
	fi	
	
	echo -e $message
}

# 检测目录是否存在
if [ ! -d $unpack ]; then
	mkdir $unzipdir
fi

if [ ! -d $software ]; then
	mkdir $software
fi

checkrpm gcc
checkrpm autoconf
checkrpm automake
checkrpm libjpeg
checkrpm libpng
checkrpm libxml2-devel
checkrpm openssl-devel
checkrpm gd-devel
checkrpm pcre2-devel
checkrpm freetype-devel

# 安装文件包
if [ ! -z $packages ]; then
	yum -y install $packages
fi

# 判断libmcrypt是否安装，没安装则自动下载安装包
libmcrypt=$(whereis libmcrypt.so | grep libmcrypt.so | wc -l)
if [ $libmcrypt -ne 1 ]; then
	if [ ! -f $software/libmcrypt-2.5.8.tar.gz ]; then
		echo -e "\n\ndownload libmcrypt package ...\n"
		curl -o $software/libmcrypt-2.5.8.tar.gz -L https://sourceforge.net/projects/mcrypt/files/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz/download
	fi
fi

# 判断php-5.6.40是否安装，没安装则自动下载安装包
php=$(whereis php | grep php | wc -l)
if [ $libmcrypt -ne 1 ]; then
	if [ ! -f $software/php-5.6.40.tar.gz ]; then
		echo -e "\n\ndownload php-5.6.40 package ...\n"
		curl -o $software/php-5.6.40.tar.gz -L https://www.php.net/distributions/php-5.6.40.tar.gz
	fi
fi



if [ $libmcrypt -ne 1 ]; then
	tar xzf $software/libmcrypt-2.5.8.tar.gz -C $unzipdir
	cd $unzipdir/libmcrypt-2.5.8
	./configure
	make -j4
	sudo make install
fi

if [ $php -ne 1 ]; then
	tar xzf $software/php-5.6.40.tar.gz -C $unzipdir
	cd $unzipdir/php-5.6.40
	./configure --enable-fpm --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib-dir --with-libxml-dir --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mhash --with-gd --enable-gd-native-ttf --enable-pcntl --enable-zip --with-bz2 --without-iconv --with-gettext --with-pear --enable-calendar --with-pdo-mysql --enable-opcache --with-openssl --with-mcrypt --prefix=/usr/local/php56
	make -j4
	sudo make install
fi

echo "\nDone.\n"
