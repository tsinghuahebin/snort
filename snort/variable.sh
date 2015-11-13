#!/bin/bash
# Define all the variables when installing snort needed

# Tranfic from from_iface to to_iface
from_iface='eth0'
to_iface='eth1'
base_url=$(cd "$(dirname "$0")"; pwd)
#base_url=`dirname "$0"`
log_url='/var/log/snort_install_log'
snort_install_dir='/usr/local/etc/snort'
home_net='192.168.23.0\/24'
external_net='!$HOME_NET'
snort_database_passwd='1234qwer'
