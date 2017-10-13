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
	link_apache=`curl -L https://httpd.apache.org/download.cgi | grep tar.gz | grep 'httpd-2.4' | grep -v "MD5\|PGP\|SHA1\|SHA256" | awk -F '"' '{print $2}'` 
	version_apache=`echo $link_apache| rev| cut -d'/' -f1 | rev`
	link_download_apache=$link_apache
	wget $link_download_apache
	if [ "$?" != 0 ] && [ -d $path_shell ] && [ ];then
        	echo "Error download "
	else
        	cd `tar -xzvf $version_apache`
        	cd srclib
        	link_apr=`curl -L https://apr.apache.org/download.cgi | grep tar.gz | grep 'apr-1' | grep -v "MD5\|PGP\|SHA1\|SHA256" | awk -F '"' '{print $2}'`
		version_apr=`echo $link_apr| rev| cut -d'/' -f1 | rev`
		wget $link_apr
		link_apr_util=`curl -L https://apr.apache.org/download.cgi | grep tar.gz | grep 'apr-util-1' | grep -v "MD5\|PGP\|SHA1\|SHA256" | awk -F '"' '{print $2}'`
		version_apr_util=`echo $link_apr_util| rev| cut -d'/' -f1 | rev`
		wget $link_apr_util
		tar -xvzf $version_apr
                tar -xvzf $version_apr_util
                mv apr-1.6.2 apr
                mv apr-util-1.6.0 apr-util
		#Tao duong dan document root
        	mkdir -p $4
		cd ..
        	./configure --prefix=$1/httpd --enable-so --enable-deflate --enable-expires --enable-ssl --enable-headers --enable-rewrite --with-included-apr --with-included-apr-util
        	make -j 2
        	make install
        	sed -i 's/Listen 80/Listen '$3'/' $1/httpd/conf/httpd.conf
        	sed -i 's/User daemon/User apache/' $1/httpd/conf/httpd.conf
        	sed -i 's/Group daemon/Group apache/' $1/httpd/conf/httpd.conf
        	sed -i 's/#ServerName/ServerName/' $1/httpd/conf/httpd.conf
        	sed -i 's#www.example.com:80#'$2'#' $1/httpd/conf/httpd.conf
        	sed -i 's#'$1'/httpd/htdocs#'$4'#' $1/httpd/conf/httpd.conf
        	echo "qua trinh cai dat da xong, bat dau qua trinh khoi dong apache:"
        	n=`echo $version_apache | cut -d . -f 1,2`
        	if [ $n == httpd-2.4 ]; then
				#phien ban 2.4
				echo "cau hinh apache-2.4 chay php:"
				sed -i '53s/$/Listen 443/' $1/httpd/conf/httpd.conf 
				sed -i '132s/#LoadModule ssl_module/LoadModule ssl_module/' $1/httpd/conf/httpd.conf
				sed -i '151s/#LoadModule rewrite_module/LoadModule rewrite_module/' $1/httpd/conf/httpd.conf
				sed -i '476s/#Include/Include/'  $1/httpd/conf/httpd.conf
				sed -i '476s/httpd-vhosts/'$2'/'  $1/httpd/conf/httpd.conf
				mv $1/httpd/conf/extra/httpd-vhosts.conf $1/httpd/conf/extra/$2.conf
				echo "ProxyPassMatch ^/(.*\\.php(/.*)?)$ fcgi://127.0.0.1:9000$4/'$1'" >> $1/httpd/conf/httpd.conf
				sed -i '116s/#LoadModule proxy_module modules\/mod_proxy.so/LoadModule proxy_module modules\/mod_proxy.so/'  $1/httpd/conf/httpd.conf
				sed -i '120s/#LoadModule proxy_fcgi_module modules\/mod_proxy_fcgi.so/LoadModule proxy_fcgi_module modules\/mod_proxy_fcgi.so/'  $1/httpd/conf/httpd.conf
				sed -i '251s/index.html/index.php index.html/'  $1/httpd/conf/httpd.conf
				sed -i '23s/80/'$3'/'  $1/httpd/conf/extra/$2.conf
				sed -i '25s#'$1'/httpd/docs/dummy-host.example.com#'$4'#'  $1/httpd/conf/extra/$2.conf
				sed -i '26,29s/dummy-host.example.com/'$2'/'  $1/httpd/conf/extra/$2.conf
				sed -i '30s#</VirtualHost>#    RewriteEngine On#' $1/httpd/conf/extra/$2.conf
				sed -i '31s#$#    RewriteCond %{HTTPS} off#' $1/httpd/conf/extra/$2.conf
				sed -i '32s#<VirtualHost #    #'  $1/httpd/conf/extra/$2.conf
				sed -i '32s#*:80>#RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}#'  $1/httpd/conf/extra/$2.conf
				sed -i '33s#ServerAdmin webmaster@dummy-host2.example.com#</VirtualHost>#'  $1/httpd/conf/extra/$2.conf
				sed -i '34s#DocumentRoot "'$1'/httpd/docs/dummy-host2.example.com"#<VirtualHost *:443>#'  $1/httpd/conf/extra/$2.conf
				sed -i '35s#ServerName dummy-host2.example.com#DocumentRoot "'$4'"#'  $1/httpd/conf/extra/$2.conf
				sed -i '36s#ErrorLog "logs/dummy-host2.example.com-error_log"#ServerName '$2':443#'  $1/httpd/conf/extra/$2.conf
				sed -i '37s#CustomLog "logs/dummy-host2.example.com-access_log" common#    DirectoryIndex index.php index.html#'$1'/php/sbin/php-fpm -host 127.0.0.1:9000#'  $1/httpd/conf/extra/$2.conf
				sed -i '38s#</VirtualHost>#    SSLEngine on#'  $1/httpd/conf/extra/$2.conf
				for ((i=0;i<=9;i++))
				do
					       sed -i '39s/$/\n/' $1/httpd/conf/extra/$2.conf
				done
				sed -i '39s#$#    SSLCertificateFile '$1'/httpd/ssl/'$2.crt'#'  $1/httpd/conf/extra/$2.conf
				sed -i '40s#$#    SSLCertificateKeyFile '$1'/httpd/ssl/'$2.key'#'  $1/httpd/conf/extra/$2.conf
				sed -i '41s#$#    CustomLog logs/ssl_request_log \\#'  $1/httpd/conf/extra/$2.conf
				sed -i '42s#$#    "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \\"%r\\" %b"#'  $1/httpd/conf/extra/$2.conf
				sed -i '43s#$#</VirtualHost>#'  $1/httpd/conf/extra/$2.conf
				mkdir -p $1/httpd/ssl
				cd $1/httpd/ssl
				openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout toandaica.vn.key -out toandaica.vn.crt
				$1/httpd/bin/apachectl
				touch $4/index.html
	    			echo "toandaica" >> $4/index.html
	    			chown -R apache:apache $4
            			$1/php/sbin/php-fpm
            			IF=`route | grep default | awk '{print $8}'`
            			ip=`ip a | grep $IF | grep inet | awk '{print $2}' | cut -d / -f 1`
				echo $ip
            			links $ip
			else
				#phien ban 2.2
				echo "cau hinh apache-2.2 chay php:"
				if [ "$?" != 0 ] && [ -d $path_shell ] && [ ];then
						echo "Error download "
				else
					wget https://github.com/whyneus/magneto-ponies/raw/master/mod_fastcgi-SNAP-0910052141.tar.gz
					tar xzvf mod_fastcgi*
					cd mod_fastcgi-*
					make -f Makefile.AP2 top_dir=$1/httpd
					cp .libs/mod_fastcgi.so $1/httpd/modules/
					echo "LoadModule fastcgi_module $1/httpd/modules/mod_fastcgi.so" >> $1/httpd/conf/httpd.conf
					sed -i '42s/$/Listen 443/' $1/httpd/conf/httpd.conf
					sed -i '119s/Deny/Allow/'  $1/httpd/conf/httpd.conf
        				sed -i '405s/#Include/Include/'  $1/httpd/conf/httpd.conf
					sed -i '405s/httpd-vhosts/'$2'/'  $1/httpd/conf/httpd.conf
					mv $1/httpd/conf/extra/httpd-vhosts.conf $1/httpd/conf/extra/$2.conf
					sed -i '19s/80/'$3'/g'  $1/httpd/conf/extra/$2.conf
					sed -i '20s#$#NameVirtualHost *:443#' $1/httpd/conf/extra/$2.conf
					sed -i '27s/80/'$3'/'  $1/httpd/conf/extra/$2.conf
					sed -i '29s#'$1'/httpd/docs/dummy-host.example.com#'$4'#'  $1/httpd/conf/extra/$2.conf
					sed -i '30,33s/dummy-host.example.com/'$2'/'  $1/httpd/conf/extra/$2.conf
					sed -i '34s#</VirtualHost>#    RewriteEngine On#' $1/httpd/conf/extra/$2.conf
					sed -i '35s#$#    RewriteCond %{HTTPS} off#' $1/httpd/conf/extra/$2.conf
					sed -i '36s#<VirtualHost #    #'  $1/httpd/conf/extra/$2.conf
					sed -i '36s#*:80>#RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}#'  $1/httpd/conf/extra/$2.conf
					sed -i '37s#ServerAdmin webmaster@dummy-host2.example.com#</VirtualHost>#'  $1/httpd/conf/extra/$2.conf
					sed -i '38s#DocumentRoot "'$1'/httpd/docs/dummy-host2.example.com"#<VirtualHost *:443>#'  $1/httpd/conf/extra/$2.conf
					sed -i '39s#ServerName dummy-host2.example.com#DocumentRoot "'$4'"#'  $1/httpd/conf/extra/$2.conf
					sed -i '40s#ErrorLog "logs/dummy-host2.example.com-error_log"#ServerName '$2':443#'  $1/httpd/conf/extra/$2.conf
					sed -i '41s#CustomLog "logs/dummy-host2.example.com-access_log" common#FastCGIExternalServer '$1'/php/sbin/php-fpm -host 127.0.0.1:9000#'  $1/httpd/conf/extra/$2.conf
					sed -i '42s#</VirtualHost>#    AddHandler php-fpm .php#'  $1/httpd/conf/extra/$2.conf
					for ((i=0;i<=9;i++))
					do
					       sed -i '43s/$/\n/' $1/httpd/conf/extra/$2.conf
					done
					sed -i '43s#$#    Action php-fpm \/php.fcgi#'  $1/httpd/conf/extra/$2.conf	
					sed -i '44s#$#    Alias /php.fcgi '$1'/php/sbin/php-fpm#'  $1/httpd/conf/extra/$2.conf
					sed -i '45s#$#    DirectoryIndex index.php index.html#'  $1/httpd/conf/extra/$2.conf
					sed -i '46s#$#    <FilesMatch "\.php$">#'  $1/httpd/conf/extra/$2.conf
					sed -i '47s#$#    SetHandler php-fpm#'  $1/httpd/conf/extra/$2.conf
					sed -i '48s#$#    </FilesMatch>#'  $1/httpd/conf/extra/$2.conf
					sed -i '49s#$#    SSLEngine on#' $1/httpd/conf/extra/$2.conf
					sed -i '50s#$#    SSLCertificateFile '$1'/httpd/ssl/'$2.crt'#'  $1/httpd/conf/extra/$2.conf
					sed -i '51s#$#    SSLCertificateKeyFile '$1'/httpd/ssl/'$2.key'#'  $1/httpd/conf/extra/$2.conf
					sed -i '52s#$#    CustomLog logs/ssl_request_log \\#'  $1/httpd/conf/extra/$2.conf
					sed -i '53s#$#    "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \\"%r\\" %b"#'  $1/httpd/conf/extra/$2.conf
					sed -i '54s#$#</VirtualHost>#'  $1/httpd/conf/extra/$2.conf
					mkdir -p $1/httpd/ssl 
					cd $1/httpd/ssl
					openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout toandaica.vn.key -out toandaica.vn.crt
					sed -i '117,152s/None/All/'  $1/httpd/conf/httpd.conf
					$1/httpd/bin/httpd
					netstat -ntpl
				fi
			fi
		fi
	}
# Invoke your function
echo "Nhap 1 trong cac du lieu sau day: source, domainname, port, document_root"
apache $version_apache $version_apr $version_apr_util $1 $2 $3 $4

