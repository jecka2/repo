# Домашние задания по Otus


<details><summary><code><h2>01. Raid массивы</h2></code></summary><ul>

### Описание задания 

• Добавить в виртуальную машину несколько дисков

• Собрать RAID-0/1/5/10 на выбор

• Сломать и починить RAID

• Создать GPT таблицу, пять разделов и смонтировать их в системе.

На проверку отправьте:
скрипт для создания рейда, 
отчет по командам для починки RAID и созданию разделов.




<h2 align="center">Отчет</h2>

<br>
Отчет предоставлен в виде набора скриншотов  представленных ниже 

<br>

![Проверка создания Raid](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/Raid/%D0%9F%D1%80%D0%BE%D0%B2%D0%B5%D1%80%D0%BA%D0%B0%20Raid.png)

<br>
Согласно указанным выше данным мы создали  Raid массив из 5 дисков  тип Raid 6


![Отмечаем сбойный диск и удаляем его](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/Raid/Fail%26Remove.png)

Производим  отметку о том, что диск "сломан"  и удаляем его из дискового массива


![Добовление нового диска и ребилд рейда](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/Raid/Add%26Rebild.png) 

Производим добовление якобы "нового" диска взамен вышедшего из строя и система производит процесс восстановления массива

![Добовление нового диска и ребилд рейда](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/Raid/%D0%9F%D0%B0%D1%80%D1%82%D0%B8%D1%86%D0%B8%D0%B8.png)

Смонтированные партиции на новом рэйде

<h2 align="center">Скрипт</h2>

<details><summary> </code></summary><ul>

```bash
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

```
</ul>
</ul></details>


<details><summary><code><h2>Файловые системы и LVM - 1</h2></code></summary><ul>


### Описание задания 

• Настроить LVM в Ubuntu 24.04 Server

• Создать Physical Volume, Volume Group и Logical Volume

• Отформатировать и смонтировать файловую систему

• Расширить файловую систему за счёт нового диска

• Выполнить resize

• Проверить корректность работы

<h2 align="center">Отчет</h2>

<br>

<details><summary> </code></summary><ul>

```bash
Отчет  будет предоставлен в виде команд 


jecka@otus:~$ sudo lvmdiskscan
  /dev/sda2 [       2.00 GiB]
  /dev/sda3 [     <30.00 GiB] LVM physical volume
  /dev/sdb  [      10.00 GiB]
  /dev/sdc  [      10.00 GiB]
  /dev/sdd  [      10.00 GiB]
  /dev/sde  [      10.00 GiB]
  /dev/sdf  [      10.00 GiB]
  5 disks
  1 partition
  0 LVM physical volume whole disks
  1 LVM physical volume


jecka@otus:~$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.


jecka@otus:~$ sudo vgcreate otus  /dev/sdb
  Volume group "otus" successfully created

jecka@otus:~$ sudo lvcreate -l+80%FREE -n test otus
  Logical volume "test" created.
jecka@otus:~$ sudo vgdisplay otus
  --- Volume group ---
  VG Name               otus
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <10.00 GiB
  PE Size               4.00 MiB
  Total PE              2559
  Alloc PE / Size       2047 / <8.00 GiB
  Free  PE / Size       512 / 2.00 GiB
  VG UUID               4e0Z6l-RhZM-EVj4-gb3B-phEF-5xP5-dI2u8j


jecka@otus:~$ sudo vgdisplay -v otus | grep "PV Name"
  PV Name               /dev/sdb
jecka@otus:~$ sudo lvdisplay /dev/otus/test
  --- Logical volume ---
  LV Path                /dev/otus/test
  LV Name                test
  VG Name                otus
  LV UUID                shlaYs-8AAc-69Z0-dS3r-lyC9-edlc-Z9AVkT
  LV Write Access        read/write
  LV Creation host, time otus, 2025-05-17 21:29:50 +0000
  LV Status              available
  # open                 0
  LV Size                <8.00 GiB
  Current LE             2047
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           252:1



jecka@otus:~$ sudo lvcreate -l100M -n small otus
  Invalid argument for --extents: 100M
  Error during parsing of command line.
jecka@otus:~$ sudo lvcreate -L100M -n small otus
  Logical volume "small" created.
jecka@otus:~$ sudo mkfs.ext4 /dev/otus/test
mke2fs 1.47.0 (5-Feb-2023)
Discarding device blocks: done
Creating filesystem with 2096128 4k blocks and 524288 inodes
Filesystem UUID: 416e71ad-df98-4945-a83c-89a9d7fd14cf
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

jecka@otus:~$ sudo pvcreate /dev/sdc
  Physical volume "/dev/sdc" successfully created.
jecka@otus:~$ sudo vgextend otus /dev/sdc
  Volume group "otus" successfully extended
jecka@otus:~$ sudo vgdisplay -v otus | grep "PV Name"
  PV Name               /dev/sdb
  PV Name               /dev/sdc
jecka@otus:~$ dd if=/dev/zero of=/data/test.log bs=1M \
 count=8000 status=progress
dd: failed to open '/data/test.log': No such file or directory
jecka@otus:~$ df -h
Filesystem                         Size  Used Avail Use% Mounted on
tmpfs                              197M  1.1M  196M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv   15G  5.0G  9.0G  36% /
tmpfs                              984M     0  984M   0% /dev/shm
tmpfs                              5.0M     0  5.0M   0% /run/lock
/dev/sda2                          2.0G  185M  1.7G  11% /boot
tmpfs                              197M   12K  197M   1% /run/user/1000

ecka@otus:~$ sudo dd if=/dev/zero of=/mnt/test.log bs=1M  count=8000 status=progress
7917797376 bytes (7.9 GB, 7.4 GiB) copied, 13 s, 609 MB/s
dd: error writing '/mnt/test.log': No space left on device
7944+0 records in
7943+0 records out
8329297920 bytes (8.3 GB, 7.8 GiB) copied, 13.7498 s, 606 MB/s
jecka@otus:~$ sudo lvextend -l+80%FREE /dev/otus/test
  Size of logical volume otus/test changed from <8.00 GiB (2047 extents) to <17.52 GiB (4484 extents).
  Logical volume otus/test successfully resized.
jecka@otus:~$ lvs /dev/otus/test
  WARNING: Running as a non-root user. Functionality may be unavailable.
  /dev/mapper/control: open failed: Permission denied
  Failure to communicate with kernel device-mapper driver.
  Incompatible libdevmapper 1.02.185 (2022-05-18) and kernel driver (unknown version).
  /run/lock/lvm/V_otus:aux: open failed: Permission denied
  Can't get lock for otus.
  Cannot process volume group otus
jecka@otus:~$ sudo lvs /dev/otus/test
  LV   VG   Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  test otus -wi-ao---- <17.52g
jecka@otus:~$ df  -Th /mnt/
Filesystem            Type  Size  Used Avail Use% Mounted on
/dev/mapper/otus-test ext4  7.8G  7.8G     0 100% /mnt
jecka@otus:~$ sudo resize2fs /dev/otus/test
resize2fs 1.47.0 (5-Feb-2023)
Filesystem at /dev/otus/test is mounted on /mnt; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 3
The filesystem on /dev/otus/test is now 4591616 (4k) blocks long.

jecka@otus:~$ df  -Th /mnt/
Filesystem            Type  Size  Used Avail Use% Mounted on
/dev/mapper/otus-test ext4   18G  7.8G  8.6G  48% /mnt
jecka@otus:~$ sudo umount /mnt
jecka@otus:~$ sudo e2fsck -fy /dev/otus/test
e2fsck 1.47.0 (5-Feb-2023)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/otus/test: 12/1155072 files (0.0% non-contiguous), 2133660/4591616 blocks
jecka@otus:~$ resize2fs /dev/otus/test  10G
resize2fs 1.47.0 (5-Feb-2023)
open: Permission denied while opening /dev/otus/test
jecka@otus:~$ sudo resize2fs /dev/otus/test  10G
resize2fs 1.47.0 (5-Feb-2023)
Resizing the filesystem on /dev/otus/test to 2621440 (4k) blocks.
The filesystem on /dev/otus/test is now 2621440 (4k) blocks long.

jecka@otus:~$ sudo lvmreduce /dev/otus/test -L 10G
sudo: lvmreduce: command not found
jecka@otus:~$ sudo lvreduce /dev/otus/test -L 10G
  WARNING: Reducing active logical volume to 10.00 GiB.
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce otus/test? [y/n]: y
  Size of logical volume otus/test changed from <17.52 GiB (4484 extents) to 10.00 GiB (2560 extents).
  Logical volume otus/test successfully resized.
jecka@otus:~$ sudo mount /dev/otus/test /mnt
jecka@otus:~$ df -Th /mnt
Filesystem            Type  Size  Used Avail Use% Mounted on
/dev/mapper/otus-test ext4  9.8G  7.8G  1.6G  84% /mnt

jecka@otus:/msudo findmnt --verify --verbose
/
   [ ] target exists
   [ ] source /dev/disk/by-id/dm-uuid-LVM-eQHuGCwKkmF9rdmNAUEHoUANHpn0FKEsAunYNN504dyjFcaTLwYyCR9MVbrdN7PC exists
   [ ] FS type is ext4
/boot
   [ ] target exists
   [ ] source /dev/disk/by-uuid/82a2adc5-bd04-4577-b9c0-3e5d81794ef2 exists
   [ ] FS type is ext4
none
   [W] non-bind mount source /swap.img is a directory or regular file
   [ ] FS type is swap
/mnt
   [ ] target exists
   [ ] UUID=416e71ad-df98-4945-a83c-89a9d7fd14cf translated to /dev/mapper/otus-test
   [ ] source /dev/mapper/otus-test exists
   [ ] FS type is ext4

0 parse errors, 0 errors, 1 warning
jecka@otus:/mnt$ sudo cat /etc/fstab
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/ubuntu-vg/ubuntu-lv during curtin installation
/dev/disk/by-id/dm-uuid-LVM-eQHuGCwKkmF9rdmNAUEHoUANHpn0FKEsAunYNN504dyjFcaTLwYyCR9MVbrdN7PC / ext4 defaults 0 1
# /boot was on /dev/sda2 during curtin installation
/dev/disk/by-uuid/82a2adc5-bd04-4577-b9c0-3e5d81794ef2 /boot ext4 defaults 0 1
/swap.img       none    swap    sw      0       0
UUID=416e71ad-df98-4945-a83c-89a9d7fd14cf /mnt ext4 defaults 0 2
jecka@otus:/mnt$




```


