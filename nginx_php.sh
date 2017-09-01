#!/bin/bash
#Cai dat thoi gian
yum install ntp -y
mv /etc/localtime /etc/localtime.bak
ln -s /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
service ntpd restart
#Tat selinux
setenforce 0
#Tat iptables
service iptables stop
#Cai dat nginx
path_shell=/root/scripts/static
path_down=/usr/src/static
if [ ! -d $path_down ];then
        mkdir -p $path_down
fi
	yum -y install gcc gcc-c++ make zlib-devel pcre-devel openssl-devel gd-devel wget vim links
	cd $path_down
	#wget http://nginx.org/en/download.html
	#grep "ChangeLog" downloads.php
	echo -n "MOI ANH BAN NHAP PHIEN BAN NGINX MOI NHAT O TREN THEO DANG nginx-1.12.1:"; read version_nginx
	wget http://nginx.org/download/$version_nginx.tar.gz
	if [ "$?" != 0 ] && [ -d $path_shell ];then
        	echo "Error download nginx"
	else
        	echo -n "Nhap duong dan chua file cai dat nginx,php:";read source
		echo -n "Nhap thong so domainname: "; read domainname
		echo -n "Nhap thong so port";read port
		echo -n "Nhap thong so document_root";read document_root
		#Tao duong dan document root 
		mkdir -p $document_root
        	tar -xvzf $version_nginx.tar.gz
        	cd $version_nginx
        	./configure --prefix=$source/nginx/ --with-file-aio --with-http_mp4_module --with-http_flv_module --with-http_secure_link_module --with-http_realip_module --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module --without-http_ssi_module --without-http_scgi_module --without-http_uwsgi_module --with-http_gzip_static_module --with-http_stub_status_module --with-http_image_filter_module
        	make -j 2
        	make install 
        	echo "qua trinh cai dat da xong, bat dau qua trinh khoi dong nginx:"
		sed -i '36s/80/'$port'/' $source/nginx/conf/nginx.conf
		sed -i '37s/localhost/'$domainname'/' $source/nginx/conf/nginx.conf
		sed -i '66s/#    root           html;/    root           html;/' $source/nginx/conf/nginx.conf
		sed -i '66s#html#'$document_root'#' $source/nginx/conf/nginx.conf
		echo "cau hinh nginx chay php:"
		sed -i 's/#user  nobody;/user  nginx;/' $source/nginx/conf/nginx.conf
		so_process=`cat /proc/cpuinfo |grep processor |wc -l`
		sed -i 's/worker_processes  1;/worker_processes  '$so_process';/' $source/nginx/conf/nginx.conf
		sed -i 's/#error_log  logs\/error.log;/error_log  logs\/error.log;/' $source/nginx/conf/nginx.conf
		sed -i 's/#pid        logs\/nginx.pid;/pid        logs\/nginx.pid;/' $source/nginx/conf/nginx.conf
		sed -i 's/#gzip  on;/gzip  on;/' $source/nginx/conf/nginx.conf
		sed -i '65,71s/#location ~ /location ~  /' $source/nginx/conf/nginx.conf
		sed -i '67s/#    fastcgi_pass   127.0.0.1:9000;/    fastcgi_pass   127.0.0.1:9000;/' $source/nginx/conf/nginx.conf
		sed -i '68s/#    fastcgi_index  index.php;/    fastcgi_index  index.php;/' $source/nginx/conf/nginx.conf
		sed -i '69s/#    fastcgi_param  SCRIPT_FILENAME  \/scripts$fastcgi_script_name;/    fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;/' $source/nginx/conf/nginx.conf
		sed -i '70s/#    include        fastcgi_params;/    include        fastcgi_params;/' $source/nginx/conf/nginx.conf
		sed -i '65,71s/#}/}/' $source/nginx/conf/nginx.conf
        	$source/nginx/sbin/nginx
		netstat -ntpl
		#Cai dat php-fpm
		yum install gcc.x86_64 gcc-c++.x86_64 make.x86_64 wget.x86_64 libxml2-devel.x86_64 openssl-devel.x86_64 pcre-devel.x86_64 libjpeg-devel curl-devel curl-devel.x86_64 libjpeg-devel.x86_64 libpng-devel.x86_64 freetype-devel.x86_64 libmcrypt.x86_64 libmcrypt-devel.x86_64  mhash.x86_64 mhash-devel.x86_64 php-mysql.x86_64 mysql-devel.x86_64 bzip2-devel.x86_64 aspell-devel.x86_64 libtidy.x86_64 libtidy-devel.x86_64 libxslt.x86_64 libxslt-devel.x86_64 glibc-utils.x86_64 libjpeg-turbo8-dev libpng-devel libmcrypt-devel.x86_64 libtool-ltdl-devel.x86_64
		cd $path_down
		wget http://php.net/downloads.php
		grep "ChangeLog" downloads.php
		echo -n "MOI ANH BAN NHAP PHIEN BAN PHP MOI NHAT O TREN THEO DANG php-5.6.31:"; read version_php
		wget http://am1.php.net/get/$version_php.tar.gz/from/this/mirror
		if [ "$?" != 0 ] && [ -d $path_shell ];then
        		echo "Error download php"
		else
        		mv mirror $version_php.tar.gz
     			tar xzvf $version_php.tar.gz
        		cd $version_php
        		./configure \--prefix=$source/php \--enable-fpm \--with-libdir=lib64 \--with-bz2 \--with-config-file-path=$source/php/etc \--with-config-file-scan-dir=$source/php/etc/php.d \--with-curl=$source/lib \--with-gd \--with-gettext \--with-jpeg-dir=$source/lib \--with-freetype-dir=$source/lib \--with-kerberos \--with-mcrypt \--with-mhash \--with-mysql \--with-mysqli \--with-pdo-mysql=shared \--with-pdo-sqlite=shared \--with-pear=$source/lib/php \--with-png-dir=$source/lib \--with-pspell \--with-sqlite=shared \--with-tidy \--with-xmlrpc \--with-xsl \--with-zlib \--with-zlib-dir=$source/lib \--with-openssl \--with-iconv \--enable-bcmath \--enable-calendar \--enable-exif \--enable-ftp \--enable-gd-native-ttf \--enable-libxml \--enable-magic-quotes \--enable-soap \--enable-sockets \--enable-mbstring \--enable-zip \--enable-wddx
        		make -j 2
        		make install
			n=`echo $version_php | cut -d . -f 1`
        		if  [ $n == php-5 ]; then
                		cp php.ini-production $source/php/etc/php.ini
                		cd $source/php/etc/
                		cp php-fpm.conf.default php-fpm.conf
                		sed -i -e "s/;pid = /pid = /" $source/php/etc/php-fpm.conf
                		sed -i -e "s/;error_log = /error_log = /" $source/php/etc/php-fpm.conf
                		sed -i -e "s/user = nobody/user = nginx/" $source/php/etc/php-fpm.conf
                		sed -i -e "s/group = nobody/group = nginx/" $source/php/etc/php-fpm.conf
                		sed -i -e "s/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/" $source/php/etc/php-fpm.conf
        		else
                		cp php.ini-production $source/php/etc/php.ini
                		cd $source/php/etc/
                		cp php-fpm.conf.default php-fpm.conf
                		sed -i -e "s/;pid = /pid = /" $source/php/etc/php-fpm.conf
                		sed -i -e "s/;error_log = /error_log = /" $source/php/etc/php-fpm.conf
                		cp $source/php/etc/php-fpm.d/www.conf.default $source/php/etc/php-fpm.d/www.conf
                		sed -i -e "s/user = nobody/user = nginx/" $source/php/etc/php-fpm.d/www.conf
                		sed -i -e "s/group = nobody/group = nginx/" $source/php/etc/php-fpm.d/www.conf
                		sed -i -e "s/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/" $source/php/etc/php-fpm.d/www.conf
        		fi
		fi
		#Tao duong dan document root
 		mkdir -p $document_root
        	netstat -ntpl
        	#Tao file index de test
        	touch $document_root/index.php
        	echo "<?php phpinfo(); ?>" >> $document_root/index.php
		$source/php/sbin/php-fpm
		IF=`route | grep default | awk '{print $8}'`
        ip=`ip a | grep $IF | grep inet | awk '{print $2}' | cut -d / -f 1`
        	links $ip:$port/index.php
	fi
