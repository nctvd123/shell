#!/bin/bash
#Cai dat php-fpm
path_shell=/root/scripts/static
path_down=/usr/src/static
if [ ! -d $path_down ];then
        mkdir -p $path_down
fi
yum install gcc.x86_64 gcc-c++.x86_64 make.x86_64 wget.x86_64 libxml2-devel.x86_64 openssl-devel.x86_64 pcre-devel.x86_64 libjpeg-devel curl-devel curl-devel.x86_64 libjpeg-devel.x86_64 libpng-devel.x86_64 freetype-devel.x86_64 libmcrypt.x86_64 libmcrypt-devel.x86_64  mhash.x86_64 mhash-devel.x86_64 php-mysql.x86_64 mysql-devel.x86_64 bzip2-devel.x86_64 aspell-devel.x86_64 libtidy.x86_64 libtidy-devel.x86_64 libxslt.x86_64 libxslt-devel.x86_64 glibc-utils.x86_64 libjpeg-turbo8-dev libpng-devel libmcrypt-devel.x86_64 libtool-ltdl-devel.x86_64
cd $path_down
wget http://php.net/downloads.php
grep "ChangeLog" downloads.php
echo -n "MOI ANH BAN NHAP PHIEN BAN PHP MOI NHAT O TREN THEO DANG php-5.6.31:"; read version_php
wget http://am1.php.net/get/$version_php.tar.gz/from/this/mirror
if [ "$?" != 0 ] && [ -d $path_shell ];then
        echo "Error download php"
else
	echo -n "Nhap duong dan chua file cai dat php:";read php_source
	mv mirror $version_php.tar.gz
	tar xzvf $version_php.tar.gz
	cd $version_php
	./configure \--prefix=$php_source/php \--enable-fpm \--with-libdir=lib64 \--with-bz2 \--with-config-file-path=$php_source/php/etc \--with-config-file-scan-dir=$php_source/php/etc/php.d \--with-curl=$php_source/lib \--with-gd \--with-gettext \--with-jpeg-dir=$php_source/lib \--with-freetype-dir=$php_source/lib \--with-kerberos \--with-mcrypt \--with-mhash \--with-mysql \--with-mysqli \--with-pdo-mysql=shared \--with-pdo-sqlite=shared \--with-pear=$php_source/lib/php \--with-png-dir=$php_source/lib \--with-pspell \--with-sqlite=shared \--with-tidy \--with-xmlrpc \--with-xsl \--with-zlib \--with-zlib-dir=$duongdan/lib \--with-openssl \--with-iconv \--enable-bcmath \--enable-calendar \--enable-exif \--enable-ftp \--enable-gd-native-ttf \--enable-libxml \--enable-magic-quotes \--enable-soap \--enable-sockets \--enable-mbstring \--enable-zip \--enable-wddx
	make -j 2
	make install
	n=`echo $version_php | cut -d . -f 1`
	if  [ $n == php-5 ]; then
		cp php.ini-production $php_source/php/etc/php.ini
		cd $php_source/php/etc/
		cp php-fpm.conf.default php-fpm.conf
		sed -i -e "s/;pid = /pid = /" $php_source/php/etc/php-fpm.conf
		sed -i -e "s/;error_log = /error_log = /" $php_source/php/etc/php-fpm.conf
		sed -i -e "s/user = nobody/user = nginx/" $php_source/php/etc/php-fpm.conf
		sed -i -e "s/group = nobody/group = nginx/" $php_source/php/etc/php-fpm.conf
		sed -i -e "s/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/" $php_source/php/etc/php-fpm.conf
	else
		cp php.ini-production $php_source/php/etc/php.ini
        	cd $php_source/php/etc/
        	cp php-fpm.conf.default php-fpm.conf
        	sed -i -e "s/;pid = /pid = /" $php_source/php/etc/php-fpm.conf
        	sed -i -e "s/;error_log = /error_log = /" $php_source/php/etc/php-fpm.conf
		cp $php_source/php/etc/php-fpm.d/www.conf.default $php_source/php/etc/php-fpm.d/www.conf
        	sed -i -e "s/user = nobody/user = nginx/" $php_source/php/etc/php-fpm.d/www.conf
        	sed -i -e "s/group = nobody/group = nginx/" $php_source/php/etc/php-fpm.d/www.conf
        	sed -i -e "s/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/" $php_source/php/etc/php-fpm.d/www.conf
	fi
fi
#chmod +x /etc/init.d/php-fpm
#chkconfig php-fpm on
#service php-fpm restart
$php_source/php/sbin/php-fpm
netstat -ntpl
echo "DONE"
