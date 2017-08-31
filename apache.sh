#!/bin/bash
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
wget http://mirror.downloadvn.com/apache//httpd/$version_apache.tar.gz
if [ "$?" != 0 ] && [ -d $path_shell ] && [ ];then
        echo "Error download "
else
	tar xzvf $version_apache.tar.gz
	cd $version_apache/srclib
	wget https://apr.apache.org/download.cgi
	grep "http://mirrors.viethosting.com/apache//apr/" download.cgi
	echo -n "MOI BAN NHAP PHIEN BAN APR MOI NHAT O TREN THEO DANG apr-1.6.2 :"; read version_apr
	echo -n "MOI BAN NHAP PHIEN BAN APR MOI NHAT O TREN THEO DANG apr-util-1.6.0 :";read version_apr_util
	wget http://mirror.downloadvn.com/apache//apr/$version_apr.tar.gz
	wget http://mirror.downloadvn.com/apache//apr/$version_apr_util.tar.gz
	tar -xvzf $version_apr.tar.gz
	mv $version_apr apr
	tar -xvzf $version_apr_util.tar.gz
	mv $version_apr_util apr-util
	echo -n "Nhap duong dan chua file cai dat apache:"; read apache_source
	echo -n "Nhap thong so domainname: "; read domainname
        echo -n "Nhap thong so port:";read port
        echo -n "Nhap thong so document_root:";read document_root
	#Tao duong dan document root
        mkdir -p $document_root
	cd ..
	./configure --prefix=$apache_source/httpd --enable-so --enable-deflate --enable-expires --enable-headers --enable-rewrite --with-included-apr --with-included-apr-util
	make -j 2
	make install
	sed -i 's/Listen 80/Listen '$port'/' $apache_source/httpd/conf/httpd.conf
	sed -i 's/User daemon/User apache/' $apache_source/httpd/conf/httpd.conf
	sed -i 's/Group daemon/Group apache/' $apache_source/httpd/conf/httpd.conf
        sed -i 's/#ServerName/ServerName/' $apache_source/httpd/conf/httpd.conf
	sed -i 's#www.example.com:80#'$domainname'#' $apache_source/httpd/conf/httpd.conf
        sed -i 's#'$apache_source'/httpd/htdocs#'$document_root'#' $apache_source/httpd/conf/httpd.conf
	chown -R apache:apache $document_root
        netstat -ntpl
        #Tao file index de test
        touch $document_root/index.html
        echo toandeptrai >> $document_root/index.html
	echo "qua trinh cai dat da xong, bat dau qua trinh khoi dong apache:"
	n=`echo $version_apache | cut -d . -f 1,2`
        if [ $n == httpd-2.2 ]; then
                #phien ban 2.2
                $apache_source/httpd/bin/httpd
        else
                #phien ban 2.4
                $apache_source/httpd/bin/apachectl
        fi
        bien=`ifconfig`
        ip=`echo $bien | cut -c 61-75`
        links $ip:$port
fi
#chmod +x /etc/init.d/httpd
#chkconfig httpd on
#service httpd start
#service httpd stop
#netstat -ntpl
#service httpd restart
