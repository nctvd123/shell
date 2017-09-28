apache () {
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
	#echo -n "MOI BAN NHAP PHIEN BAN APACHE MOI NHAT O TREN THEO DANG httpd-2.4.27:"; read version_apache
	wget http://mirror.downloadvn.com/apache//httpd/$version_apache.tar.gz
	if [ "$?" != 0 ] && [ -d $path_shell ] && [ ];then
        	echo "Error download "
	else
        	tar xzvf $version_apache.tar.gz
        	cd $version_apache/srclib
        	wget https://apr.apache.org/download.cgi
        	grep "http://mirrors.viethosting.com/apache//apr/" download.cgi
        	#echo -n "MOI BAN NHAP PHIEN BAN APR MOI NHAT O TREN THEO DANG apr-1.6.2 :"; read version_apr
        	#echo -n "MOI BAN NHAP PHIEN BAN APR MOI NHAT O TREN THEO DANG apr-util-1.6.0 :";read version_apr_util
        	wget http://mirror.downloadvn.com/apache//apr/$version_apr.tar.gz
        	wget http://mirror.downloadvn.com/apache//apr/$version_apr_util.tar.gz
        	tar -xvzf $version_apr.tar.gz
        	mv $version_apr apr
		tar -xvzf $version_apr_util.tar.gz
        	mv $version_apr_util apr-util
        	#echo -n "Nhap duong dan chua file cai dat apache,php:"; read source
        	#echo -n "Nhap thong so domainname: "; read domainname
        	#echo -n "Nhap thong so port:";read port
        	#echo -n "Nhap thong so document_root:";read document_root
		#Tao duong dan document root
        	mkdir -p $document_root
		cd ..
        	./configure --prefix=$source/httpd --enable-so --enable-deflate --enable-expires --enable-ssl --enable-headers --enable-rewrite --with-included-apr --with-included-apr-util
        	make -j 2
        	make install
        	sed -i 's/Listen 80/Listen '$port'/' $source/httpd/conf/httpd.conf
        	sed -i 's/User daemon/User apache/' $source/httpd/conf/httpd.conf
        	sed -i 's/Group daemon/Group apache/' $source/httpd/conf/httpd.conf
        	sed -i 's/#ServerName/ServerName/' $source/httpd/conf/httpd.conf
        	sed -i 's#www.example.com:80#'$domainname'#' $source/httpd/conf/httpd.conf
        	sed -i 's#'$source'/httpd/htdocs#'$document_root'#' $source/httpd/conf/httpd.conf
        	echo "qua trinh cai dat da xong, bat dau qua trinh khoi dong apache:"
        	n=`echo $version_apache | cut -d . -f 1,2`
        	if [ $n == httpd-2.4 ]; then
				#phien ban 2.4
				echo "cau hinh apache-2.4 chay php:"
				sed -i '53s/$/Listen 443/' $source/httpd/conf/httpd.conf 
				sed -i '132s/#LoadModule ssl_module/LoadModule ssl_module/' $source/httpd/conf/httpd.conf
				sed -i '151s/#LoadModule rewrite_module/LoadModule rewrite_module/' $source/httpd/conf/httpd.conf
				sed -i '476s/#Include/Include/'  $source/httpd/conf/httpd.conf
				sed -i '476s/httpd-vhosts/'$domainname'/'  $source/httpd/conf/httpd.conf
				mv $source/httpd/conf/extra/httpd-vhosts.conf $source/httpd/conf/extra/$domainname.conf
				echo "ProxyPassMatch ^/(.*\\.php(/.*)?)$ fcgi://127.0.0.1:9000$document_root/$1" >> $source/httpd/conf/httpd.conf
				sed -i '116s/#LoadModule proxy_module modules\/mod_proxy.so/LoadModule proxy_module modules\/mod_proxy.so/'  $source/httpd/conf/httpd.conf
				sed -i '120s/#LoadModule proxy_fcgi_module modules\/mod_proxy_fcgi.so/LoadModule proxy_fcgi_module modules\/mod_proxy_fcgi.so/'  $source/httpd/conf/httpd.conf
				sed -i '251s/index.html/index.php index.html/'  $source/httpd/conf/httpd.conf
				sed -i '23s/80/'$port'/'  $source/httpd/conf/extra/$domainname.conf
				sed -i '25s#'$source'/httpd/docs/dummy-host.example.com#'$document_root'#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '26,29s/dummy-host.example.com/'$domainname'/'  $source/httpd/conf/extra/$domainname.conf
				sed -i '30s#</VirtualHost>#    RewriteEngine On#' $source/httpd/conf/extra/$domainname.conf
				sed -i '31s#$#    RewriteCond %{HTTPS} off#' $source/httpd/conf/extra/$domainname.conf
				sed -i '32s#<VirtualHost #    #'  $source/httpd/conf/extra/$domainname.conf
				sed -i '32s#*:80>#RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '33s#ServerAdmin webmaster@dummy-host2.example.com#</VirtualHost>#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '34s#DocumentRoot "'$source'/httpd/docs/dummy-host2.example.com"#<VirtualHost *:443>#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '35s#ServerName dummy-host2.example.com#DocumentRoot "'$document_root'"#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '36s#ErrorLog "logs/dummy-host2.example.com-error_log"#ServerName '$domainname':443#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '37s#CustomLog "logs/dummy-host2.example.com-access_log" common#    DirectoryIndex index.php index.html#'$source'/php/sbin/php-fpm -host 127.0.0.1:9000#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '38s#</VirtualHost>#    SSLEngine on#'  $source/httpd/conf/extra/$domainname.conf
				for ((i=0;i<=9;i++))
				do
					       sed -i '39s/$/\n/' $source/httpd/conf/extra/$domainname.conf
				done
				sed -i '39s#$#    SSLCertificateFile '$source'/httpd/ssl/'$domainname.crt'#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '40s#$#    SSLCertificateKeyFile '$source'/httpd/ssl/'$domainname.key'#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '41s#$#    CustomLog logs/ssl_request_log \\#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '42s#$#    "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \\"%r\\" %b"#'  $source/httpd/conf/extra/$domainname.conf
				sed -i '43s#$#</VirtualHost>#'  $source/httpd/conf/extra/$domainname.conf
				mkdir -p $source/httpd/ssl
				cd $source/httpd/ssl
				openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout toandaica.vn.key -out toandaica.vn.crt
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
					sed -i '42s/$/Listen 443/' $source/httpd/conf/httpd.conf
					sed -i '119s/Deny/Allow/'  $source/httpd/conf/httpd.conf
        				sed -i '405s/#Include/Include/'  $source/httpd/conf/httpd.conf
					sed -i '405s/httpd-vhosts/'$domainname'/'  $source/httpd/conf/httpd.conf
					mv $source/httpd/conf/extra/httpd-vhosts.conf $source/httpd/conf/extra/$domainname.conf
					sed -i '19s/80/'$port'/g'  $source/httpd/conf/extra/$domainname.conf
					sed -i '20s#$#NameVirtualHost *:443#' $source/httpd/conf/extra/$domainname.conf
					sed -i '27s/80/'$port'/'  $source/httpd/conf/extra/$domainname.conf
					sed -i '29s#'$source'/httpd/docs/dummy-host.example.com#'$document_root'#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '30,33s/dummy-host.example.com/'$domainname'/'  $source/httpd/conf/extra/$domainname.conf
					sed -i '34s#</VirtualHost>#    RewriteEngine On#' $source/httpd/conf/extra/$domainname.conf
					sed -i '35s#$#    RewriteCond %{HTTPS} off#' $source/httpd/conf/extra/$domainname.conf
					sed -i '36s#<VirtualHost #    #'  $source/httpd/conf/extra/$domainname.conf
					sed -i '36s#*:80>#RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '37s#ServerAdmin webmaster@dummy-host2.example.com#</VirtualHost>#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '38s#DocumentRoot "'$source'/httpd/docs/dummy-host2.example.com"#<VirtualHost *:443>#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '39s#ServerName dummy-host2.example.com#DocumentRoot "'$document_root'"#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '40s#ErrorLog "logs/dummy-host2.example.com-error_log"#ServerName '$domainname':443#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '41s#CustomLog "logs/dummy-host2.example.com-access_log" common#FastCGIExternalServer '$source'/php/sbin/php-fpm -host 127.0.0.1:9000#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '42s#</VirtualHost>#    AddHandler php-fpm .php#'  $source/httpd/conf/extra/$domainname.conf
					for ((i=0;i<=9;i++))
					do
					       sed -i '43s/$/\n/' $source/httpd/conf/extra/$domainname.conf
					done
					sed -i '43s#$#    Action php-fpm \/php.fcgi#'  $source/httpd/conf/extra/$domainname.conf	
					sed -i '44s#$#    Alias /php.fcgi '$source'/php/sbin/php-fpm#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '45s#$#    DirectoryIndex index.php index.html#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '46s#$#    <FilesMatch "\.php$">#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '47s#$#    SetHandler php-fpm#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '48s#$#    </FilesMatch>#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '49s#$#    SSLEngine on#' $source/httpd/conf/extra/$domainname.conf
					sed -i '50s#$#    SSLCertificateFile '$source'/httpd/ssl/'$domainname.crt'#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '51s#$#    SSLCertificateKeyFile '$source'/httpd/ssl/'$domainname.key'#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '52s#$#    CustomLog logs/ssl_request_log \\#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '53s#$#    "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \\"%r\\" %b"#'  $source/httpd/conf/extra/$domainname.conf
					sed -i '54s#$#</VirtualHost>#'  $source/httpd/conf/extra/$domainname.conf
					mkdir -p $source/httpd/ssl 
					cd $source/httpd/ssl
					openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout toandaica.vn.key -out toandaica.vn.crt
					sed -i '117,152s/None/All/'  $source/httpd/conf/httpd.conf
					$source/httpd/bin/httpd
					netstat -ntpl
				fi
			fi
		fi
	}
# Invoke your function
echo "Nhap 1 trong cac du lieu sau day"
apache $version_apache $version_apr $version_apr_util $source $domainname $port $document_root
