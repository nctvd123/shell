#Cai dat thoi gian
yum install ntp -y
mv /etc/localtime /etc/localtime.bak
ln -s /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
service ntpd restart
useradd apache
#Tat selinux
setenforce 0
#Tat iptables
service iptables stop
#Cai dat nginx
path_shell=/root/scripts/static
path_down=/usr/src/static/
if [ ! -d $path_down ];then
        mkdir -p $path_down
fi
	yum -y install apr-devel apr-util-devel gcc pcre-devel.x86_64 zlib-devel openssl-devel wget vim links
	cd $path_down
	#Kiem tra cac phien ban moi nhat
	wget https://httpd.apache.org/download.cgi
	grep "Source:" download.cgi
	echo -n "MOI BAN NHAP PHIEN BAN APACHE MOI NHAT O TREN THEO DANG httpd-2.4.27:"; read version_apache
	wget http://mirrors.viethosting.com/apache//httpd/$version_apache.tar.gz
	if [ "$?" != 0 ] && [ -d $path_shell ] && [ ];then
        	echo "Error download "
	else
        	tar xzvf $version_apache.tar.gz
        	cd $version_apache/srclib
        	wget https://apr.apache.org/download.cgi
        	grep "http://mirrors.viethosting.com/apache//apr/" download.cgi
        	echo -n "MOI BAN NHAP PHIEN BAN APR MOI NHAT O TREN THEO DANG apr-1.6.2 :"; read version_apr
        	echo -n "MOI BAN NHAP PHIEN BAN APR MOI NHAT O TREN THEO DANG apr-util-1.6.0 :";read version_apr_util
        	wget http://mirrors.viethosting.com/apache//apr/$version_apr.tar.gz
        	wget http://mirrors.viethosting.com/apache//apr/$version_apr_util.tar.gz
        	tar -xvzf $version_apr.tar.gz
        	mv $version_apr apr
		tar -xvzf $version_apr_util.tar.gz
        	mv $version_apr_util apr-util
        	echo -n "Nhap duong dan chua file cai dat apache,php:"; read source
        	echo -n "Nhap thong so domainname: "; read domainname
        	echo -n "Nhap thong so port:";read port
        	echo -n "Nhap thong so document_root:";read document_root
        	cd ..
        	./configure --prefix=$source/httpd --enable-so --enable-deflate --enable-expires --enable-headers --enable-rewrite --with-included-apr --with-included-apr-util
        	make -j 2
        	make install
        	sed -i 's/Listen 80/Listen '$port'/' $source/httpd/conf/httpd.conf
        	sed -i 's/User daemon/User apache/' $source/httpd/conf/httpd.conf
        	sed -i 's/Group daemon/Group apache/' $source/httpd/conf/httpd.conf
        	sed -i 's/#ServerName/ServerName/' $source/httpd/conf/httpd.conf
        	sed -i 's#www.example.com:80#'$domainname'#' $source/httpd/conf/httpd.conf
        	sed -i 's#'$source'/httpd/htdocs#'$document_root'#' $source/httpd/conf/httpd.conf
        	#Tao duong dan document root
        	mkdir -p $document_root
        	chown -R apache:apache $document_root
        	echo "qua trinh cai dat da xong, bat dau qua trinh khoi dong apache:"
        	n=`echo $version_apache | cut -d . -f 1,2`
        	if [ $n == httpd-2.4 ]; then
                	#phien ban 2.4
			echo "cau hinh apache-2.4 chay php:"
			sed -i '503s#$#ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9000'$document_root'/$1#' $source/httpd/conf/httpd.conf
			sed -i '116s/#LoadModule proxy_module modules\/mod_proxy.so/LoadModule proxy_module modules\/mod_proxy.so/'  $source/httpd/conf/httpd.conf
			sed -i '120s/#LoadModule proxy_fcgi_module modules\/mod_proxy_fcgi.so/LoadModule proxy_fcgi_module modules\/mod_proxy_fcgi.so/'  $source/httpd/conf/httpd.conf
			sed -i '251s/index.html/index.php index.html/'  $source/httpd/conf/httpd.conf
			$source/httpd/bin/apachectl
		else
                	#phien ban 2.2
			echo "cau hinh apache-2.2 chay php:"
			if [ "$?" != 0 ] && [ -d $path_shell ] && [ ];then
        			echo "Error download "
			else
				wget https://github.com/whyneus/magneto-ponies/raw/master/mod_fastcgi-SNAP-0910052141.tar.gz
				tar xzvf mod_fastcgi*
				cd mod_fastcgi-*
				make -f Makefile.AP2 top_dir=$source/httpd
				cp .libs/mod_fastcgi.so $source/httpd/modules/
				echo "LoadModule fastcgi_module $source/httpd/modules/mod_fastcgi.so" >> $source/httpd/conf/httpd.conf
				sed -i '119s/Deny/Allow/'  $source/httpd/conf/httpd.conf
        			sed -i '405s/#Include/Include/'  $source/httpd/conf/httpd.conf
				sed -i '405s/httpd-vhosts/'$domainname'/'  $source/httpd/conf/httpd.conf
				mv $source/httpd/conf/extra/httpd-vhosts.conf $source/httpd/conf/extra/$domainname.conf
				sed -i '19s/80/'$port'/'  $source/httpd/conf/extra/$domainname.conf
				sed -i '27s/80/'$port'/'  $source/httpd/conf/extra/$domainname.conf
				sed -i '29s#'$source'/httpd/docs/dummy-host.example.com#'$document_root'#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '30,33s/dummy-host.example.com/'$domainname'/'  $source/httpd/conf/extra/$domainname.conf
				sed -i '34s#</VirtualHost>#   FastCGIExternalServer '$source'/php/sbin/php-fpm -host 127.0.0.1:9000#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '35s/$/   AddHandler php-fpm .php/'  $source/httpd/conf/extra/$domainname.conf
				sed -i -e '36s#<VirtualHost #    #'  $source/httpd/conf/extra/$domainname.conf
				sed -i -e '36s#*:80>#Action php-fpm \/php.fcgi#'  $source/httpd/conf/extra/$domainname.conf	
				sed -i '37s#ServerAdmin webmaster@dummy-host2.example.com#Alias /php.fcgi '$source'/php/sbin/php-fpm#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '38s#DocumentRoot "'$source'/httpd/docs/dummy-host2.example.com"#DirectoryIndex index.php#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '39s#ServerName dummy-host2.example.com#<FilesMatch "\.php$">#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '40s#ErrorLog "logs/dummy-host2.example.com-error_log"#SetHandler php-fpm#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '41s#CustomLog "logs/dummy-host2.example.com-access_log" common#</FilesMatch>#'  $source/httpd/conf/extra/$domainname.conf
				$source/httpd/bin/httpd
			fi
			netstat -ntpl
			#Cai dat php-fpm
        		yum install gcc.x86_64 gcc-c++.x86_64 make.x86_64 wget.x86_64 libxml2-devel.x86_64 openssl-devel.x86_64 pcre-devel.x86_64 libjpeg-devel curl-devel curl-devel.x86_64 libjpeg-devel.x86_64 libpng-devel.x86_64 freetype-devel.x86_64 libmcrypt.x86_64 libmcrypt-devel.x86_64  mhash.x86_64 mhash-devel.x86_64 php-mysql.x86_64 mysql-devel.x86_64 bzip2-devel.x86_64 aspell-devel.x86_64 libtidy.x86_64 libtidy-devel.x86_64 libxslt.x86_64 libxslt-devel.x86_64 glibc-utils.x86_64 libjpeg-turbo8-dev libpng-devel libmcrypt-devel.x86_64 libtool-ltdl-devel.x86_64
        		rpm -ivh "http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm"
			yum install libmcrypt-devel
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
                        		sed -i -e "s/user = nobody/user = apache/" $source/php/etc/php-fpm.conf
                        		sed -i -e "s/group = nobody/group = apache/" $source/php/etc/php-fpm.conf
                        		sed -i -e "s/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/" $source/php/etc/php-fpm.conf
				else
                        		cp php.ini-production $source/php/etc/php.ini
                        		cd $source/php/etc/
                        		cp php-fpm.conf.default php-fpm.conf
                        		sed -i -e "s/;pid = /pid = /" $source/php/etc/php-fpm.conf
                        		sed -i -e "s/;error_log = /error_log = /" $source/php/etc/php-fpm.conf
                        		cp $source/php/etc/php-fpm.d/www.conf.default $source/php/etc/php-fpm.d/www.conf
                        		sed -i -e "s/user = nobody/user = apache/" $source/php/etc/php-fpm.d/www.conf
                        		sed -i -e "s/group = nobody/group = apache/" $source/php/etc/php-fpm.d/www.conf
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
                	bien=`ifconfig`
                	ip=`echo $bien | cut -c 61-75`
                	links $ip:$port/index.php
                	#chmod +x /etc/init.d/php-fpm
                	#chkconfig php-fpm on
                	#service php-fpm restart
		fi
	fi
