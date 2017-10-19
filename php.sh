php ()
{
#!/bin/bash
#Cai dat php-fpm
path_shell=/root/scripts/static
path_down=/usr/src/static
if [ ! -d $path_down ];then
        mkdir -p $path_down
fi
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
	./configure \--prefix=$1/php \--enable-fpm \--with-libdir=lib64 \--with-bz2 \--with-config-file-path=$1/php/etc \--with-config-file-scan-dir=$1/php/etc/php.d \--with-curl=$1/lib \--with-gd \--with-gettext \--with-jpeg-dir=$1/lib \--with-freetype-dir=$1/lib \--with-kerberos \--with-mcrypt \--with-mhash \--with-mysql \--with-mysqli \--with-pdo-mysql=shared \--with-pdo-sqlite=shared \--with-pear=$1/lib/php \--with-png-dir=$1/lib \--with-pspell \--with-sqlite=shared \--with-tidy \--with-xmlrpc \--with-xsl \--with-zlib \--with-zlib-dir=$duongdan/lib \--with-openssl \--with-iconv \--enable-bcmath \--enable-calendar \--enable-exif \--enable-ftp \--enable-gd-native-ttf \--enable-libxml \--enable-magic-quotes \--enable-soap \--enable-sockets \--enable-mbstring \--enable-zip \--enable-wddx
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
#chmod +x /etc/init.d/php-fpm
#chkconfig php-fpm on
#service php-fpm restart
useradd nginx
$1/php/sbin/php-fpm
netstat -ntpl
echo "DONE"
}
php /usr/local
