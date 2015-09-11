#!/bin/bash
# Function: install snort as an IPS or an IDS
# Version: 1.0
# Date: 2015/09/08 9:05

sudo groupadd snort
sudo useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort
source variable.sh
source dir_configure.sh
# Variable defination
#base_url=$(cd "$(dirname "$0")"; pwd)
#base_url=`pwd`
#log_url='/var/log/snort_install'


function prepare(){
	sudo apt-get update
	sudo apt-get upgrade -y
	sudo apt-get install -y build-essential libpcap-dev libpcre3-dev libdumbnet-dev bison flex zlib1g-dev \
		mysql-server libmysqlclient-dev mysql-client autoconf libtool libcrypt-ssleay-perl liblwp-useragent-determined-perl \
		apache2 libapache2-mod-php5 php5 php5-mysql php5-common php5-gd php5-cli php-pear tree ethtool
	
	sudo ifconfig from_iface promisc
	sudo ifconfig to_iface promisc
	
	sudo ethtool -K from_iface gro off 
	sudo ethtool -K from_iface lro off
	sudo ethtool -K to_iface gro off
	sudo ethtool -K to_iface lro off

	sudo groupadd snort
	sudo useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort
}

function snort_install(){

#	sudo mkdir ${log_url}/ &&  chmod 754 ${log_url}/
	echo "...........Starting daq installation.........."
	sudo touch ${log_url}/daq_install.log && chmod 754 ${log_url}/daq_install.log
	echo `date` >> ${log_url}/daq_install.log
	cd ${base_url}/src 
	tar -zxvf daq-2.0.6.tar.gz >> ${log_url}/daq_install.log 2>&1
	cd daq-2.0.6 
	./configure >> ${log_url}/daq_install.log 2>&1
	make >> ${log_url}/daq_install.log 2>&1
	sudo make install >> ${log_url}/daq_install.log 2>&1
	echo ".............daq-2.0.6 is ok................."

	echo "...........Starting snort installation........."
	sudo touch ${log_url}/snort_install.log && chmod 754 ${log_url}/snort_install.log
	echo `date` >> ${log_url}/snort_install.log
	cd ${base_url}/src && tar -zxvf snort-2.9.7.5.tar.gz >> ${log_url}/snort_install.log 2>&1 && cd snort-2.9.7.5
	./configure --enable-sourcefire >> ${log_url}/snort_install.log 2>&1
	make  >> ${log_url}/snort_install.log 2>&1
	make install >> ${log_url}/snort_install.log 2>&1
	sudo ldconfig >> ${log_url}/snort_install.log 2>&1
	sudo ln -s /usr/local/bin/snort /usr/sbin/snort
	/usr/sbin/snort -V

	sudo cp ${base_url}/src/snort-2.9.7.5/etc/*.conf* /usr/local/etc/snort
	sudo cp ${base_url}/src/snort-2.9.7.5/etc/*.map /usr/local/etc/snort
	sudo rm -f /usr/local/etc/snort/snort.conf
	sudo cp ${base_url}/snort.conf /usr/local/etc/snort/snort.conf
	sudo chmod -R 777 /usr/local/etc/snort/
	sudo sed -i "s/include \$RULE\_PATH/#include \$RULE\_PATH/g" /usr/local/etc/snort/snort.conf
	sudo sed -i "s/ipvar HOME\_NET any/ipvar HOME\_NET ${home_net}/g" /usr/local/etc/snort/snort.conf
	sudo sed -i "s/ipvar EXTERNAL\_NET any/ipvar EXTERNAL\_NET ${external_net}/g" /usr/local/etc/snort/snort.conf
}

function barnyard2_install(){
	echo "..........Starting barnyard2 installarion........"
	cd ${base_url}/src
	tar -zxvf barnyard2-2-1.13.tar.gz > /dev/null 2>&1
	cd barnyard2-2-1.13
	autoreconf -fvi -I ./m4 > /dev/null 2>&1
	./configure --with-mysql --with-mysql-libraries=/usr/lib/x86_64-linux-gnu > /dev/null 2>&1
	make > /dev/null 2>&1
	sudo make install > /dev/null 2>&1
	sudo cp ${base_url}/barnyard2.conf /usr/local/etc/snort/barnyard2.conf
	sudo sed -i "s/password=1234qwer/password=${snort_database_passwd}/g" /usr/local/etc/snort/barnyard2.conf
	echo "create database snort;" | mysql -uroot -p1234qwer
	mysql -uroot -p1234qwer -D snort < ${base_url}/src/barnyard2-2-1.13/schemas/create_mysql
	echo "grant create, insert, select, delete, update on snort.* to snort@localhost identified by '1234qwer'" | mysql -uroot -p1234qwer
	chmod o-r /usr/local/etc/snort/barnyard2.conf
}

function pulledpork_install(){
	echo "..........Starting pulledpork installation........."
	cd ${base_url}/src/pulledpork
    sudo cp pulledpork.pl /usr/local/bin
	sudo chmod a+x /usr/local/bin/pulledpork.pl
	sudo cp etc/*.conf /usr/local/etc/snort
	sudo rm -f /usr/local/etc/snort/pulledpork.conf
	sudo cp ${base_url}/pulledpork.conf /usr/local/etc/snort/pulledpork.conf
	/usr/local/bin/pulledpork.pl -V
	sudo /usr/local/bin/pulledpork.pl -c /usr/local/etc/snort/pulledpork.conf -l
	sudo echo '* "^\s*alert" "DROP"' >> /usr/local/etc/snort/modifysid.conf
}

function base_install(){
	echo "...........Starting base installation............."
	sudo pear install -f Image_Graph > /dev/null 2>&1
	cd ${base_url}/src
	tar -xvzf adodb518.tgz > /dev/null 2>&1
	sudo mv adodb5 /var/adodb
	cd ${base_url}/src
	tar -zxvf base-1.4.5.tar.gz > /dev/null 2>&1
	sudo mv base-1.4.5 /var/www/html/base/
	cd /var/www/html/base
	sudo cp ${base_url}/base_conf.php /var/www/html/base/base_conf.php
	sudo chown -R www-data:www-data /var/www/html/base
	sudo chmod o-r /var/www/html/base/base_conf.php
	sudo sed -i "s/\$alert\_password = '';/\$alert\_password = '${snort_database_passwd}';/g" /var/www/html/base/base_conf.php
	sudo service apache2 restart > /dev/null 2>&1
}

function create_start_up_script(){
	sudo touch /etc/init/snort.conf
	sudo chmod 754 /etc/init/snort.conf
	echo "description \"Snort NIDS service\"" > /etc/init/snort.conf
	echo "stop on runlevel [!2345]" >> /etc/init/snort.conf
	echo "start on runlevel [2345]" >> /etc/init/snort.conf
	echo "script" >> /etc/init/snort.conf
	echo "	exec /usr/sbin/snort -q -u snort -g snort -c /usr/local/etc/snort/snort.conf -i ${from_iface}:${to_iface} -D" >> /etc/init/snort.conf
	echo "end script" >> /etc/init/snort.conf
	
	sudo touch /etc/init/barnyard2.conf
	sudo chmod 754 /etc/init/barnyard2.conf
	echo "description \"barnyard2 service\"" > /etc/init/barnyard2.conf
	echo "stop on runlevel [!2345]" >> /etc/init/barnyard2.conf
	echo "start on runlevel [2345]" >> /etc/init/barnyard2.conf
	echo "script" >> /etc/init/barnyard2.conf
	echo "	exec /usr/local/bin/barnyard2 -c /usr/local/etc/snort/barnyard2.conf -d /var/log/snort -f snort.log -w /var/log/snort/barnyard2.waldo -C /usr/local/etc/snort/classification.config -g snort -u snort -D" >> /etc/init/barnyard2.conf
	echo "end script" >> /etc/init/barnyard2.conf
}
# ================================Starting install========================
#prepare
snort_install
barnyard2_install
base_install
pulledpork_install
create_start_up_script
