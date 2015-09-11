#!/bin/bash

# intall log dir and logfile
sudo mkdir ${log_url}/
sudo chmod -R 7777 ${log_url}/
sudo touch ${log_url}/snort_install.log
sudo chmod -R 7777 ${log_url}/snort_install.log
sudo touch ${log_url}/barnyard2_install.log
sudo chmod -R 7777 ${log_url}/barnyard2_install.log
sudo touch ${log_url}/pulledpork_install.log
sudo chmod -R 7777 ${log_url}/pulledpork_install.log
sudo touch ${log_url}/base_install.log
sudo chmod -R 7777 ${log_url}/base_install.log

# snort installed dir
sudo mkdir /usr/local/etc/snort
sudo mkdir /usr/local/etc/snort/rules
sudo mkdir /var/log/snort
sudo mkdir /usr/local/lib/snort_dynamicrules
sudo mkdir /usr/local/etc/snort/preproc_rules

sudo touch /usr/local/etc/snort/rules/white_list.rules
sudo touch /usr/local/etc/snort/rules/black_list.rules
sudo touch /usr/local/etc/snort/rules/local.rules
sudo touch /usr/local/etc/snort/rules/snort.rules
sudo touch /usr/local/etc/snort/sid-msg.map

sudo chmod -R 5775 /usr/local/etc/snort
sudo chmod -R 5775 /var/log/snort
sudo chmod -R 5775 /usr/local/lib/snort_dynamicrules

sudo chown -R snort:snort /usr/local/etc/snort
sudo chown -R snort:snort /var/log/snort
sudo chown -R snort:snort /usr/local/lib/snort_dynamicrules

# barnyard2 dir
sudo mkdir /var/log/barnyard2
sudo chown snort:snort /var/log/barnyard2
sudo touch /var/log/snort/barnyard2.waldo
sudo chown snort:snort /var/log/snort/barnyard2.waldo

# pulledpork
sudo mkdir /usr/local/etc/snort/rules/iplists
sudo touch /usr/local/etc/snort/rules/iplists/default.blacklist
