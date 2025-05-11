#!/bin/bash

if [[ $(id -u) -ne 0 ]]; then
   echo "Ошибка: Скрипт должен быть запущен с правами root."
   exit 1
fi

lsblk

echo "Справочная информация - для raid 1 и 0  2 диска  для raid 5 - необходимо от 3 дисков , для raid 10(1+0) от 4 дисков"

raidtype ()
{
read -p "Укажите тип рэйда(0,1,5,6,10): " Raid

}

raidtype


checkraid ()
{
if [[ $Raid != 0 ]]; then
    if [[ $Raid != 1 ]]; then
        if [[ $Raid != 5 ]]; then
            if [[ $Raid != 6 ]]; then
               if [[ $Raid != 10 ]] ;then
                echo "Указан некорректный тип Raid"
                raidtype
                checkraid
                fi
            fi
        fi
    fi
fi
}
checkraid

read -p "Укажите количество дисков: " num_disks
read -p "Введите имена дисков через пробел: " Disk_names

Disks=($Disk_names)

echo "${Disks[*]}"

echo  $Raid
if [[ $Raid -le 1 ]]; then
    if [[ $num_disks -ge 3 ]]; then
        echo "Ошибка, количество дисков не подходит для данного типа Raid"
    else
        mdadm --create --verbose /dev/md0 -l $Raid -n $num_disks ${Disks[*]}
    fi
elif [[ $Raid == 5 ]]; then
    if [[ $num_disks -le 2 ]]; then
        echo "Ошибка, количество дисков не подходит для данного типа Raid"
    else
        mdadm --create --verbose /dev/md0 -l $Raid -n $num_disks ${Disks[*]}
    fi
else
    if [[ $num_disks -le 3 ]]; then
        echo "Ошибка, количество дисков не подходит для данного типа Raid"
    else
        mdadm --create --verbose /dev/md0 -l $Raid -n $num_disks ${Disks[*]}
    fi
fi


echo  "Raid "$Raid"  успешно создан"
cat /proc/mdstat
mdadm -D /dev/md0
