nginx_php () 
{
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
useradd nginx
#Cai dat nginx
path_shell=/root/scripts/static
path_down=/usr/src/static
if [ ! -d $path_down ];then
        mkdir -p $path_down
fi
	yum -y install gcc gcc-c++ make zlib-devel pcre-devel openssl-devel gd-devel wget vim links
	cd $path_down
	wget http://nginx.org/download/nginx-1.12.1.tar.gz
	if [ "$?" != 0 ] && [ -d $path_shell ];then
        	echo "Error download nginx"
	else
		#Tao duong dan document root 
		mkdir -p $4
        tar -xvzf nginx-1.12.1.tar.gz
        cd nginx-1.12.1
        ./configure --prefix=$1/nginx/ --with-file-aio --with-http_mp4_module --with-http_flv_module --with-http_secure_link_module --with-http_realip_module --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module --without-http_ssi_module --without-http_scgi_module --without-http_uwsgi_module --with-http_gzip_static_module --with-http_stub_status_module --with-http_image_filter_module --with-http_ssl_module
        make -j 2
        make install 
        echo "qua trinh cai dat da xong, bat dau qua trinh khoi dong nginx:"
		mkdir -p $1/nginx/conf/conf.d
		touch $1/nginx/conf/conf.d/$2.conf
		sed -i '20s#$#   include '$1'/nginx/conf/conf.d/*.conf;#' $1/nginx/conf/nginx.conf
		sed -i '35s/    server {/    #server {/' $1/nginx/conf/nginx.conf
		sed -i '36s/listen/#listen/' $1/nginx/conf/nginx.conf
		sed -i '37s/server_name/#server_name/' $1/nginx/conf/nginx.conf
		sed -i '43s/location/#location/' $1/nginx/conf/nginx.conf
		sed -i '44s/root/#root/' $1/nginx/conf/nginx.conf
		sed -i '45s/index/#index/' $1/nginx/conf/nginx.conf
		sed -i '46s/}/#}/' $1/nginx/conf/nginx.conf
		sed -i '52s/error_page/#error_page/' $1/nginx/conf/nginx.conf
		sed -i '53s/location/#location/' $1/nginx/conf/nginx.conf
		sed -i '54s/root/#root/' $1/nginx/conf/nginx.conf
		sed -i '55s/}/#}/' $1/nginx/conf/nginx.conf
		sed -i '79s/}/#}/' $1/nginx/conf/nginx.conf
		echo "cau hinh nginx chay php:"
		sed -i 's/#user  nobody;/user  nginx;/' $1/nginx/conf/nginx.conf
		so_process=`cat /proc/cpuinfo |grep processor |wc -l`
		sed -i 's/worker_processes  1;/worker_processes  '$so_process';/' $1/nginx/conf/nginx.conf
		sed -i 's/#error_log  logs\/error.log;/error_log  logs\/error.log;/' $1/nginx/conf/nginx.conf
		sed -i 's/#pid        logs\/nginx.pid;/pid        logs\/nginx.pid;/' $1/nginx/conf/nginx.conf
		sed -i 's/#gzip  on;/gzip  on;/' $1/nginx/conf/nginx.conf
		sed -i '21s/#log_format/log_format/' $1/nginx/conf/nginx.conf
		sed -i '22s/#                  '/                  '/' $1/nginx/conf/nginx.conf
		sed -i '23s/#                  '/                  '/' $1/nginx/conf/nginx.conf
		#cau hinh ssl
		echo "server {" >> $1/nginx/conf/conf.d/$2.conf
		echo "    listen       80;" >> $1/nginx/conf/conf.d/$2.conf
		echo "    server_name  $2;" >> $1/nginx/conf/conf.d/$2.conf
		echo "    rewrite  ^/(.*) https://$2/index.php permanent;" >> $1/nginx/conf/conf.d/$2.conf
		echo "}" >> $1/nginx/conf/conf.d/$2.conf
		echo "server {" >> $1/nginx/conf/conf.d/$2.conf
		echo "    listen      443;" >> $1/nginx/conf/conf.d/$2.conf
		echo "    ssl on;" >> $1/nginx/conf/conf.d/$2.conf
		echo "    ssl_certificate $1/ssl/$2.crt;" >> $1/nginx/conf/conf.d/$2.conf
		echo "    ssl_certificate_key $1/ssl/$2.key;" >> $1/nginx/conf/conf.d/$2.conf
		echo "    access_log $1/nginx/logs/$2.access.log;" >> $1/nginx/conf/conf.d/$2.conf
		echo "    error_log $1/nginx/logs/$2.error.log;" >> $1/nginx/conf/conf.d/$2.conf
		echo "    location / {" >> $1/nginx/conf/conf.d/$2.conf
		echo "        root         $4;" >> $1/nginx/conf/conf.d/$2.conf
		echo "        index  index.html index.htm;" >> $1/nginx/conf/conf.d/$2.conf
		echo "    }" >> $1/nginx/conf/conf.d/$2.conf
		echo "    location ~  \.php$ {" >> $1/nginx/conf/conf.d/$2.conf
		echo "    root           $4;" >> $1/nginx/conf/conf.d/$2.conf
		echo "    fastcgi_pass   127.0.0.1:9000;" >> $1/nginx/conf/conf.d/$2.conf
		echo "    fastcgi_index  index.php;" >> $1/nginx/conf/conf.d/$2.conf
		echo "    fastcgi_param  SCRIPT_FILENAME  $4/$fastcgi_script_name;" >> $1/nginx/conf/conf.d/$2.conf
		echo "    include        fastcgi_params;" >> $1/nginx/conf/conf.d/$2.conf
		echo "    }" >> $1/nginx/conf/conf.d/$2.conf
		echo "        error_page 404 /404.html;" >> $1/nginx/conf/conf.d/$2.conf
		echo "        location = /40x.html {" >> $1/nginx/conf/conf.d/$2.conf
		echo "    }" >> $1/nginx/conf/conf.d/$2.conf
		echo "        error_page 500 502 503 504 /50x.html;" >> $1/nginx/conf/conf.d/$2.conf
		echo "        location = /50x.html {" >> $1/nginx/conf/conf.d/$2.conf
		echo "    }" >> $1/nginx/conf/conf.d/$2.conf
		echo "}" >> $1/nginx/conf/conf.d/$2.conf
		#Cai dat php-fpm
		yum -y install gcc.x86_64 gcc-c++.x86_64 make.x86_64 wget.x86_64 libxml2-devel.x86_64 openssl-devel.x86_64 pcre-devel.x86_64 libjpeg-devel curl-devel curl-devel.x86_64 libjpeg-devel.x86_64 libpng-devel.x86_64 freetype-devel.x86_64 libmcrypt.x86_64 libmcrypt-devel.x86_64  mhash.x86_64 mhash-devel.x86_64 php-mysql.x86_64 mysql-devel.x86_64 bzip2-devel.x86_64 aspell-devel.x86_64 libtidy.x86_64 libtidy-devel.x86_64 libxslt.x86_64 libxslt-devel.x86_64 glibc-utils.x86_64 libjpeg-turbo8-dev libpng-devel libmcrypt-devel.x86_64 libtool-ltdl-devel.x86_64
		rpm -ivh "http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm"
		yum -y install libmcrypt-devel
		cd $path_down
		link_php=`curl -L http://php.net/downloads.php | grep tar.gz | grep 'php-7.1'|grep -v "MD5\|PGP\|SHA1\|SHA256"| cut -d / -f 3`
		echo $link_php
		wget http://am1.php.net/get/$link_php/from/this/mirror
		if [ "$?" != 0 ] && [ -d $path_shell ];then
        		echo "Error download php"
		else
        		mv mirror $link_php
     			version_php=`tar -xvzf $link_php`
        		cd $version_php
        		./configure \--prefix=$1/php \--enable-fpm \--with-libdir=lib64 \--with-bz2 \--with-config-file-path=$1/php/etc \--with-config-file-scan-dir=$1/php/etc/php.d \--with-curl=$1/lib \--with-gd \--with-gettext \--with-jpeg-dir=$1/lib \--with-freetype-dir=$1/lib \--with-kerberos \--with-mcrypt \--with-mhash \--with-mysql \--with-mysqli \--with-pdo-mysql=shared \--with-pdo-sqlite=shared \--with-pear=$1/lib/php \--with-png-dir=$1/lib \--with-pspell \--with-sqlite=shared \--with-tidy \--with-xmlrpc \--with-xsl \--with-zlib \--with-zlib-dir=$1/lib \--with-openssl \--with-iconv \--enable-bcmath \--enable-calendar \--enable-exif \--enable-ftp \--enable-gd-native-ttf \--enable-libxml \--enable-magic-quotes \--enable-soap \--enable-sockets \--enable-mbstring \--enable-zip \--enable-wddx
        		make -j 2
        		make install
			n=`echo $version_php | cut -d . -f 1`
        		if  [ $n == php-5 ]; then
                		cp php.ini-production $1/php/etc/php.ini
                		cd $1/php/etc/
                		cp php-fpm.conf.default php-fpm.conf
                		sed -i -e "s/;pid = /pid = /" $1/php/etc/php-fpm.conf
                		sed -i -e "s/;error_log = /error_log = /" $1/php/etc/php-fpm.conf
                		sed -i -e "s/user = nobody/user = nginx/" $1/php/etc/php-fpm.conf
                		sed -i -e "s/group = nobody/group = nginx/" $1/php/etc/php-fpm.conf
                		sed -i -e "s/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/" $1/php/etc/php-fpm.conf
        		else
                		cp php.ini-production $1/php/etc/php.ini
                		cd $1/php/etc/
                		cp php-fpm.conf.default php-fpm.conf
                		sed -i -e "s/;pid = /pid = /" $1/php/etc/php-fpm.conf
                		sed -i -e "s/;error_log = /error_log = /" $1/php/etc/php-fpm.conf
                		cp $1/php/etc/php-fpm.d/www.conf.default $1/php/etc/php-fpm.d/www.conf
                		sed -i -e "s/user = nobody/user = nginx/" $1/php/etc/php-fpm.d/www.conf
                		sed -i -e "s/group = nobody/group = nginx/" $1/php/etc/php-fpm.d/www.conf
                		sed -i -e "s/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/" $1/php/etc/php-fpm.d/www.conf
        		fi
		fi
		#cai dat ssl
		mkdir -p $1/ssl
		cd $1/ssl
		openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout toandaica.vn.key -out toandaica.vn.crt
		#Tao duong dan document root
 		mkdir -p $4
		chown -R nginx:nginx $4
        netstat -ntpl
        #Tao file index de test
        touch $4/index.php
		touch $4/index.html
		echo "toandaica" >> $4/index.html
        echo "<?php phpinfo(); ?>" >> $4/index.php
		$1/nginx/sbin/nginx
		$1/php/sbin/php-fpm
		IF=`route | grep default | awk '{print $8}'`
        ip=`ip a | grep $IF | grep inet | awk '{print $2}' | cut -d / -f 1`
        links $ip:$3/index.php
	fi
}
nginx_php /usr/local toandaica.vn 80 /usr/local/toandaica.vn
