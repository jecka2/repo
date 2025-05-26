# Домашние задания по Otus

<details><summary><code>01.Raid массивы </code></summary>

### Описание задания

• Добавить в виртуальную машину несколько дисков

• Собрать RAID-0/1/5/10 на выбор

• Сломать и починить RAID

• Создать GPT таблицу, пять разделов и смонтировать их в системе.

На проверку отправьте:
скрипт для создания рейда,
отчет по командам для починки RAID и созданию разделов.

<h2 align="center">Отчет</h2>

Отчет предоставлен в виде набора скриншотов  представленных ниже

![Проверка создания Raid](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/Raid/%D0%9F%D1%80%D0%BE%D0%B2%D0%B5%D1%80%D0%BA%D0%B0%20Raid.png)

Согласно указанным выше данным мы создали  Raid массив из 5 дисков  тип Raid 6

![Отмечаем сбойный диск и удаляем его](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/Raid/Fail%26Remove.png)

Производим  отметку о том, что диск "сломан"  и удаляем его из дискового массива

![Добовление нового диска и ребилд рейда](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/Raid/Add%26Rebild.png)

Производим добовление якобы "нового" диска взамен вышедшего из строя и система производит процесс восстановления массива

![Добовление нового диска и ребилд рейда](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/Raid/%D0%9F%D0%B0%D1%80%D1%82%D0%B8%D1%86%D0%B8%D0%B8.png)

Смонтированные партиции на новом рэйде

<h2 align="center">Скрипт</h2>

<ul>
<li><details><summary>Скрипт</summary>

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

</li>
</details> </ul>
</details>

<details><summary><code>02.Файловые системы и LVM</code></summary>

### Описание задания

• Настроить LVM в Ubuntu 24.04 Server

• Создать Physical Volume, Volume Group и Logical Volume

• Отформатировать и смонтировать файловую систему

• Расширить файловую систему за счёт нового диска

• Выполнить resize

• Проверить корректность работы

<h2 align="center">Отчет</h2>

<br>

### Работа с LVM

## Отчет  будет предоставлен в виде команд и ответа системы

<br>

```bash

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

```

### Создаем Physical Volume

```bash

jecka@otus:~$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.

```

### Создаем Volume Group

```bash
jecka@otus:~$ sudo vgcreate otus  /dev/sdb
  Volume group "otus" successfully created
```

### Создаем Logical Voilume размером 80% ( свободного места ) от  размера Volum Group и показываем его свойства

```bash
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

```

### Создаем дополнительный Logical Volume размером 100M с последующим созданием на нем файловой системы ext4  

```bash
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
```

### Создание Pysical Volume и расширение Volume Group при помощи созданного Pysical Volume

```bash
jecka@otus:~$ sudo pvcreate /dev/sdc
  Physical volume "/dev/sdc" successfully created.
jecka@otus:~$ sudo vgextend otus /dev/sdc
  Volume group "otus" successfully extended
jecka@otus:~$ sudo vgdisplay -v otus | grep "PV Name"
  PV Name               /dev/sdb
  PV Name               /dev/sdc
```

### Проводится расширение Logical Volume  за счет свободного простарства c последующим увеличением файловой системы на появивщееся простраснство

```bash
jecka@otus:~$ sudo lvextend -l+80%FREE /dev/otus/test
  Size of logical volume otus/test changed from <8.00 GiB (2047 extents) to <17.52 GiB (4484 extents).
  Logical volume otus/test successfully resized.

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
```

### Уменьшение файловой системы с последующим уменьшением размера Logical Volume

```bash
jecka@otus:~$ sudo umount /mnt
jecka@otus:~$ sudo e2fsck -fy /dev/otus/test
e2fsck 1.47.0 (5-Feb-2023)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/otus/test: 12/1155072 files (0.0% non-contiguous), 2133660/4591616 blocks

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
```

### Настройка монитрования дисков в данном случае Logical Volume  otus-test

```bash
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
```

</ul></details>
<details><summary><code>05.ZFS </code></summary>


### Описание задания

Определить алгоритм с наилучшим сжатием:
Определить какие алгоритмы сжатия поддерживает zfs (gzip, zle, lzjb, lz4);
создать 4 файловых системы на каждой применить свой алгоритм сжатия;
для сжатия использовать либо текстовый файл, либо группу файлов.
Определить настройки пула.
С помощью команды zfs import собрать pool ZFS.
Командами zfs определить настройки:
   
- размер хранилища;
    
- тип pool;
    
- значение recordsize;
   
- какое сжатие используется;
   
- какая контрольная сумма используется.
Работа со снапшотами:
скопировать файл из удаленной директории;
восстановить файл локально. zfs receive;
найти зашифрованное сообщение в файле secret_message.

### Описание выполнения

#### 1. Создание ZFS Пулов

```bash
jecka@otus:~$ sudo zpool create gzip mirror /dev/sdb /dev/sdc
jecka@otus:~$ sudo zpool create zle mirror /dev/sdd /dev/sde
jecka@otus:~$ sudo zpool create lzjb mirror /dev/sdf /dev/sdg
jecka@otus:~$ sudo zpool create gzip mirror /dev/sdb /dev/sdc
jecka@otus:~$ sudo zpool create zle mirror /dev/sdd /dev/sde
```
#### 1.1 Выводим информацию  о созданных  пулах  используя команду 

```bash
sudo zpool list
```
 ![Результат выполннения запроса на  предоставления данных  о созданных ZFS пулах](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/Zfs/zpool%20list.jpg)

#### 1.2 Включаем компрессию на zfs пулах

```bash
jecka@otus:~$ sudo zfs set compression=gzip-9 gzip
jecka@otus:~$ sudo zfs set compression=lz4 lz4
jecka@otus:~$ sudo zfs set compression=lzjb lzjb
jecka@otus:~$ sudo zfs set compression=zle zle

```
 ![Результат выполннения запроса  о включенной компресии](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/Zfs/compression.jpg)

#### 1.3 Выясняем какая компрессия лучше 

Скачиваем один и тот же файл на разные ZFS пулы. После скачивания проверям какой обьем был использован


```bash
jecka@otus:/$ zfs list
jecka@otus:/$ zfs get all | grep compressratio | grep -v ref
```
![Результат выполннения запроса  о занятом пространстве и  компресии](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/Zfs/zip.jpg)


По результатам указанным выше мы узнаем, что компресиия gzip-9 явялется в данном случае лучшей, так как файл занимает меньше места.


### 2. Определение настроек пула

#### 2.1 Импорт пула 

Скачивем "образ" пула и  разворачиваем в нашей системе 

![Результат выполннения запроса  о занятом пространстве и  компресии](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/Zfs/Import%20ZFS%20Pools.png)



#### 2.2 Пулчаем параметры ZFS пула

```bash
jecka@otus:~/zpoolexport$ zpool get all otus
NAME  PROPERTY                       VALUE                          SOURCE
otus  size                           480M                           -
otus  capacity                       0%                             -
otus  altroot                        -                              default
otus  health                         ONLINE                         -
otus  guid                           6554193320433390805            -
otus  version                        -                              default
otus  bootfs                         -                              default
otus  delegation                     on                             default
otus  autoreplace                    off                            default
otus  cachefile                      -                              default
otus  failmode                       wait                           default
otus  listsnapshots                  off                            default
otus  autoexpand                     off                            default
otus  dedupratio                     1.00x                          -
otus  free                           478M                           -
otus  allocated                      2.09M                          -
otus  readonly                       off                            -
otus  ashift                         0                              default
otus  comment                        -                              default
otus  expandsize                     -                              -
otus  freeing                        0                              -
otus  fragmentation                  0%                             -
otus  leaked                         0                              -
otus  multihost                      off                            default
otus  checkpoint                     -                              -
otus  load_guid                      15276750415685578067           -
otus  autotrim                       off                            default
otus  compatibility                  off                            default
otus  bcloneused                     0                              -
otus  bclonesaved                    0                              -
otus  bcloneratio                    1.00x                          -
otus  feature@async_destroy          enabled                        local
otus  feature@empty_bpobj            active                         local
otus  feature@lz4_compress           active                         local
otus  feature@multi_vdev_crash_dump  enabled                        local
otus  feature@spacemap_histogram     active                         local
otus  feature@enabled_txg            active                         local
otus  feature@hole_birth             active                         local
otus  feature@extensible_dataset     active                         local
otus  feature@embedded_data          active                         local
otus  feature@bookmarks              enabled                        local
otus  feature@filesystem_limits      enabled                        local
otus  feature@large_blocks           enabled                        local
otus  feature@large_dnode            enabled                        local
otus  feature@sha512                 enabled                        local
otus  feature@skein                  enabled                        local
otus  feature@edonr                  enabled                        local
otus  feature@userobj_accounting     active                         local
otus  feature@encryption             enabled                        local
otus  feature@project_quota          active                         local
otus  feature@device_removal         enabled                        local
otus  feature@obsolete_counts        enabled                        local
otus  feature@zpool_checkpoint       enabled                        local
otus  feature@spacemap_v2            active                         local
otus  feature@allocation_classes     enabled                        local
otus  feature@resilver_defer         enabled                        local
otus  feature@bookmark_v2            enabled                        local
otus  feature@redaction_bookmarks    disabled                       local
otus  feature@redacted_datasets      disabled                       local
otus  feature@bookmark_written       disabled                       local
otus  feature@log_spacemap           disabled                       local
otus  feature@livelist               disabled                       local
otus  feature@device_rebuild         disabled                       local
otus  feature@zstd_compress          disabled                       local
otus  feature@draid                  disabled                       local
otus  feature@zilsaxattr             disabled                       local
otus  feature@head_errlog            disabled                       local
otus  feature@blake3                 disabled                       local
otus  feature@block_cloning          disabled                       local
otus  feature@vdev_zaps_v2           disabled                       local
jecka@otus:~/zpoolexport$ sudo zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local
jecka@otus:~/zpoolexport$ zpool status

 pool: otus
 state: ONLINE
status: Some supported and requested features are not enabled on the pool.
	The pool can still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done,
	the pool may no longer be accessible by software that does not support
	the features. See zpool-features(7) for details.
config:

	NAME                               STATE     READ WRITE CKSUM
	otus                               ONLINE       0     0     0
	  mirror-0                         ONLINE       0     0     0
	    /home/jecka/zpoolexport/filea  ONLINE       0     0     0
	    /home/jecka/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors
```

Из данных выше мы видим  некоторые параметры:
<br>
Размер пула - 480M
<br>
Компрессия  - lz4
<br>
recordsize  128K
<br>
Тип пула - зеркало 
<br>


### 3. Работа со снапшотами
#### 3.1  Копирование файла из удаленной директории

```bash
jecka@otus:~$ sudo zfs snapshot gzip@n001
jecka@otus:~$ zfs list -t snapshot
NAME        USED  AVAIL  REFER  MOUNTPOINT
gzip@n001     0B      -  51.1M  -
jecka@otus:~$ zfs list -t snapshot
NAME        USED  AVAIL  REFER  MOUNTPOINT
gzip@n001     0B      -  51.1M  -
jecka@otus:~$ cd /gzip/
jecka@otus:/gzip$ ls -la
total 52311
drwxr-xr-x  2 root root         3 May 26 21:00 .
drwxr-xr-x 29 root root      4096 May 26 23:22 ..
-rw-r--r--  1 root root 139921497 May 25  2021 rockyou.txt
jecka@otus:/gzip$ sudo rm rockyou.txt 
jecka@otus:/gzip$ sudo zfs rollback gzip@n001
jecka@otus:/gzip$ ls -la
total 52311
drwxr-xr-x  2 root root         3 May 26 21:00 .
drwxr-xr-x 29 root root      4096 May 26 23:22 ..
-rw-r--r--  1 root root 139921497 May 25  2021 rockyou.txt
jecka@otus:/gzip$ 
```
Восстановление произведено из снапшота диска

#### 3.2 восстановить файл локально. zfs receive;

```bash
jecka@otus:/gzip$ sudo zfs send gzip@n001 > /tmp/gzip.zfs
jecka@otus:~$ sudo zfs destroy gzip@n001
jecka@otus:/gzip$ sudo rm rockyou.txt 
jecka@otus:/gzip$ ls -la
total 5
drwxr-xr-x  2 root root    2 May 26 23:35 .
drwxr-xr-x 29 root root 4096 May 26 23:22 ..
jecka@otus:/gzip$ cd ~ 
jecka@otus:~$ sudo zfs receive gzip </tmp/gzip.zfs 
jecka@otus:~$ sudo zfs receive -F  gzip </tmp/gzip.zfs 
jecka@otus:~$ cd /gzip/
jecka@otus:/gzip$ ls -la
total 52311
drwxr-xr-x  2 root root         3 May 26 21:00 .
drwxr-xr-x 29 root root      4096 May 26 23:38 ..
-rw-r--r--  1 root root 139921497 May 25  2021 rockyou.txt
jecka@otus:/gzip$ 

```
Произведена копия снимка в виде файла и сохранен в /tmp/gzip.zfs
<br>
Произведено удаление снимка
<br>
Произведено удаление файла rockyou.txt на zfs пуле gzip 
<br>
Произведено восстановление из файла gzip.zfs


#### 3.3 найти зашифрованное сообщение в файле secret_message.

```bash
jecka@otus:~$ wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download
[1] 4408
jecka@otus:~$ 
Redirecting output to ‘wget-log’.

[1]+  Done                    wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI
jecka@otus:~$ zfs receive otus/test@today < otus_task2.file
cannot receive new filesystem stream: permission denied
jecka@otus:~$ sudo zfs receive otus/test@today < otus_task2.file
[sudo] password for jecka: 
jecka@otus:~$ cd /otus/
hometask2/ test/      
jecka@otus:~$ cd /otus/test/
jecka@otus:/otus/test$ ls -la
total 2591
drwxr-xr-x 3 root  root       11 May 15  2020 .
drwxr-xr-x 4 root  root        4 May 26 22:57 ..
-rw-r--r-- 1 root  root        0 May 15  2020 10M.file
-rw-r--r-- 1 root  root   727040 May 15  2020 cinderella.tar
-rw-r--r-- 1 root  root       65 May 15  2020 for_examaple.txt
-rw-r--r-- 1 root  root        0 May 15  2020 homework4.txt
-rw-r--r-- 1 root  root   309987 May 15  2020 Limbo.txt
-rw-r--r-- 1 root  root   509836 May 15  2020 Moby_Dick.txt
drwxr-xr-x 3 jecka jecka       4 Dec 18  2017 task1
-rw-r--r-- 1 root  root  1209374 May  6  2016 War_and_Peace.txt
-rw-r--r-- 1 root  root   398635 May 15  2020 world.sql
jecka@otus:/otus/test$ find /otus/test -name "secret_message"
/otus/test/task1/file_mess/secret_message
jecka@otus:/otus/test$ cd task1/file_mess/
jecka@otus:/otus/test/task1/file_mess$ cat secret_message 
https://otus.ru/lessons/linux-hl/

```

В "secret message" - https://otus.ru/lessons/linux-hl/





