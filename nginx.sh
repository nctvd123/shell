#!/bin/bash
#Cai dat thoi gian
yum install ntp -y
mv /etc/localtime /etc/localtime.bak
ln -s /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
service ntpd restart
useradd nginx
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
yum -y install gcc gcc-c++ make zlib-devel pcre-devel openssl-devel gd-devel wget vimi links
cd $path_down
#wget http://nginx.org/en/download.html
#grep "ChangeLog" downloads.php
echo -n "MOI ANH BAN NHAP PHIEN BAN NGINX MOI NHAT O TREN THEO DANG nginx-1.12.1:"; read version_nginx
wget http://nginx.org/download/$version_nginx.tar.gz
if [ "$?" != 0 ] && [ -d $path_shell ];then
        echo "Error download nginx"
else
	mkdir -p $path_shell
        echo -n "Nhap duong dan chua file cai dat nginx:";read nginx_source
	echo -n "Nhap thong so domainname: "; read domainname
	echo -n "Nhap thong so port:";read port
        echo -n "Nhap thong so document_root:";read root
	#Tao duong dan document root
        mkdir -p $root
	tar -xvzf $version_nginx.tar.gz
	cd $version_nginx
	./configure --prefix=$nginx_source/nginx/ --with-file-aio --with-http_mp4_module --with-http_flv_module --with-http_secure_link_module --with-http_realip_module --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module --without-http_ssi_module --without-http_scgi_module --without-http_uwsgi_module --with-http_gzip_static_module --with-http_stub_status_module --with-http_image_filter_module
	make -j 2
	make install
	sed -i '36s/80/'$port'/' $nginx_source/nginx/conf/nginx.conf
        sed -i '37s/localhost/'$domainname'/' $nginx_source/nginx/conf/nginx.conf
        sed -i '44s#html#'$root'#' $nginx_source/nginx/conf/nginx.conf
	echo "qua trinh cai dat da xong, bat dau qua trinh khoi dong nginx:"
	$nginx_source/nginx/sbin/nginx
	netstat -ntpl
	#Tao file index de test
	touch $root/index.html
        echo toandeptrai >> $root/index.html
	bien=`ifconfig`
        ip=`echo $bien | cut -c 61-75`
        links $ip:$port
fi
