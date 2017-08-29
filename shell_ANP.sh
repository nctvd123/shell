#!bin/bash
echo "1.Apache"
echo "2.Nginx"
echo "3.Php-fpm"
echo "4.Apache va php-fpm"
echo "5.Nginx va php-fpm"
echo -n "Moi ban nhap 1 trong cac so o tren de cai dat phan mem mong muon :";read n
path_shell=/root/scripts/static
if [ ! -d $path_shell ];then
        mkdir -p $path_shell
fi
while [ $n -eq 1 ]
do
	echo "CAI DAT APACHE"	
	mv apache.sh $path_shell
	cd $path_shell
	./apache.sh
	break
done
while [ $n -eq 2 ]
do
        echo "CAI DAT NGINX"
	mv nginx.sh $path_shell
        cd $path_shell
        ./nginx.sh
        break
done
while [ $n -eq 3 ]
do
        echo "CAI DAT PHP-FPM"
	mv nginx.sh $path_shell
        cd $path_shell
        ./php.sh
        break
done
while [ $n -eq 4 ]
do
        echo "CAI DAT APACHE VA PHP-FPM"
	mv apache_php.sh $path_shell
        cd $path_shell
        ./apache_php.sh
        break
done
while [ $n -eq 5 ]
do
        echo "CAI DAT NGINX VA PHP-FPM"
	mv nginx_php.sh $path_shell
        cd $path_shell
        ./nginx_php.sh
        break
done

