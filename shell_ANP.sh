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
        sh apache.sh
        break
done
while [ $n -eq 2 ]
do      
        sh nginx.sh
        break
done
while [ $n -eq 3 ]
do
        sh php.sh
        break
done
while [ $n -eq 4 ]
do
        sh apache_php.sh
        break
done
while [ $n -eq 5 ]
do
        sh nginx_php.sh
        break
done
