nginx () 
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
		echo "    fastcgi_param  SCRIPT_FILENAME  $4/"$fastcgi_script_name";" >> $1/nginx/conf/conf.d/$2.conf
		echo "    include        fastcgi_params;" >> $1/nginx/conf/conf.d/$2.conf
		echo "    }" >> $1/nginx/conf/conf.d/$2.conf
		echo "        error_page 404 /404.html;" >> $1/nginx/conf/conf.d/$2.conf
		echo "        location = /40x.html {" >> $1/nginx/conf/conf.d/$2.conf
		echo "    }" >> $1/nginx/conf/conf.d/$2.conf
		echo "        error_page 500 502 503 504 /50x.html;" >> $1/nginx/conf/conf.d/$2.conf
		echo "        location = /50x.html {" >> $1/nginx/conf/conf.d/$2.conf
		echo "    }" >> $1/nginx/conf/conf.d/$2.conf
		echo "}" >> $1/nginx/conf/conf.d/$2.conf
		#cai dat ssl
		mkdir -p $1/ssl
		cd $1/ssl
		openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout toandaica.vn.key -out toandaica.vn.crt
		#Tao duong dan document root
 		mkdir -p $4
		chown -R nginx:nginx $4
        #Tao file index de test
        touch $4/index.php
		echo "toandaica" >> $4/index.html
		$1/nginx/sbin/nginx
		netstat -ntpl
		IF=`route | grep default | awk '{print $8}'`
        ip=`ip a | grep $IF | grep inet | awk '{print $2}' | cut -d / -f 1`
        links $ip:$3/index.php
	fi
}
nginx /usr/local toandaica.vn 80 /usr/local/toandaica.vn
