#!/bin/bash
start_number=18
last_number=23
current_hostname='snapboxXX'
new_prefix='snapbox'
partition_path='/media/mina/f39781f6-b968-4738-93ef-4d1af6861b99'
current_ip='10.60.60.5'
ip_prefix='10.60.60.'

function rename {
  number=$1
  partition_postfix=$(($number-$start_number))
  if [ "$partition_postfix" -eq "0" ];
  then
    partition_postfix=''
  fi
  echo $partition_path${partition_postfix}
  echo $new_prefix${number}
  sudo sed -i "s/$current_hostname/$new_prefix${number}/" $partition_path${partition_postfix}/etc/hosts $partition_path${partition_postfix}/etc/hostname
  sudo sed -i "s/$current_ip/$ip_prefix${number}/" $partition_path${partition_postfix}/etc/network/interfaces
}

for ((i=$start_number;i<=$last_number; i++))
  do rename $i
done
