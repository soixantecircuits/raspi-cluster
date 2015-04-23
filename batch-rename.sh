#!/bin/bash
start_number=66
last_number=70
current_hostname='chow-chowXX'
new_prefix='chow-chow'
partition_path='/media/emmanuel/c1398422-7a7c-4863-8a8f-45a1db26b4f2'

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
}

for ((i=$start_number;i<=$last_number; i++))
  do rename $i
done
