#!/usr/bin/env bash

echo -e "\n\n"
echo "███╗   ███╗ █████╗ ███╗   ██╗██╗   ██╗ █████╗ ███╗   ██╗"
echo "████╗ ████║██╔══██╗████╗  ██║╚██╗ ██╔╝██╔══██╗████╗  ██║"
echo "██╔████╔██║███████║██╔██╗ ██║ ╚████╔╝ ███████║██╔██╗ ██║"
echo "██║╚██╔╝██║██╔══██║██║╚██╗██║  ╚██╔╝  ██╔══██║██║╚██╗██║"
echo "██║ ╚═╝ ██║██║  ██║██║ ╚████║   ██║   ██║  ██║██║ ╚████║"
echo "╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝"
echo -e "\n"
echo "https://www.mygctong.com    version: 0.1"
echo "author: yagas <yagas@sina.com>"
echo "copyright (c) 2019 Manyan Network Technology Co. Ltd."
echo -e "\n\n"

packages=""

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

# 安装文件包
for pkg in $packages
do
	yum -y install $pkg
done

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

echo $packages

# 检测目录是否存在
if [ ! -d ./software ]; then
	mkdir ./software
fi

# 下载文件包
if [ ! -f ./software/libmcrypt-2.5.8.tar.gz ]; then
	echo -e "\n\ndownload libmcrypt package ...\n"
	curl -o ./software/libmcrypt-2.5.8.tar.gz -L https://sourceforge.net/projects/mcrypt/files/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz/download
fi

unzipdir='unpack'
mkdir $unzipdir
tar xzf ./software/libmcrypt-2.5.8.tar.gz -C $unzipdir
cd $unzipdir/libmcrypt-2.5.8
./configure
make -j4
sudo make install
