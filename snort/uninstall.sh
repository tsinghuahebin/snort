#!/bin/bash

source variable.sh

sudo userdel snort
sudo groupdel snort

rm -rf ${log_url}
rm -rf ${snort_install_dir}
rm -rf /var/log/snort/
rm -rf /usr/local/lib/snort_dynamicrules
rm -rf /var/log/barnyard2/
rm -f /usr/sbin/snort

echo "drop database snort" | mysql -uroot -p1234qwer

echo "#####################################################"
cd ${base_url}/src/snort-2.9.7.5
make uninstall > /dev/null 2>&1
make clean > /dev/null 2>&1

cd ${base_url}/src/daq-2.06
make uninstall > /dev/null 2>&1
make clean > /dev/null 2>&1

cd ${base_url}/src/barnyard2-2-1.13
make uninstall > /dev/null 2>&1
make clean > /dev/null 2>&1

rm -f /usr/local/bin/pulledpork.pl

#sudo pear uninstall -f Image_Graph
rm -rf /var/adodb
rm -rf /var/www/html/base/

rm -f /etc/init/snort.conf
rm -f /etc/init/barnyard2.conf

echo "1111111111111111111111111111111111111111111111111111111111"
rm -rf ${base_url}/src/daq-2.0.6/
rm -rf ${base_url}/src/snort-2.9.7.5/
rm -rf ${base_url}/src/barnyard2-2-1.13/
rm -rf ${base_url}/src/adodb5/
rm -rf ${base_url}/src/base-1.4.5/
