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
jecka@otus:/gzip$ zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
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
Чек сумма - sha256


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
</ul></details>

<details><summary><code>06.Работы с NFS</code></summary>


### Описание задания

Необходимс создать 2 скрипта которы будут в автоматическом  режиме  производить настройку NFS
<br>
1-ый скрипт - [nfsc_script.sh](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/nfs/nfsc_script.sh) -  производит настройку сервера 
<br>
2-ой скрпит - [ndss_sctipt.sh](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/nfs/ndss_sctipt.sh) -  произвыодит натсрокй клиента 


### Решение

####  1.1 Настройка сервера 

```bash
#!/bin/bash

echo "скрипт настройки сервера NFS"
sleep 5
# Проверка запуска от имени root
if [[ "$EUID" != 0 ]]; then
   echo "Ошибка! Скрипт необходимо запускать от имени root." >&2
   exit 1
fi

apt update && apt install  nfs-kernel-server -y

mkdir -p /mnt/share/upload
chown -R nobody:nogroup /mnt/share
chmod 0777 /mnt/share/upload

echo  "/mnt/share *(rw.sync,root_squash)" | tee -a /etc/exportfs

exportfs -r
exportfs -s

echo "Настройка проведена. Не забудьте запустить скрипт настройки клиента на клиентской машине"
```


Скрипт выполняет следующие действия:
<br>
Провереяет, что запущен с правми sudo
<br>
Обновляет и устанавливает необходимые для работы пакеты
<br>
Проводит создание директории /mnt/share/uppload   назначет права на директорию 
<br>
Добавляет строчку для настройки сервиса NFS



####  1.2 Настройка клиента

```bash
#!/bin/bash

DIRECTORY="/mnt/upload/"


echo "скрипт настройки Клиента NFS"
sleep 5
# Проверка запуска от имени root
if [[ "$EUID" != 0 ]]; then
   echo "Ошибка! Скрипт необходимо запускать от имени root." >&2
   exit 1
fi

apt update && apt install nfs-common -y
echo "192.168.1.14:/mnt/share /mnt nfs vers=3,noauto,systemd.automount 0 0" >> /etc/fstab

systemd daemon-reload
systemd restart remote-fs.target

touch $DIRECTORY/test_file

# Поиск файлов в заданной директории
for file in "$DIRECTORY"/*; do
    if [[ -f "$file" ]]; then
        # Запись найденных файлов в журнал
        echo "Файл обнаружен: $(basename "$file")"
    fi
done
```
Скрипт выполняет следующие действия:
<br>
Проверяет, что скрипт выполняется от с правами sudo  
<br>
Производит установку необходимых компанентов
<br>
Создает насчтрокй для автоматческого подключения ( монтрования)  директории на NFS
<br>
Создает файл и проверяет, что он созадался
<br>
</ul></details>

<details><summary><code>07.Управление пакетами. Дистрибьюция софта</code></summary>

### Задание

Создать свой RPM (можно взять свое приложение, либо собрать к примеру Apache с определенными опциями);

Создать свой репозиторий и разместить там ранее собранный RPM;

Сеализовать это все либо в Vagrant, либо развернуть у себя через Nginx и дать ссылку на репозиторий.

### Реализация

##### 1.1 Подготовка

Устанавливаем необходимые компаненты:

<ul>

```bash

[jecka@localhost ~]$ dnf install -y wget rpmdevtools rpm-build createrepo yum-utils cmake gcc git nano
Ошибка: Эту команду нужно запускать с привилегиями суперпользователя (на большинстве систем - под именем пользователя root).
[jecka@localhost ~]$ sudo dnf install -y wget rpmdevtools rpm-build createrepo yum-utils cmake gcc git nano
[sudo] пароль для jecka:
Последняя проверка окончания срока действия метаданных: 1:54:47 назад, Пн 02 июн 2025 21:02:36.
Пакет wget-1.21.3-4.red80.x86_64 уже установлен.
Пакет gcc-12.4.0-1.red80.x86_64 уже установлен.
Пакет git-2.48.1-1.red80.x86_64 уже установлен.
Пакет nano-8.0-1.red80.x86_64 уже установлен.
Зависимости разрешены.
==============================================================================================================================================================================================================================================================================================
 Пакет                                                                     Архитектура                                              Версия                                                                                    Репозиторий                                               Размер
==============================================================================================================================================================================================================================================================================================
Установка:
 cmake                                                                     x86_64                                                   3.28.3-1.red80                                                                            updates                                                   8.0 M
 createrepo_c                                                              x86_64                                                   0.20.1-1.red80                                                                            base                                                       72 k
 dnf-utils                                                                 noarch                                                   4.4.2-1.red80                                                                             base                                                       33 k
 rpm-build                                                                 x86_64                                                   4.18.2-3.red80                                                                            updates                                                    63 k
 rpmdevtools                                                               noarch                                                   9.5-5.red80                                                                               updates                                                    89 k
Установка зависимостей:
 annobin-docs                                                              noarch                                                   10.94-3.red80                                                                             base                                                       70 k
 annobin-plugin-gcc                                                        x86_64                                                   10.94-3.red80                                                                             base                                                      865 k
 cmake-data                                                                noarch                                                   3.28.3-1.red80                                                                            updates                                                   1.8 M
 cmake-rpm-macros                                                          noarch                                                   3.28.3-1.red80                                                                            updates                                                    10 k
 createrepo_c-libs                                                         x86_64                                                   0.20.1-1.red80                                                                            base                                                      102 k
 debugedit                                                                 x86_64                                                   5.0-5.red80                                                                               base                                                       76 k
 drpm                                                                      x86_64                                                   0.5.0-6.red80                                                                             base                                                       61 k
 dwz                                                                       x86_64                                                   0.15-2.red80                                                                              base                                                      135 k
 fakeroot                                                                  x86_64                                                   1.25.3-4.red80                                                                            base                                                       86 k
 fakeroot-libs                                                             x86_64                                                   1.25.3-4.red80                                                                            base                                                       38 k
 gcc-plugin-annobin                                                        x86_64                                                   12.4.0-1.red80                                                                            updates                                                    30 k
 http-parser                                                               x86_64                                                   2.9.4-6.red80                                                                             base                                                       35 k
 jsoncpp                                                                   x86_64                                                   1.9.5-1.red80                                                                             base                                                       97 k
 koji                                                                      noarch                                                   1.35.1-1.red80                                                                            updates                                                   234 k
 libgit2                                                                   x86_64                                                   1.7.2-2.red80                                                                             base                                                      533 k
 perl-srpm-macros                                                          noarch                                                   1-24.red80                                                                                base                                                      7.6 k
 python-srpm-macros                                                        noarch                                                   3.11-4.red80                                                                              updates                                                    19 k
 python3-argcomplete                                                       noarch                                                   2.0.0-1.red80                                                                             base                                                       70 k
 python3-babel                                                             noarch                                                   2.12.1-1.red80                                                                            updates                                                   6.6 M
 python3-decorator                                                         noarch                                                   5.1.1-4.red80                                                                             base                                                       30 k
 python3-gssapi                                                            x86_64                                                   1.7.3-3.red80                                                                             base                                                      548 k
 python3-koji                                                              noarch                                                   1.35.1-1.red80                                                                            updates                                                   431 k
 python3-progressbar2                                                      noarch                                                   3.53.2-6.red80                                                                            base                                                       67 k
 python3-pygit2                                                            x86_64                                                   1.13.3-2.red80                                                                            base                                                      251 k
 python3-requests-gssapi                                                   noarch                                                   1.2.3-6.red80                                                                             base                                                       27 k
 python3-utils                                                             noarch                                                   3.1.0-3.red80                                                                             base                                                       43 k
 redos-rpm-config                                                          noarch                                                   1.2-14.red80                                                                              updates                                                    55 k
 rhash                                                                     x86_64                                                   1.4.2-2.red80                                                                             base                                                      184 k
 systemd-rpm-macros                                                        noarch                                                   253.30-1.red80                                                                            updates                                                    12 k
 xemacs-filesystem                                                         noarch                                                   21.5.34-43.20200331hge2ac728aa576.red80                                                   base                                                      7.9 k
 zchunk-libs                                                               x86_64                                                   1.5.1-1.red80                                                                             updates                                                    50 k
Установка слабых зависимостей:
 python3-rpmautospec                                                       noarch                                                   0.3.0-1.red80                                                                             base                                                       55 k

Результат транзакции
==============================================================================================================================================================================================================================================================================================
Установка  37 Пакетов

Объем загрузки: 21 M
Объем изменений: 82 M
Загрузка пакетов:
(1/37): createrepo_c-0.20.1-1.red80.x86_64.rpm                                                                                                                                                                                                                508 kB/s |  72 kB     00:00
(2/37): annobin-docs-10.94-3.red80.noarch.rpm                                                                                                                                                                                                                 326 kB/s |  70 kB     00:00
(3/37): createrepo_c-libs-0.20.1-1.red80.x86_64.rpm                                                                                                                                                                                                           724 kB/s | 102 kB     00:00
(4/37): annobin-plugin-gcc-10.94-3.red80.x86_64.rpm                                                                                                                                                                                                           2.3 MB/s | 865 kB     00:00
(5/37): debugedit-5.0-5.red80.x86_64.rpm                                                                                                                                                                                                                      276 kB/s |  76 kB     00:00
(6/37): dnf-utils-4.4.2-1.red80.noarch.rpm                                                                                                                                                                                                                    121 kB/s |  33 kB     00:00
(7/37): drpm-0.5.0-6.red80.x86_64.rpm                                                                                                                                                                                                                         230 kB/s |  61 kB     00:00
(8/37): dwz-0.15-2.red80.x86_64.rpm                                                                                                                                                                                                                           978 kB/s | 135 kB     00:00
(9/37): fakeroot-1.25.3-4.red80.x86_64.rpm                                                                                                                                                                                                                    417 kB/s |  86 kB     00:00
(10/37): fakeroot-libs-1.25.3-4.red80.x86_64.rpm                                                                                                                                                                                                              184 kB/s |  38 kB     00:00
(11/37): http-parser-2.9.4-6.red80.x86_64.rpm                                                                                                                                                                                                                 260 kB/s |  35 kB     00:00
(12/37): jsoncpp-1.9.5-1.red80.x86_64.rpm                                                                                                                                                                                                                     474 kB/s |  97 kB     00:00
(13/37): libgit2-1.7.2-2.red80.x86_64.rpm                                                                                                                                                                                                                     2.5 MB/s | 533 kB     00:00
(14/37): perl-srpm-macros-1-24.red80.noarch.rpm                                                                                                                                                                                                               101 kB/s | 7.6 kB     00:00
(15/37): python3-argcomplete-2.0.0-1.red80.noarch.rpm                                                                                                                                                                                                         493 kB/s |  70 kB     00:00
(16/37): python3-decorator-5.1.1-4.red80.noarch.rpm                                                                                                                                                                                                           217 kB/s |  30 kB     00:00
(17/37): python3-gssapi-1.7.3-3.red80.x86_64.rpm                                                                                                                                                                                                              3.8 MB/s | 548 kB     00:00
(18/37): python3-progressbar2-3.53.2-6.red80.noarch.rpm                                                                                                                                                                                                       319 kB/s |  67 kB     00:00
(19/37): python3-pygit2-1.13.3-2.red80.x86_64.rpm                                                                                                                                                                                                             1.2 MB/s | 251 kB     00:00
(20/37): python3-requests-gssapi-1.2.3-6.red80.noarch.rpm                                                                                                                                                                                                     199 kB/s |  27 kB     00:00
(21/37): python3-rpmautospec-0.3.0-1.red80.noarch.rpm                                                                                                                                                                                                         271 kB/s |  55 kB     00:00
(22/37): python3-utils-3.1.0-3.red80.noarch.rpm                                                                                                                                                                                                               213 kB/s |  43 kB     00:00
(23/37): rhash-1.4.2-2.red80.x86_64.rpm                                                                                                                                                                                                                       1.3 MB/s | 184 kB     00:00
(24/37): xemacs-filesystem-21.5.34-43.20200331hge2ac728aa576.red80.noarch.rpm                                                                                                                                                                                  56 kB/s | 7.9 kB     00:00
(25/37): cmake-rpm-macros-3.28.3-1.red80.noarch.rpm                                                                                                                                                                                                           101 kB/s |  10 kB     00:00
(26/37): cmake-data-3.28.3-1.red80.noarch.rpm                                                                                                                                                                                                                 8.9 MB/s | 1.8 MB     00:00
(27/37): gcc-plugin-annobin-12.4.0-1.red80.x86_64.rpm                                                                                                                                                                                                         194 kB/s |  30 kB     00:00
(28/37): koji-1.35.1-1.red80.noarch.rpm                                                                                                                                                                                                                       1.6 MB/s | 234 kB     00:00
(29/37): cmake-3.28.3-1.red80.x86_64.rpm                                                                                                                                                                                                                       15 MB/s | 8.0 MB     00:00
(30/37): python-srpm-macros-3.11-4.red80.noarch.rpm                                                                                                                                                                                                           101 kB/s |  19 kB     00:00
(31/37): redos-rpm-config-1.2-14.red80.noarch.rpm                                                                                                                                                                                                             508 kB/s |  55 kB     00:00
(32/37): python3-koji-1.35.1-1.red80.noarch.rpm                                                                                                                                                                                                               2.3 MB/s | 431 kB     00:00
(33/37): rpm-build-4.18.2-3.red80.x86_64.rpm                                                                                                                                                                                                                  438 kB/s |  63 kB     00:00
(34/37): rpmdevtools-9.5-5.red80.noarch.rpm                                                                                                                                                                                                                   629 kB/s |  89 kB     00:00
(35/37): python3-babel-2.12.1-1.red80.noarch.rpm                                                                                                                                                                                                               13 MB/s | 6.6 MB     00:00
(36/37): systemd-rpm-macros-253.30-1.red80.noarch.rpm                                                                                                                                                                                                          98 kB/s |  12 kB     00:00
(37/37): zchunk-libs-1.5.1-1.red80.x86_64.rpm                                                                                                                                                                                                                 410 kB/s |  50 kB     00:00
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Общий размер                                                                                                                                                                                                                                                  7.9 MB/s |  21 MB     00:02
Проверка транзакции
Проверка транзакции успешно завершена.
Идет проверка транзакции
Тест транзакции проведен успешно.
Выполнение транзакции
  Подготовка       :                                                                                                                                                                                                                                                                      1/1
  Установка        : cmake-rpm-macros-3.28.3-1.red80.noarch                                                                                                                                                                                                                              1/37
  Установка        : dwz-0.15-2.red80.x86_64                                                                                                                                                                                                                                             2/37
  Установка        : debugedit-5.0-5.red80.x86_64                                                                                                                                                                                                                                        3/37
  Установка        : zchunk-libs-1.5.1-1.red80.x86_64                                                                                                                                                                                                                                    4/37
  Установка        : python3-babel-2.12.1-1.red80.noarch                                                                                                                                                                                                                                 5/37
  Установка        : gcc-plugin-annobin-12.4.0-1.red80.x86_64                                                                                                                                                                                                                            6/37
  Установка        : xemacs-filesystem-21.5.34-43.20200331hge2ac728aa576.red80.noarch                                                                                                                                                                                                    7/37
  Установка        : rhash-1.4.2-2.red80.x86_64                                                                                                                                                                                                                                          8/37
  Установка        : python3-utils-3.1.0-3.red80.noarch                                                                                                                                                                                                                                  9/37
  Установка        : python3-progressbar2-3.53.2-6.red80.noarch                                                                                                                                                                                                                         10/37
  Установка        : python3-decorator-5.1.1-4.red80.noarch                                                                                                                                                                                                                             11/37
  Установка        : python3-gssapi-1.7.3-3.red80.x86_64                                                                                                                                                                                                                                12/37
  Установка        : python3-requests-gssapi-1.2.3-6.red80.noarch                                                                                                                                                                                                                       13/37
  Установка        : python3-koji-1.35.1-1.red80.noarch                                                                                                                                                                                                                                 14/37
  Установка        : koji-1.35.1-1.red80.noarch                                                                                                                                                                                                                                         15/37
  Установка        : python3-argcomplete-2.0.0-1.red80.noarch                                                                                                                                                                                                                           16/37
  Установка        : perl-srpm-macros-1-24.red80.noarch                                                                                                                                                                                                                                 17/37
  Установка        : jsoncpp-1.9.5-1.red80.x86_64                                                                                                                                                                                                                                       18/37
  Установка        : cmake-data-3.28.3-1.red80.noarch                                                                                                                                                                                                                                   19/37
  Установка        : cmake-3.28.3-1.red80.x86_64                                                                                                                                                                                                                                        20/37
  Установка        : http-parser-2.9.4-6.red80.x86_64                                                                                                                                                                                                                                   21/37
  Установка        : libgit2-1.7.2-2.red80.x86_64                                                                                                                                                                                                                                       22/37
  Установка        : python3-pygit2-1.13.3-2.red80.x86_64                                                                                                                                                                                                                               23/37
  Установка        : fakeroot-libs-1.25.3-4.red80.x86_64                                                                                                                                                                                                                                24/37
  Установка        : fakeroot-1.25.3-4.red80.x86_64                                                                                                                                                                                                                                     25/37
  Запуск скриптлета: fakeroot-1.25.3-4.red80.x86_64                                                                                                                                                                                                                                     25/37
  Установка        : drpm-0.5.0-6.red80.x86_64                                                                                                                                                                                                                                          26/37
  Установка        : createrepo_c-libs-0.20.1-1.red80.x86_64                                                                                                                                                                                                                            27/37
  Установка        : annobin-docs-10.94-3.red80.noarch                                                                                                                                                                                                                                  28/37
  Установка        : annobin-plugin-gcc-10.94-3.red80.x86_64                                                                                                                                                                                                                            29/37
  Установка        : redos-rpm-config-1.2-14.red80.noarch                                                                                                                                                                                                                               30/37
  Запуск скриптлета: redos-rpm-config-1.2-14.red80.noarch                                                                                                                                                                                                                               30/37
  Установка        : python-srpm-macros-3.11-4.red80.noarch                                                                                                                                                                                                                             31/37
  Установка        : rpm-build-4.18.2-3.red80.x86_64                                                                                                                                                                                                                                    32/37
  Установка        : python3-rpmautospec-0.3.0-1.red80.noarch                                                                                                                                                                                                                           33/37
  Установка        : rpmdevtools-9.5-5.red80.noarch                                                                                                                                                                                                                                     34/37
  Установка        : createrepo_c-0.20.1-1.red80.x86_64                                                                                                                                                                                                                                 35/37
  Установка        : systemd-rpm-macros-253.30-1.red80.noarch                                                                                                                                                                                                                           36/37
  Установка        : dnf-utils-4.4.2-1.red80.noarch                                                                                                                                                                                                                                     37/37
  Запуск скриптлета: dnf-utils-4.4.2-1.red80.noarch                                                                                                                                                                                                                                     37/37
  Проверка         : annobin-docs-10.94-3.red80.noarch                                                                                                                                                                                                                                   1/37
  Проверка         : annobin-plugin-gcc-10.94-3.red80.x86_64                                                                                                                                                                                                                             2/37
  Проверка         : createrepo_c-0.20.1-1.red80.x86_64                                                                                                                                                                                                                                  3/37
  Проверка         : createrepo_c-libs-0.20.1-1.red80.x86_64                                                                                                                                                                                                                             4/37
  Проверка         : debugedit-5.0-5.red80.x86_64                                                                                                                                                                                                                                        5/37
  Проверка         : dnf-utils-4.4.2-1.red80.noarch                                                                                                                                                                                                                                      6/37
  Проверка         : drpm-0.5.0-6.red80.x86_64                                                                                                                                                                                                                                           7/37
  Проверка         : dwz-0.15-2.red80.x86_64                                                                                                                                                                                                                                             8/37
  Проверка         : fakeroot-1.25.3-4.red80.x86_64                                                                                                                                                                                                                                      9/37
  Проверка         : fakeroot-libs-1.25.3-4.red80.x86_64                                                                                                                                                                                                                                10/37
  Проверка         : http-parser-2.9.4-6.red80.x86_64                                                                                                                                                                                                                                   11/37
  Проверка         : jsoncpp-1.9.5-1.red80.x86_64                                                                                                                                                                                                                                       12/37
  Проверка         : libgit2-1.7.2-2.red80.x86_64                                                                                                                                                                                                                                       13/37
  Проверка         : perl-srpm-macros-1-24.red80.noarch                                                                                                                                                                                                                                 14/37
  Проверка         : python3-argcomplete-2.0.0-1.red80.noarch                                                                                                                                                                                                                           15/37
  Проверка         : python3-decorator-5.1.1-4.red80.noarch                                                                                                                                                                                                                             16/37
  Проверка         : python3-gssapi-1.7.3-3.red80.x86_64                                                                                                                                                                                                                                17/37
  Проверка         : python3-progressbar2-3.53.2-6.red80.noarch                                                                                                                                                                                                                         18/37
  Проверка         : python3-pygit2-1.13.3-2.red80.x86_64                                                                                                                                                                                                                               19/37
  Проверка         : python3-requests-gssapi-1.2.3-6.red80.noarch                                                                                                                                                                                                                       20/37
  Проверка         : python3-rpmautospec-0.3.0-1.red80.noarch                                                                                                                                                                                                                           21/37
  Проверка         : python3-utils-3.1.0-3.red80.noarch                                                                                                                                                                                                                                 22/37
  Проверка         : rhash-1.4.2-2.red80.x86_64                                                                                                                                                                                                                                         23/37
  Проверка         : xemacs-filesystem-21.5.34-43.20200331hge2ac728aa576.red80.noarch                                                                                                                                                                                                   24/37
  Проверка         : cmake-3.28.3-1.red80.x86_64                                                                                                                                                                                                                                        25/37
  Проверка         : cmake-data-3.28.3-1.red80.noarch                                                                                                                                                                                                                                   26/37
  Проверка         : cmake-rpm-macros-3.28.3-1.red80.noarch                                                                                                                                                                                                                             27/37
  Проверка         : gcc-plugin-annobin-12.4.0-1.red80.x86_64                                                                                                                                                                                                                           28/37
  Проверка         : koji-1.35.1-1.red80.noarch                                                                                                                                                                                                                                         29/37
  Проверка         : python-srpm-macros-3.11-4.red80.noarch                                                                                                                                                                                                                             30/37
  Проверка         : python3-babel-2.12.1-1.red80.noarch                                                                                                                                                                                                                                31/37
  Проверка         : python3-koji-1.35.1-1.red80.noarch                                                                                                                                                                                                                                 32/37
  Проверка         : redos-rpm-config-1.2-14.red80.noarch                                                                                                                                                                                                                               33/37
  Проверка         : rpm-build-4.18.2-3.red80.x86_64                                                                                                                                                                                                                                    34/37
  Проверка         : rpmdevtools-9.5-5.red80.noarch                                                                                                                                                                                                                                     35/37
  Проверка         : systemd-rpm-macros-253.30-1.red80.noarch                                                                                                                                                                                                                           36/37
  Проверка         : zchunk-libs-1.5.1-1.red80.x86_64                                                                                                                                                                                                                                   37/37

Установлен:
  annobin-docs-10.94-3.red80.noarch        annobin-plugin-gcc-10.94-3.red80.x86_64     cmake-3.28.3-1.red80.x86_64               cmake-data-3.28.3-1.red80.noarch              cmake-rpm-macros-3.28.3-1.red80.noarch    createrepo_c-0.20.1-1.red80.x86_64
  createrepo_c-libs-0.20.1-1.red80.x86_64  debugedit-5.0-5.red80.x86_64                dnf-utils-4.4.2-1.red80.noarch            drpm-0.5.0-6.red80.x86_64                     dwz-0.15-2.red80.x86_64                   fakeroot-1.25.3-4.red80.x86_64
  fakeroot-libs-1.25.3-4.red80.x86_64      gcc-plugin-annobin-12.4.0-1.red80.x86_64    http-parser-2.9.4-6.red80.x86_64          jsoncpp-1.9.5-1.red80.x86_64                  koji-1.35.1-1.red80.noarch                libgit2-1.7.2-2.red80.x86_64
  perl-srpm-macros-1-24.red80.noarch       python-srpm-macros-3.11-4.red80.noarch      python3-argcomplete-2.0.0-1.red80.noarch  python3-babel-2.12.1-1.red80.noarch           python3-decorator-5.1.1-4.red80.noarch    python3-gssapi-1.7.3-3.red80.x86_64
  python3-koji-1.35.1-1.red80.noarch       python3-progressbar2-3.53.2-6.red80.noarch  python3-pygit2-1.13.3-2.red80.x86_64      python3-requests-gssapi-1.2.3-6.red80.noarch  python3-rpmautospec-0.3.0-1.red80.noarch  python3-utils-3.1.0-3.red80.noarch
  redos-rpm-config-1.2-14.red80.noarch     rhash-1.4.2-2.red80.x86_64                  rpm-build-4.18.2-3.red80.x86_64           rpmdevtools-9.5-5.red80.noarch                systemd-rpm-macros-253.30-1.red80.noarch  xemacs-filesystem-21.5.34-43.20200331hge2ac728aa576.red80.noarch
  zchunk-libs-1.5.1-1.red80.x86_64

Выполнено!
```

</ul>

Скачиваем Програмное обеспечивание которое будем исспользовать к качестве тестового для разверотывния через RPM Пакеты

```bash
[jecka@localhost ~]$ wget https://github.com/prometheus/prometheus/releases/download/v3.4.1/prometheus-3.4.1.linux-amd64.tar.gz
--2025-06-02 23:03:27--  https://github.com/prometheus/prometheus/releases/download/v3.4.1/prometheus-3.4.1.linux-amd64.tar.gz
Распознаётся github.com (github.com)… 140.82.121.3
Подключение к github.com (github.com)|140.82.121.3|:443... соединение установлено.
HTTP-запрос отправлен. Ожидание ответа… 302 Found
Адрес: https://objects.githubusercontent.com/github-production-release-asset-2e65be/6838921/9fa63ebf-79ae-453f-9f67-1ab91f4cb98e?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250602%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250602T200328Z&X-Amz-Expires=300&X-Amz-Signature=d332d4519a3f6cd65cf3c165b489c66b0f9ec476da8e3ef6cf47fe56f69fa018&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dprometheus-3.4.1.linux-amd64.tar.gz&response-content-type=application%2Foctet-stream [переход]
--2025-06-02 23:03:28--  https://objects.githubusercontent.com/github-production-release-asset-2e65be/6838921/9fa63ebf-79ae-453f-9f67-1ab91f4cb98e?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250602%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250602T200328Z&X-Amz-Expires=300&X-Amz-Signature=d332d4519a3f6cd65cf3c165b489c66b0f9ec476da8e3ef6cf47fe56f69fa018&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dprometheus-3.4.1.linux-amd64.tar.gz&response-content-type=application%2Foctet-stream
Распознаётся objects.githubusercontent.com (objects.githubusercontent.com)… 185.199.108.133
Подключение к objects.githubusercontent.com (objects.githubusercontent.com)|185.199.108.133|:443... соединение установлено.
HTTP-запрос отправлен. Ожидание ответа… 200 OK
Длина: 117287996 (112M) [application/octet-stream]
Сохранение в: «prometheus-3.4.1.linux-amd64.tar.gz»

prometheus-3.4.1.linux-amd64.tar.gz                                     100%[=============================================================================================================================================================================>] 111,85M  62,7MB/s    за 1,8s

2025-06-02 23:03:30 (62,7 MB/s) - «prometheus-3.4.1.linux-amd64.tar.gz» сохранён [117287996/117287996]

```

Создаем дерево для разработки и копируем необходимые файлы 

```bash
[jecka@localhost create]$ rpmdev-setuptree
[jecka@localhost tmp]$ touch  /home/jecka/rpmbuild/SPECS/prometheus.spec
[jecka@localhost tmp]$ cp /home/jecka/prometheus-3.4.1.linux-amd64.tar.gz /home/jecka/rpmbuild/SOURCE/
[jecka@localhost rpmbuild]$ cd SOURCES/
[jecka@localhost SOURCES]$ touch prometheus.service
```

Файлы подготовлены


Вид prometheus.service

```bash
  GNU nano 8.0                                                                                                                          prometheus.service
[Unit]
Description=Prometheus Monitoring System and Time Series Database
Documentation=https://prometheus.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/opt/prometheus/prometheus \
    --config.file /opt/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.libraries=/opt/prometheus/consoles/libraries \
    --web.console.templates=/opt/prometheus/consoles/templates \
    --web.listen-address=:9090 \
    --log.level=info
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Вид созданного файла спецификации для RPM

```bash
Name        : prometheus
Version     : 3.4.1
Release     : 1%{?dist}
Summary     : RPM package for Prometheus
URL         : https://prometheus.io/
License     : Apache-2.0 + GPL-3.0-or-later OR CC-BY-SA-4.0, FSF, MIT
Group       : System Environment/Monitoring
Source0      : %{name}-%{version}.linux-amd64.tar.gz
Source1     : prometheus.service
Prefix:         /opt/prometheus

%description
This package contains Prometheus, a systems and service monitoring toolkit.

%prep
%setup -q -n prometheus-%{version}.linux-amd64

%build
# Binary build not required

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/opt/prometheus
tar xzf %{SOURCE0} -C %{buildroot}/opt/prometheus --strip-components=1

# Copy service file to systemd directory
mkdir -p %{buildroot}/etc/systemd/system
cp %{SOURCE1} %{buildroot}/etc/systemd/system/prometheus.service

%files
%defattr(-, root, root)
/opt/prometheus/*
/etc/systemd/system/prometheus.service

%post
systemctl daemon-reload || :
if ! systemctl is-active --quiet prometheus.service ; then
   echo "The 'prometheus' service was installed but it isn't running."
fi

%preun
if [ "$1" = "0" ]; then
   # Package removal, stop service before removing unit file
   if systemctl is-active --quiet prometheus.service ; then
       systemctl stop prometheus.service || :
   fi
   systemctl disable prometheus.service || :
fi

%changelog
* Fri Sep 17 2021 M.E. User <jecka@iaccpet.ru> - 3.4.1
- Initial Release

```

#### 2.2 Создание RPM пакета

```bash
[jecka@localhost SPECS]$ rpmbuild -ba prometheus.spec
setting SOURCE_DATE_EPOCH=1631836800
Выполняется(%prep): /bin/sh -e /var/tmp/rpm-tmp.HzfLG2
+ umask 022
+ cd /home/jecka/rpmbuild/BUILD
+ cd /home/jecka/rpmbuild/BUILD
+ rm -rf prometheus-3.4.1.linux-amd64
+ /usr/lib/rpm/rpmuncompress -x /home/jecka/rpmbuild/SOURCES/prometheus-3.4.1.linux-amd64.tar.gz
+ STATUS=0
+ '[' 0 -ne 0 ']'
+ cd prometheus-3.4.1.linux-amd64
+ /usr/bin/chmod -Rf a+rX,u+w,g-w,o-w .
+ RPM_EC=0
++ jobs -p
+ exit 0
Выполняется(%build): /bin/sh -e /var/tmp/rpm-tmp.e5jtjW
+ umask 022
+ cd /home/jecka/rpmbuild/BUILD
+ CFLAGS='-O2 -flto=auto -ffat-lto-objects -fexceptions -g -grecord-gcc-switches -pipe -Wall -Werror=format-security -U_FORTIFY_SOURCE -Wp,-U_FORTIFY_SOURCE -Wp,-D_FORTIFY_SOURCE=3 -Wp,-D_GLIBCXX_ASSERTIONS -specs=/usr/lib/rpm/redsoft/redsoft-hardened-cc1 -fstack-protector-strong -specs=/usr/lib/rpm/redsoft/redsoft-annobin-cc1  -m64  -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection'
+ export CFLAGS
+ CXXFLAGS='-O2 -flto=auto -ffat-lto-objects -fexceptions -g -grecord-gcc-switches -pipe -Wall -Werror=format-security -U_FORTIFY_SOURCE -Wp,-U_FORTIFY_SOURCE -Wp,-D_FORTIFY_SOURCE=3 -Wp,-D_GLIBCXX_ASSERTIONS -specs=/usr/lib/rpm/redsoft/redsoft-hardened-cc1 -fstack-protector-strong -specs=/usr/lib/rpm/redsoft/redsoft-annobin-cc1  -m64  -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection'
+ export CXXFLAGS
+ FFLAGS='-O2 -flto=auto -ffat-lto-objects -fexceptions -g -grecord-gcc-switches -pipe -Wall -Werror=format-security -U_FORTIFY_SOURCE -Wp,-U_FORTIFY_SOURCE -Wp,-D_FORTIFY_SOURCE=3 -Wp,-D_GLIBCXX_ASSERTIONS -specs=/usr/lib/rpm/redsoft/redsoft-hardened-cc1 -fstack-protector-strong -specs=/usr/lib/rpm/redsoft/redsoft-annobin-cc1  -m64  -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -I/usr/lib64/gfortran/modules'
+ export FFLAGS
+ FCFLAGS='-O2 -flto=auto -ffat-lto-objects -fexceptions -g -grecord-gcc-switches -pipe -Wall -Werror=format-security -U_FORTIFY_SOURCE -Wp,-U_FORTIFY_SOURCE -Wp,-D_FORTIFY_SOURCE=3 -Wp,-D_GLIBCXX_ASSERTIONS -specs=/usr/lib/rpm/redsoft/redsoft-hardened-cc1 -fstack-protector-strong -specs=/usr/lib/rpm/redsoft/redsoft-annobin-cc1  -m64  -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -I/usr/lib64/gfortran/modules'
+ export FCFLAGS
+ LDFLAGS='-Wl,-z,relro -Wl,--as-needed  -Wl,-z,now -specs=/usr/lib/rpm/redsoft/redsoft-hardened-ld -specs=/usr/lib/rpm/redsoft/redsoft-annobin-cc1 '
+ export LDFLAGS
+ LT_SYS_LIBRARY_PATH=/usr/lib64:
+ export LT_SYS_LIBRARY_PATH
+ CC=gcc
+ export CC
+ CXX=g++
+ export CXX
+ cd prometheus-3.4.1.linux-amd64
+ RPM_EC=0
++ jobs -p
+ exit 0
Выполняется(%install): /bin/sh -e /var/tmp/rpm-tmp.Ewj9Ad
+ umask 022
+ cd /home/jecka/rpmbuild/BUILD
+ '[' /home/jecka/rpmbuild/BUILDROOT/prometheus-3.4.1-1.red80.x86_64 '!=' / ']'
+ rm -rf /home/jecka/rpmbuild/BUILDROOT/prometheus-3.4.1-1.red80.x86_64
++ dirname /home/jecka/rpmbuild/BUILDROOT/prometheus-3.4.1-1.red80.x86_64
+ mkdir -p /home/jecka/rpmbuild/BUILDROOT
+ mkdir /home/jecka/rpmbuild/BUILDROOT/prometheus-3.4.1-1.red80.x86_64
+ cd prometheus-3.4.1.linux-amd64
+ rm -rf /home/jecka/rpmbuild/BUILDROOT/prometheus-3.4.1-1.red80.x86_64
+ mkdir -p /home/jecka/rpmbuild/BUILDROOT/prometheus-3.4.1-1.red80.x86_64/opt/prometheus
+ tar xzf /home/jecka/rpmbuild/SOURCES/prometheus-3.4.1.linux-amd64.tar.gz -C /home/jecka/rpmbuild/BUILDROOT/prometheus-3.4.1-1.red80.x86_64/opt/prometheus --strip-components=1
+ mkdir -p /home/jecka/rpmbuild/BUILDROOT/prometheus-3.4.1-1.red80.x86_64/etc/systemd/system
+ cp /home/jecka/rpmbuild/SOURCES/prometheus.service /home/jecka/rpmbuild/BUILDROOT/prometheus-3.4.1-1.red80.x86_64/etc/systemd/system/prometheus.service
+ /usr/bin/find-debuginfo -j2 --strict-build-id -m -i --build-id-seed 3.4.1-1.red80 --unique-debug-suffix -3.4.1-1.red80.x86_64 --unique-debug-src-base prometheus-3.4.1-1.red80.x86_64 --run-dwz --dwz-low-mem-die-limit 10000000 --dwz-max-die-limit 110000000 -S debugsourcefiles.list /home/jecka/rpmbuild/BUILD/prometheus-3.4.1.linux-amd64
find-debuginfo: starting
Extracting debug info from 2 files
debugedit: /home/jecka/rpmbuild/BUILDROOT/prometheus-3.4.1-1.red80.x86_64/opt/prometheus/prometheus: DWARF version 0 unhandleddebugedit:
/home/jecka/rpmbuild/BUILDROOT/prometheus-3.4.1-1.red80.x86_64/opt/prometheus/promtool: DWARF version 0 unhandled
nm: /home/jecka/rpmbuild/BUILDROOT/prometheus-3.4.1-1.red80.x86_64/opt/prometheus/promtool: no symbols
nm: /home/jecka/rpmbuild/BUILDROOT/prometheus-3.4.1-1.red80.x86_64/opt/prometheus/prometheus: no symbols
DWARF-compressing 2 files
dwz: ./opt/prometheus/prometheus-3.4.1-1.red80.x86_64.debug: Found compressed .debug_abbrev section, not attempting dwz compression
dwz: ./opt/prometheus/promtool-3.4.1-1.red80.x86_64.debug: Found compressed .debug_abbrev section, not attempting dwz compression
dwz: Too few files for multifile optimization
sepdebugcrcfix: Updated 0 CRC32s, 2 CRC32s did match.
Creating .debug symlinks for symlinks to ELF files
find-debuginfo: done
+ '[' '%{buildarch}' = noarch ']'
+ QA_CHECK_RPATHS=1
+ case "${QA_CHECK_RPATHS:-}" in
+ /usr/lib/rpm/check-rpaths
+ /usr/lib/rpm/check-buildroot
+ /usr/lib/rpm/redsoft/brp-ldconfig
+ /usr/lib/rpm/brp-compress
+ /usr/lib/rpm/redsoft/brp-strip-lto /usr/bin/strip
+ /usr/lib/rpm/brp-strip-static-archive /usr/bin/strip
+ /usr/lib/rpm/check-rpaths
+ /usr/lib/rpm/redsoft/brp-mangle-shebangs
+ /usr/lib/rpm/redsoft/brp-python-bytecompile '' 1 0
+ /usr/lib/rpm/redsoft/brp-python-hardlink
Processing files: prometheus-3.4.1-1.red80.x86_64
Provides: prometheus = 3.4.1-1.red80 prometheus(x86-64) = 3.4.1-1.red80
Requires(interp): /bin/sh /bin/sh
Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1
Requires(post): /bin/sh
Requires(preun): /bin/sh
Processing files: prometheus-debuginfo-3.4.1-1.red80.x86_64
Provides: debuginfo(build-id) = 1548c4fde1ed4d8d25e14435be871eeb2d77b919 debuginfo(build-id) = 6562ddd46f7232061c454fcd7e931a60a24376ff prometheus-debuginfo = 3.4.1-1.red80 prometheus-debuginfo(x86-64) = 3.4.1-1.red80
Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(FileDigests) <= 4.6.0-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1
Проверка на неупакованный(е) файл(ы): /usr/lib/rpm/check-files /home/jecka/rpmbuild/BUILDROOT/prometheus-3.4.1-1.red80.x86_64
Записан: /home/jecka/rpmbuild/SRPMS/prometheus-3.4.1-1.red80.src.rpm
Записан: /home/jecka/rpmbuild/RPMS/x86_64/prometheus-debuginfo-3.4.1-1.red80.x86_64.rpm
Записан: /home/jecka/rpmbuild/RPMS/x86_64/prometheus-3.4.1-1.red80.x86_64.rpm
Выполняется(%clean): /bin/sh -e /var/tmp/rpm-tmp.iqOU9F
+ umask 022
+ cd /home/jecka/rpmbuild/BUILD
+ cd prometheus-3.4.1.linux-amd64
+ /usr/bin/rm -rf /home/jecka/rpmbuild/BUILDROOT/prometheus-3.4.1-1.red80.x86_64
+ RPM_EC=0
++ jobs -p
+ exit 0
Выполняется(rmbuild): /bin/sh -e /var/tmp/rpm-tmp.hXx5kn
+ umask 022
+ cd /home/jecka/rpmbuild/BUILD
+ rm -rf prometheus-3.4.1.linux-amd64 prometheus-3.4.1.linux-amd64.gemspec
+ RPM_EC=0
++ jobs -p
+ exit 0

```

#### 2.1 Проверка установки и работы пакета


```bash
[jecka@localhost x86_64]$ sudo dnf localinstall ./prometheus-3.4.1-1.red80.x86_64.rpm
[sudo] пароль для jecka:
Последняя проверка окончания срока действия метаданных: 1:24:16 назад, Вт 03 июн 2025 00:56:26.
Зависимости разрешены.
==============================================================================================================================================================================================================================================================================================
 Пакет                                                                Архитектура                                                      Версия                                                                    Репозиторий                                                            Размер
==============================================================================================================================================================================================================================================================================================
Установка:
 prometheus                                                           x86_64                                                           3.4.1-1.red80                                                             @commandline                                                            45 M

Результат транзакции
==============================================================================================================================================================================================================================================================================================
Установка  1 Пакет

Общий размер: 45 M
Объем изменений: 205 M
Продолжить? [д/Н]: y
Загрузка пакетов:
Проверка транзакции
Проверка транзакции успешно завершена.
Идет проверка транзакции
Тест транзакции проведен успешно.
Выполнение транзакции
  Подготовка       :                                                                                                                                                                                                                                                                      1/1
  Установка        : prometheus-3.4.1-1.red80.x86_64                                                                                                                                                                                                                                      1/1
  Запуск скриптлета: prometheus-3.4.1-1.red80.x86_64                                                                                                                                                                                                                                      1/1
The 'prometheus' service was installed but it isn't running.

  Проверка         : prometheus-3.4.1-1.red80.x86_64                                                                                                                                                                                                                                      1/1

Установлен:
  prometheus-3.4.1-1.red80.x86_64

```
### 3.Создание репозитория 

```bash
[jecka@localhost myrepo]$ sudo createrepo /usr/share/nginx/html/redos
Directory walk started
Directory walk done - 1 packages
Temporary output repo path: /usr/share/nginx/html/redos/.repodata/
Preparing sqlite DBs
Pool started (with 5 workers)
Pool finished

```

Репозиторий доступен по адреcу [repo](http://red.iaccept.ru/redos/updates/)
</ul></details>


<details><summary><code>08.Загрузка системы</code></summary>

### Задачи

Включить отображение меню Grub.
<br>
Попасть в систему без пароля несколькими способами.
<br>
Установить систему с LVM, после чего переименовать VG.
<br>


 ### Решение

 #### 1. Для включения отображения изменим настройки файла /etc/default/grub внесем только изменение в строчки указанные ниже

 ```bash
GRUB_TIMEOUT_STYLE=menu  #Позволит нам показывать меню
GRUB_TIMEOUT=5           #Задержка времени для показа меню
 ```
 После внесения измеенний введем 

 ```bash
 jecka@otus:~$ sudo update-grub
[sudo] password for jecka:
Sourcing file `/etc/default/grub'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.8.0-60-generic
Found initrd image: /boot/initrd.img-6.8.0-60-generic
Found linux image: /boot/vmlinuz-6.8.0-59-generic
Found initrd image: /boot/initrd.img-6.8.0-59-generic
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
Adding boot menu entry for UEFI Firmware Settings ...
done
 ```

 Это позволит нам применить настройки для grub


 #### 2.  Попасть в систему нескольким способами ( изменение пароля пользователя если вы его забыли)

При запуске меню с выбором запуска системы жмем 'e'
Далее находим строку запуска системы и добовляем в нее init=/bin/bash , что приведет к запуску системы в однопользовательском режиме 

![Добовление init=/bin/bash при запуске системы](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/grub/init.png)


После запуска системы в одно пользовательском режиме вводим 
```bash
mount -o remount,rw / # Для перемантирования рут в режиме rw
passwd      # для смены пароля root  и после ввода команды 2 раза вводим новый пароль root  
```
![Смена пароля Root](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/grub/Change_password_to_root.png)

#### 3. Переименование VG

Входим в режим восстановлвения в Grub, для этого при запуске выбираем пункт Меню Recovery

![Меню режима Recovery](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/grub/recovery_menu.png)

Выбераем пункт root

Далее изменяем наименование  Volume Group при помощи команды Vgrename  текущее_имя новое_имя
После переимновния необходимо провести изменения в файле /boot/grub/grub.cfg заменить текущее_имя на новое _имя

![Меню режима Recovery](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/screenshots/grub/renamed_vg.png)

</ul></details>

<details><summary><code>09.Инициализация системы. Systemd</code></summary>


### Задачи

Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/default).
<br>
Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта (https://gist.github.com/cea2k/1318020).
<br>
Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно.
<br>

###  Решение

#### 1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/default).

```bash
[Unit]
Description = Log Service
After = syslog.target

[Service]
User = root
Group = root
ExecStart = bash  /home/jecka/search.sh
Restart = always
RestartSec = 30

[Install]
WantedBy = multi-user.target

```

Скрипт Файл

```bash

#!/bin/bash
source /etc/default.conf
tail -n 1000 "$Source" | grep "$Keyword" >/var/log/find.log
```

Файл с параметрами

```bash
Source=/var/log/syslog
Keyword=PID

```


#### 2. Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта (https://gist.github.com/cea2k/1318020).

```bash
[Unit]
Description = fast-swg
After = network.target

[Service]
Type = forking
User = www-data
Group = www-data
Environment = "PIDFile=/var/run/fast-svg/php_cgi.pid" "server=127.0.0.1" "port=9000" "user=www-data" "group=www-data"
ExecStart = /usr/bin/spawn-fcgi -a $server -p $port -u $user -g $group -C 5 -f /usr/bin/php-cgi
ExecStop = killproc -p php-cgi -QUIT

[Install]
WantedBy = multi-user.target
```

#### 3. Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно.

```bash
[Unit]
Description = Nginx web server instance %i
After = network.target

[Service]
Type = forking
PIDFile = /run/nginx-%i.pid
ExecStartPre = /usr/sbin/nginx -c /etc/nginx/%i.conf -t
ExecStart = /usr/sbin/nginx -c /etc/nginx/%i.conf
ExecReload = /usr/sbin/nginx -c /etc/nginx/%i.conf -s reload
ExecStop = /usr/sbin/nginx -c /etc/nginx/%i.conf -s quit
PrivateTmp = true

[Install]
WantedBy = multi-user.target
```

</ul></details>


<details><summary><code>10.Bash</code></summary>

### Задачи

Написать скрипт для CRON, который раз в час будет формировать письмо и отправлять на заданную почту.


Необходимая информация в письме:

Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
<br>
Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
<br>
Ошибки веб-сервера/приложения c момента последнего запуска;
<br>
Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта.
<br>
Скрипт должен предотвращать одновременный запуск нескольких копий, до его завершения.
<br>


### Решение

```bash
#!/bin/bash
# Проверка  не запущен ли второй экземпляр
if PID=`pgrep -x "email.sh"`
then
    echo "уже запущен $PID"
        breake
else

# Временный Фвайл
email="/tmp/email.log"

#Параметры от пользователя
read -p  "ВВедите  количество  строчек с наибольшим колисеством запросов кторое поподет в отчет  "  line
read -p  "Укажите лог для парсинга  " log

# Оставлено для дебага
#log="/home/jecka/access-4560-644067.log"
echo $log

#  Если файл уже есть  удаление
if [  -e $email ]; then
    rm $email
fi

echo  "Список IP адресов (с наибольшим кол-вом запросов"  >>  $email
grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' $log  | sort | uniq -c  | sort -k1,1nr -k2 | head -n $line >> $email

echo "Список запрашиваемых URL (с наибольшим кол-вом запросов)" >> $email
grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" $log | sort  | uniq -c | sort -k1,1nr -k2 | head -n $line >> $email

echo "Все коды ошибок" >> $email
grep -o "[5][0-9][0-9]"  $log | sort | uniq -c  | sort -k1,1nr -k2 >>  $email

echo "Все коды в файле" >> $email
grep -o "[1-5][0-9][0-9]"  $log | sort | uniq -c  | sort -k1,1nr -k2 >> $email


# Отправка почты без авторизации
echo  'SendPasrslog' | mail -s "Parce log" -a $email  -a "Smtp: someserver.somezone:someport" -a "From:somesendname@somedomain.somezone"   someemail@somedomain.somezone

rm  $email

fi

```
</ul></details>

<details><summary><code>12. Управление процессами</code></summary>

### Задание 

реализовать 2 конкурирующих процесса по CPU. пробовать запустить с разными nice
Результат ДЗ - скрипт запускающий 2 процесса с разными nice и замеряющий время выполнения и лог консоли


### Решение


```bash
#!/bin/bash

# Время выполнения процесса
T=1

# Имя файла для записи вывода
LOG_FILE="/tmp/process_log.txt"

# Удаляем старый лог-файл перед новым запуском
rm -f "$LOG_FILE"
exec 1>> $LOG_FILE


# Процесс №1 с низким приоритетом (-10)
echo "Запускаем процесс #1 с высоким приоритетом..."
START_TIME=$(date +%s)
nice -n -10 stress -c 1  --verbose --timeout $T\m &
PID1=$!
wait $PID1
END_TIME=$(date +%s)
EXECUTION_TIME_1=$(( $(echo "$END_TIME - $START_TIME" | bc -l ) ))
echo "Процесс #1 завершился за ${EXECUTION_TIME_1}s." >> "$LOG_FILE"

# Процесс №2 с нормальным приоритетом (0)
echo "Запускаем процесс #2 с обычным приоритетом..."
START_TIME=$(date +%s)
nice -n  0  stress -c 1  --verbose --timeout $T\m &
PID2=$!
wait $PID2
END_TIME=$(date +%s)
EXECUTION_TIME_2=$(( $(echo "$END_TIME - $START_TIME" | bc -l ) ))
echo "Процесс #2 завершился за ${EXECUTION_TIME_2}s." >> "$LOG_FILE"
```


</ul></details>

<details><summary><code>15 Selinux- Когда все запрещено</code></summary>

### Задание

1. Запустить nginx на нестандартном порту 3-мя разными способами:
переключатели setsebool;
добавление нестандартного порта в имеющийся тип;
формирование и установка модуля SELinux.
К сдаче:
README с описанием каждого решения (скриншоты и демонстрация приветствуются).

2. Обеспечить работоспособность приложения при включенном selinux.

развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems;
выяснить причину неработоспособности механизма обновления зоны (см. README);
предложить решение (или решения) для данной проблемы;
выбрать одно из решений для реализации, предварительно обосновав выбор;
реализовать выбранное решение и продемонстрировать его работоспособность.

К сдаче:
README с анализом причины неработоспособности, возможными способами решения и обоснованием выбора одного из них;
исправленный стенд или демонстрация работоспособной системы скриншотами и описанием.

###  Решение

1. Запустить nginx на нестандартном порту 3-мя разными способами:

1.1  Изменяем настройки Nginx, что бы он обслуживал порт 4881/tcp
```bash

    server {
        listen       80;
        listen       [::]:80;
        listen          4881;
        server_name  _;
        root         /usr/share/nginx/html;
        index index.html index.htm;
        autoindex on;
```
Перезапускаем сервис nginx Командой systemctl nginx restart и получаем ошибку, что сервис не может перезапуститься 

```bash 
[root@localhost ~]# systemctl restart nginx.service
Job for nginx.service failed because the control process exited with error code.
See "systemctl status nginx.service" and "journalctl -xeu nginx.service" for details.
```
Просмотрим audit.log 

```bash
[root@localhost ~]# tail -n 20 /var/log/audit/audit.log
type=USER_ACCT msg=audit(1751748945.106:835): pid=49539 uid=1000 auid=1000 ses=4 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='op=PAM:accounting grantors=pam_unix acct="jecka" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/0 res=success'UID="jecka" AUID="jecka"
type=USER_CMD msg=audit(1751748945.106:836): pid=49539 uid=1000 auid=1000 ses=4 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='cwd="/home/jecka" cmd=7375202D exe="/usr/bin/sudo" terminal=pts/0 res=success'UID="jecka" AUID="jecka"
type=CRED_REFR msg=audit(1751748945.107:837): pid=49539 uid=1000 auid=1000 ses=4 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='op=PAM:setcred grantors=pam_env,pam_fprintd acct="root" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/0 res=success'UID="jecka" AUID="jecka"
type=USER_START msg=audit(1751748945.111:838): pid=49539 uid=1000 auid=1000 ses=4 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='op=PAM:session_open grantors=pam_keyinit,pam_limits,pam_keyinit,pam_limits,pam_systemd,pam_unix acct="root" exe="/usr/bin/sudo" hostname=? addr=? terminal=/dev/pts/0 res=success'UID="jecka" AUID="jecka"
type=USER_AUTH msg=audit(1751748945.122:839): pid=49541 uid=0 auid=1000 ses=4 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='op=PAM:authentication grantors=pam_rootok acct="root" exe="/usr/bin/su" hostname=? addr=? terminal=/dev/pts/1 res=success'UID="root" AUID="jecka"
type=USER_ACCT msg=audit(1751748945.122:840): pid=49541 uid=0 auid=1000 ses=4 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='op=PAM:accounting grantors=pam_succeed_if acct="root" exe="/usr/bin/su" hostname=? addr=? terminal=/dev/pts/1 res=success'UID="root" AUID="jecka"
type=CRED_ACQ msg=audit(1751748945.122:841): pid=49541 uid=0 auid=1000 ses=4 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='op=PAM:setcred grantors=pam_rootok acct="root" exe="/usr/bin/su" hostname=? addr=? terminal=/dev/pts/1 res=success'UID="root" AUID="jecka"
type=USER_START msg=audit(1751748945.237:842): pid=49541 uid=0 auid=1000 ses=4 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='op=PAM:session_open grantors=pam_keyinit,pam_keyinit,pam_limits,pam_systemd,pam_unix,pam_umask acct="root" exe="/usr/bin/su" hostname=? addr=? terminal=/dev/pts/1 res=success'UID="root" AUID="jecka"
type=BPF msg=audit(1751748945.274:843): prog-id=115 op=LOAD
type=BPF msg=audit(1751748945.274:844): prog-id=116 op=LOAD
type=BPF msg=audit(1751748945.274:845): prog-id=117 op=LOAD
type=SERVICE_START msg=audit(1751748945.351:846): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-hostnamed comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'UID="root" AUID="unset"
type=SERVICE_STOP msg=audit(1751748975.390:847): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=systemd-hostnamed comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'UID="root" AUID="unset"
type=BPF msg=audit(1751748975.398:848): prog-id=117 op=UNLOAD
type=BPF msg=audit(1751748975.398:849): prog-id=116 op=UNLOAD
type=BPF msg=audit(1751748975.398:850): prog-id=115 op=UNLOAD
type=AVC msg=audit(1751749001.174:851): avc:  denied  { name_bind } for  pid=49945 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
type=SYSCALL msg=audit(1751749001.174:851): arch=c000003e syscall=49 success=no exit=-13 a0=a a1=557ab228b2d8 a2=10 a3=7ffc1fba7300 items=0 ppid=1 pid=49945 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)ARCH=x86_64 SYSCALL=bind AUID="unset" UID="root" GID="root" EUID="root" SUID="root" FSUID="root" EGID="root" SGID="root" FSGID="root"
type=PROCTITLE msg=audit(1751749001.174:851): proctitle=2F7573722F7362696E2F6E67696E78002D74
type=SERVICE_START msg=audit(1751749001.176:852): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'UID="root" AUID="unset"
```

В нем мы найдем  avc:  denied  { name_bind } for  pid=49945 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0,  это  говорит нам о том, что сервер не может запуститься на порту 4881 

Уточним через утилиту audit2why  что происходит 

```bash 
[root@localhost ~]# grep 1751749001.174:851 /var/log/audit/audit.log  | audit2why
type=AVC msg=audit(1751749001.174:851): avc:  denied  { name_bind } for  pid=49945 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

        Was caused by:
        The boolean nis_enabled was set incorrectly.
        Description:
        Allow nis to enabled

        Allow access by executing:
        # setsebool -P nis_enabled 1
```
На выходе получаем требуемые действия для того, что бы наш сервис запустился на не стандартном порту.
ВЫполним действия и пробуем запустить сервис

```bash 
 setsebool -P nis_enabled on
[root@localhost ~]# systemctl restart nginx.service
[root@localhost ~]# systemctl status nginx.service
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: disabled)
    Drop-In: /usr/lib/systemd/system/service.d
             └─10-timeout-abort.conf
     Active: active (running) since Sun 2025-07-06 00:01:04 MSK; 8s ago
    Process: 51543 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 51550 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 51551 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 51552 (nginx)
      Tasks: 3 (limit: 4667)
     Memory: 3.3M
        CPU: 78ms
     CGroup: /system.slice/nginx.service
             ├─51552 "nginx: master process /usr/sbin/nginx"
             ├─51553 "nginx: worker process"
             └─51554 "nginx: worker process"

июл 06 00:01:04 localhost.localdomain systemd[1]: Starting nginx.service - The nginx HTTP and reverse proxy server...
июл 06 00:01:04 localhost.localdomain nginx[51550]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
июл 06 00:01:04 localhost.localdomain nginx[51550]: nginx: configuration file /etc/nginx/nginx.conf test is successful
июл 06 00:01:04 localhost.localdomain systemd[1]: Started nginx.service - The nginx HTTP and reverse proxy server.
```

Послен запуска сервиса  из браузера откроем http:\\ip_адресс_сервера:4881 и посмотрим откроется ли страница

![Страница успешно открывается](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/Selinux/Site4881.png)

Выключем первое решение путем отключения разрешения

```bash
[root@localhost ~]# setsebool -P nis_enabled off
```


1.2 Пробуем Добавить нестандартный порт 

```Basg
[root@localhost ~]#  semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
[root@localhost ~]# semanage port -a -t http_port_t -p tcp 4881
[root@localhost ~]#  semanage port -l | grep  http_port_t
http_port_t                    tcp      4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
```

Порт добавлен. Пробуем перезапусить службу и видим что служба успешно запуститься

```bash 
[root@localhost ~]# systemctl restart nginx
[root@localhost ~]# systemctl status nginx.service
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: disabled)
    Drop-In: /usr/lib/systemd/system/service.d
             └─10-timeout-abort.conf
     Active: active (running) since Sun 2025-07-06 00:19:21 MSK; 10s ago
    Process: 58121 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 58122 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 58123 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 58124 (nginx)
      Tasks: 3 (limit: 4667)
     Memory: 3.3M
        CPU: 79ms
     CGroup: /system.slice/nginx.service
             ├─58124 "nginx: master process /usr/sbin/nginx"
             ├─58125 "nginx: worker process"
             └─58126 "nginx: worker process"

июл 06 00:19:21 localhost.localdomain systemd[1]: Starting nginx.service - The nginx HTTP and reverse proxy server...
июл 06 00:19:21 localhost.localdomain nginx[58122]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
июл 06 00:19:21 localhost.localdomain nginx[58122]: nginx: configuration file /etc/nginx/nginx.conf test is successful
июл 06 00:19:21 localhost.localdomain systemd[1]: Started nginx.service - The nginx HTTP and reverse proxy server.
```

![Проверим страницу](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/Selinux/Site4881.png)

Удалим порт из правила 

```bash
[root@localhost ~]#  semanage port -d -t http_port_t -p tcp 4881
[root@localhost ~]# semanage port -l | grep  http_port_t
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
``` 


1.3 Для последнего задания изменим порт на 4882 для интереса.
 На основании лога аудита просим систему создать правило для запуска сервиса на нестандартном порту 

 ```bash
 server {
        listen       80;
        listen       [::]:80;
        listen          4881;
        server_name  _;
        root         /usr/share/nginx/html;
        index index.html index.htm;
        autoindex on;
 ```  

Создадим модуль на основании лога и примененим его, а так же перезапустим сервис после применения

```bash
 tail -n 5 /var/log/audit/audit.log  | audit2allow -M nginx
 [root@localhost ~]# semodule -i nginx.pp
[root@localhost ~]# systemctl start nginx
[root@localhost ~]# systemctl restart nginx
[root@localhost ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: disabled)
    Drop-In: /usr/lib/systemd/system/service.d
             └─10-timeout-abort.conf
     Active: active (running) since Sun 2025-07-06 00:35:23 MSK; 8s ago
    Process: 63937 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 63938 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 63939 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 63940 (nginx)
      Tasks: 3 (limit: 4667)
     Memory: 3.3M
        CPU: 77ms
     CGroup: /system.slice/nginx.service
             ├─63940 "nginx: master process /usr/sbin/nginx"
             ├─63941 "nginx: worker process"
             └─63942 "nginx: worker process"

июл 06 00:35:23 localhost.localdomain systemd[1]: Starting nginx.service - The nginx HTTP and reverse proxy server...
июл 06 00:35:23 localhost.localdomain nginx[63938]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
июл 06 00:35:23 localhost.localdomain nginx[63938]: nginx: configuration file /etc/nginx/nginx.conf test is successful
июл 06 00:35:23 localhost.localdomain systemd[1]: Started nginx.service - The nginx HTTP and reverse proxy server.

 ```
![Проверим страницу c портом 4882](https://raw.githubusercontent.com/jecka2/repo/refs/heads/main/Selinux/Site4882.png)

Как мы видим, все успешно работает 1 Часть завершена


2. 

2.1 Разворачивание Vagrant

```bash
  jecka   ~/Documents/otus/vagrant_selinux_dns_problems git-[ main]-  vagrant up            
Bringing machine 'ns01' up with 'virtualbox' provider...
Bringing machine 'client' up with 'virtualbox' provider...
==> ns01: Box 'almalinux/9' could not be found. Attempting to find and install...
    ns01: Box Provider: virtualbox
    ns01: Box Version: 9.4.20240805
==> ns01: Loading metadata for box 'almalinux/9'
    ns01: URL: https://vagrantcloud.com/api/v2/vagrant/almalinux/9
==> ns01: Adding box 'almalinux/9' (v9.4.20240805) for provider: virtualbox (amd64)
    ns01: Downloading: https://vagrantcloud.com/almalinux/boxes/9/versions/9.4.20240805/providers/virtualbox/amd64/vagrant.box
==> ns01: Box download is resuming from prior download progress
    ns01: Calculating and comparing box checksum...
==> ns01: Successfully added box 'almalinux/9' (v9.4.20240805) for 'virtualbox (amd64)'!
==> ns01: Importing base box 'almalinux/9'...
==> ns01: Matching MAC address for NAT networking...
==> ns01: Checking if box 'almalinux/9' version '9.4.20240805' is up to date...
==> ns01: Setting the name of the VM: vagrant_selinux_dns_problems_ns01_1751788951829_18201
==> ns01: Clearing any previously set network interfaces...
==> ns01: Preparing network interfaces based on configuration...
    ns01: Adapter 1: nat
    ns01: Adapter 2: intnet
==> ns01: Forwarding ports...
    ns01: 22 (guest) => 2222 (host) (adapter 1)
==> ns01: Running 'pre-boot' VM customizations...
==> ns01: Booting VM...
==> ns01: Waiting for machine to boot. This may take a few minutes...
    ns01: SSH address: 127.0.0.1:2222
    ns01: SSH username: vagrant
    ns01: SSH auth method: private key
    ns01: 
    ns01: Vagrant insecure key detected. Vagrant will automatically replace
    ns01: this with a newly generated keypair for better security.
    ns01: 
    ns01: Inserting generated public key within guest...
    ns01: Removing insecure key from the guest if it's present...
    ns01: Key inserted! Disconnecting and reconnecting using new SSH key...
==> ns01: Machine booted and ready!
==> ns01: Checking for guest additions in VM...
    ns01: The guest additions on this VM do not match the installed version of
    ns01: VirtualBox! In most cases this is fine, but in rare cases it can
    ns01: prevent things such as shared folders from working properly. If you see
    ns01: shared folder errors, please make sure the guest additions within the
    ns01: virtual machine match the version of VirtualBox you have installed on
    ns01: your host and reload your VM.
    ns01: 
    ns01: Guest Additions Version: 7.0.20
    ns01: VirtualBox Version: 7.1
==> ns01: Setting hostname...
==> ns01: Configuring and enabling network interfaces...
==> ns01: Running provisioner: ansible...
    ns01: Running ansible-playbook...

PLAY [all] *********************************************************************

TASK [Gathering Facts] *********************************************************
[WARNING]: Platform linux on host ns01 is using the discovered Python
interpreter at /usr/bin/python3.9, but future installation of another Python
interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-
core/2.18/reference_appendices/interpreter_discovery.html for more information.
ok: [ns01]

TASK [install packages] ********************************************************
changed: [ns01]

PLAY [ns01] ********************************************************************

TASK [Gathering Facts] *********************************************************
ok: [ns01]

TASK [copy named.conf] *********************************************************
changed: [ns01]

TASK [copy master zone dns.lab] ************************************************
changed: [ns01] => (item=/home/jecka/Documents/otus/vagrant_selinux_dns_problems/provisioning/files/ns01/named.dns.lab.view1)
changed: [ns01] => (item=/home/jecka/Documents/otus/vagrant_selinux_dns_problems/provisioning/files/ns01/named.dns.lab)

TASK [copy dynamic zone ddns.lab] **********************************************
changed: [ns01]

TASK [copy dynamic zone ddns.lab.view1] ****************************************
changed: [ns01]

TASK [copy master zone newdns.lab] *********************************************
changed: [ns01]

TASK [copy rev zones] **********************************************************
changed: [ns01]

TASK [copy resolv.conf to server] **********************************************
changed: [ns01]

TASK [copy transferkey to server] **********************************************
changed: [ns01]

TASK [set /etc/named permissions] **********************************************
changed: [ns01]

TASK [set /etc/named/dynamic permissions] **************************************
changed: [ns01]

TASK [ensure named is running and enabled] *************************************
changed: [ns01]
[WARNING]: Could not match supplied host pattern, ignoring: client

PLAY [client] ******************************************************************
skipping: no hosts matched

PLAY RECAP *********************************************************************
ns01                       : ok=14   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

==> client: Box 'almalinux/9' could not be found. Attempting to find and install...
    client: Box Provider: virtualbox
    client: Box Version: 9.4.20240805
==> client: Loading metadata for box 'almalinux/9'
    client: URL: https://vagrantcloud.com/api/v2/vagrant/almalinux/9
==> client: Adding box 'almalinux/9' (v9.4.20240805) for provider: virtualbox (amd64)
==> client: Importing base box 'almalinux/9'...
==> client: Matching MAC address for NAT networking...
==> client: Checking if box 'almalinux/9' version '9.4.20240805' is up to date...
==> client: Setting the name of the VM: vagrant_selinux_dns_problems_client_1751789073032_57111
==> client: Fixed port collision for 22 => 2222. Now on port 2200.
==> client: Clearing any previously set network interfaces...
==> client: Preparing network interfaces based on configuration...
    client: Adapter 1: nat
    client: Adapter 2: intnet
==> client: Forwarding ports...
    client: 22 (guest) => 2200 (host) (adapter 1)
==> client: Running 'pre-boot' VM customizations...
==> client: Booting VM...
==> client: Waiting for machine to boot. This may take a few minutes...
    client: SSH address: 127.0.0.1:2200
    client: SSH username: vagrant
    client: SSH auth method: private key
    client: 
    client: Vagrant insecure key detected. Vagrant will automatically replace
    client: this with a newly generated keypair for better security.
    client: 
    client: Inserting generated public key within guest...
    client: Removing insecure key from the guest if it's present...
    client: Key inserted! Disconnecting and reconnecting using new SSH key...
==> client: Machine booted and ready!
==> client: Checking for guest additions in VM...
    client: The guest additions on this VM do not match the installed version of
    client: VirtualBox! In most cases this is fine, but in rare cases it can
    client: prevent things such as shared folders from working properly. If you see
    client: shared folder errors, please make sure the guest additions within the
    client: virtual machine match the version of VirtualBox you have installed on
    client: your host and reload your VM.
    client: 
    client: Guest Additions Version: 7.0.20
    client: VirtualBox Version: 7.1
==> client: Setting hostname...
==> client: Configuring and enabling network interfaces...
==> client: Running provisioner: ansible...
    client: Running ansible-playbook...

PLAY [all] *********************************************************************

TASK [Gathering Facts] *********************************************************
[WARNING]: Platform linux on host client is using the discovered Python
interpreter at /usr/bin/python3.9, but future installation of another Python
interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-
core/2.18/reference_appendices/interpreter_discovery.html for more information.
ok: [client]

TASK [install packages] ********************************************************
changed: [client]

PLAY [ns01] ********************************************************************
skipping: no hosts matched

PLAY [client] ******************************************************************

TASK [Gathering Facts] *********************************************************
ok: [client]

TASK [copy resolv.conf to the client] ******************************************
changed: [client]

TASK [copy rndc conf file] *****************************************************
changed: [client]

TASK [copy motd to the client] *************************************************
changed: [client]

TASK [copy transferkey to client] **********************************************
changed: [client]

PLAY RECAP *********************************************************************
client                     : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

  jecka   ~/Documents/otus/vagrant_selinux_dns_problems git-[ main]-  vagrant status
Current machine states:

ns01                      running (virtualbox)
client                    running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```
 2.2 Подключимтся к клиентской VM и попробуем обновить данные в DNS зоне

 ```bash
  jecka   ~/Documents/otus/vagrant_selinux_dns_problems git-[ main]-  vagrant ssh client
###############################
### Welcome to the DNS lab! ###
###############################

- Use this client to test the enviroment
- with dig or nslookup. Ex:
    dig @192.168.50.10 ns01.dns.lab

- nsupdate is available in the ddns.lab zone. Ex:
    nsupdate -k /etc/named.zonetransfer.key
    server 192.168.50.10
    zone ddns.lab 
    update add www.ddns.lab. 60 A 192.168.50.15
    send

- rndc is also available to manage the servers
    rndc -c ~/rndc.conf reload

###############################
### Enjoy! ####################
###############################
Last login: Sun Jul  6 22:04:56 2025 from 10.0.2.2
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
update failed: SERVFAIL
> quit
[vagrant@client ~]$ sudo -i
[root@client ~]# cat /var/log/audit/audit.log | audit2why 
type=AVC msg=audit(1751839461.875:670): avc:  denied  { dac_read_search } for  pid=3301 comm="20-chrony-dhcp" capability=2  scontext=system_u:system_r:NetworkManager_dispatcher_chronyc_t:s0 tcontext=system_u:system_r:NetworkManager_dispatcher_chronyc_t:s0 tclass=capability permissive=0

	Was caused by:
		Missing type enforcement (TE) allow rule.

		You can use audit2allow to generate a loadable module to allow this access.

type=AVC msg=audit(1751839461.875:670): avc:  denied  { dac_override } for  pid=3301 comm="20-chrony-dhcp" capability=1  scontext=system_u:system_r:NetworkManager_dispatcher_chronyc_t:s0 tcontext=system_u:system_r:NetworkManager_dispatcher_chronyc_t:s0 tclass=capability permissive=0

	Was caused by:
		Missing type enforcement (TE) allow rule.

		You can use audit2allow to generate a loadable module to allow this access.

```

2.3 Не найдя ошибок относящихся к нашей теме на клиентском ПК,  подклюимся к серверу ns01  и посмотрим ошибки аудита

```bash 
  jecka   ~/Documents/otus/vagrant_selinux_dns_problems git-[ main]-  vagrant ssh ns01  
Last login: Sun Jul  6 22:03:39 2025 from 10.0.2.2
[vagrant@ns01 ~]$ sudo -i 
[root@ns01 ~]# cat /var/log/audit/audit.log | audit2why 
type=AVC msg=audit(1751839369.955:670): avc:  denied  { dac_read_search } for  pid=3300 comm="20-chrony-dhcp" capability=2  scontext=system_u:system_r:NetworkManager_dispatcher_chronyc_t:s0 tcontext=system_u:system_r:NetworkManager_dispatcher_chronyc_t:s0 tclass=capability permissive=0

	Was caused by:
		Missing type enforcement (TE) allow rule.

		You can use audit2allow to generate a loadable module to allow this access.

type=AVC msg=audit(1751839369.955:670): avc:  denied  { dac_override } for  pid=3300 comm="20-chrony-dhcp" capability=1  scontext=system_u:system_r:NetworkManager_dispatcher_chronyc_t:s0 tcontext=system_u:system_r:NetworkManager_dispatcher_chronyc_t:s0 tclass=capability permissive=0

	Was caused by:
		Missing type enforcement (TE) allow rule.

		You can use audit2allow to generate a loadable module to allow this access.

type=AVC msg=audit(1751839780.355:1733): avc:  denied  { write } for  pid=9539 comm="isc-net-0001" name="dynamic" dev="sda4" ino=34029558 scontext=system_u:system_r:named_t:s0 tcontext=unconfined_u:object_r:named_conf_t:s0 tclass=dir permissive=0

	Was caused by:
		Missing type enforcement (TE) allow rule.

		You can use audit2allow to generate a loadable module to allow this access.

```

2.4 Обнаруживаем ошибку относящуюсся к сервису named, далее проверяем контекст 

```bash

[root@ns01 ~]# ls -alZ /var/named/named.localhost 
-rw-r-----. 1 root named system_u:object_r:named_zone_t:s0 152 Jun 24 13:47 /var/named/named.localhost
[root@ns01 ~]# ls -alZ /var/named
total 20
drwxrwx--T.  5 root  named system_u:object_r:named_zone_t:s0   127 Jul  6 22:27 .
drwxr-xr-x. 20 root  root  system_u:object_r:var_t:s0         4096 Jul  6 22:03 ..
drwxrwx---.  2 named named system_u:object_r:named_cache_t:s0   23 Jul  6 22:03 data
drwxrwx---.  2 named named system_u:object_r:named_cache_t:s0   94 Jul  6 22:28 dynamic
-rw-r-----.  1 root  named system_u:object_r:named_conf_t:s0  2112 Jun 24 13:47 named.ca
-rw-r-----.  1 root  named system_u:object_r:named_zone_t:s0   152 Jun 24 13:47 named.empty
-rw-r-----.  1 root  named system_u:object_r:named_zone_t:s0   152 Jun 24 13:47 named.localhost
-rw-r-----.  1 root  named system_u:object_r:named_zone_t:s0   168 Jun 24 13:47 named.loopback
drwxrwx---.  2 named named system_u:object_r:named_cache_t:s0    6 Jun 24 13:47 slaves
```

2.5 Проверяем какой контекст должен быть в системе 

```bash
[root@ns01 ~]# sudo semanage fcontext -l | grep named
/dev/gpmdata                                       named pipe         system_u:object_r:gpmctl_t:s0 
/dev/initctl                                       named pipe         system_u:object_r:initctl_t:s0 
/dev/xconsole                                      named pipe         system_u:object_r:xconsole_device_t:s0 
/dev/xen/tapctrl.*                                 named pipe         system_u:object_r:xenctl_t:s0 
/etc/named(/.*)?                                   all files          system_u:object_r:named_conf_t:s0 
/etc/named\.caching-nameserver\.conf               regular file       system_u:object_r:named_conf_t:s0 
/etc/named\.conf                                   regular file       system_u:object_r:named_conf_t:s0 
/etc/named\.rfc1912.zones                          regular file       system_u:object_r:named_conf_t:s0 
/etc/named\.root\.hints                            regular file       system_u:object_r:named_conf_t:s0 
/etc/rc\.d/init\.d/named                           regular file       system_u:object_r:named_initrc_exec_t:s0 
/etc/rc\.d/init\.d/named-sdb                       regular file       system_u:object_r:named_initrc_exec_t:s0 
/etc/rc\.d/init\.d/unbound                         regular file       system_u:object_r:named_initrc_exec_t:s0 
/etc/rndc.*                                        regular file       system_u:object_r:named_conf_t:s0 
/etc/unbound(/.*)?                                 all files          system_u:object_r:named_conf_t:s0 
/usr/lib/systemd/system/named-sdb.*                regular file       system_u:object_r:named_unit_file_t:s0 
/usr/lib/systemd/system/named.*                    regular file       system_u:object_r:named_unit_file_t:s0 
/usr/lib/systemd/system/unbound.*                  regular file       system_u:object_r:named_unit_file_t:s0 
/usr/lib/systemd/systemd-hostnamed                 regular file       system_u:object_r:systemd_hostnamed_exec_t:s0 
/usr/sbin/lwresd                                   regular file       system_u:object_r:named_exec_t:s0 
/usr/sbin/named                                    regular file       system_u:object_r:named_exec_t:s0 
/usr/sbin/named-checkconf                          regular file       system_u:object_r:named_checkconf_exec_t:s0 
/usr/sbin/named-pkcs11                             regular file       system_u:object_r:named_exec_t:s0 
/usr/sbin/named-sdb                                regular file       system_u:object_r:named_exec_t:s0 
/usr/sbin/unbound                                  regular file       system_u:object_r:named_exec_t:s0 
/usr/sbin/unbound-anchor                           regular file       system_u:object_r:named_exec_t:s0 
/usr/sbin/unbound-checkconf                        regular file       system_u:object_r:named_exec_t:s0 
/usr/sbin/unbound-control                          regular file       system_u:object_r:named_exec_t:s0 
/usr/share/munin/plugins/named                     regular file       system_u:object_r:services_munin_plugin_exec_t:s0 
/var/lib/softhsm(/.*)?                             all files          system_u:object_r:named_cache_t:s0 
/var/lib/unbound(/.*)?                             all files          system_u:object_r:named_cache_t:s0 
/var/log/named.*                                   regular file       system_u:object_r:named_log_t:s0 
/var/named(/.*)?                                   all files          system_u:object_r:named_zone_t:s0 
/var/named/chroot(/.*)?                            all files          system_u:object_r:named_conf_t:s0 
/var/named/chroot/dev                              directory          system_u:object_r:device_t:s0 
/var/named/chroot/dev/log                          socket             system_u:object_r:devlog_t:s0 
/var/named/chroot/dev/null                         character device   system_u:object_r:null_device_t:s0 
/var/named/chroot/dev/random                       character device   system_u:object_r:random_device_t:s0 
/var/named/chroot/dev/urandom                      character device   system_u:object_r:urandom_device_t:s0 
/var/named/chroot/dev/zero                         character device   system_u:object_r:zero_device_t:s0 
/var/named/chroot/etc(/.*)?                        all files          system_u:object_r:etc_t:s0 
/var/named/chroot/etc/localtime                    regular file       system_u:object_r:locale_t:s0 
/var/named/chroot/etc/named\.caching-nameserver\.conf regular file       system_u:object_r:named_conf_t:s0 
/var/named/chroot/etc/named\.conf                  regular file       system_u:object_r:named_conf_t:s0 
/var/named/chroot/etc/named\.rfc1912.zones         regular file       system_u:object_r:named_conf_t:s0 
/var/named/chroot/etc/named\.root\.hints           regular file       system_u:object_r:named_conf_t:s0 
/var/named/chroot/etc/pki(/.*)?                    all files          system_u:object_r:cert_t:s0 
/var/named/chroot/etc/rndc\.key                    regular file       system_u:object_r:dnssec_t:s0 
/var/named/chroot/lib(/.*)?                        all files          system_u:object_r:lib_t:s0 
/var/named/chroot/proc(/.*)?                       all files          <<None>>
/var/named/chroot/run/named.*                      all files          system_u:object_r:named_var_run_t:s0 
/var/named/chroot/usr/lib(/.*)?                    all files          system_u:object_r:lib_t:s0 
/var/named/chroot/var/log                          directory          system_u:object_r:var_log_t:s0 
/var/named/chroot/var/log/named.*                  regular file       system_u:object_r:named_log_t:s0 
/var/named/chroot/var/named(/.*)?                  all files          system_u:object_r:named_zone_t:s0 
/var/named/chroot/var/named/data(/.*)?             all files          system_u:object_r:named_cache_t:s0 
/var/named/chroot/var/named/dynamic(/.*)?          all files          system_u:object_r:named_cache_t:s0 
/var/named/chroot/var/named/named\.ca              regular file       system_u:object_r:named_conf_t:s0 
/var/named/chroot/var/named/slaves(/.*)?           all files          system_u:object_r:named_cache_t:s0 
/var/named/chroot/var/run/dbus(/.*)?               all files          system_u:object_r:system_dbusd_var_run_t:s0 
/var/named/chroot/var/run/named.*                  all files          system_u:object_r:named_var_run_t:s0 
/var/named/chroot/var/tmp(/.*)?                    all files          system_u:object_r:named_cache_t:s0 
/var/named/chroot_sdb/dev                          directory          system_u:object_r:device_t:s0 
/var/named/chroot_sdb/dev/null                     character device   system_u:object_r:null_device_t:s0 
/var/named/chroot_sdb/dev/random                   character device   system_u:object_r:random_device_t:s0 
/var/named/chroot_sdb/dev/urandom                  character device   system_u:object_r:urandom_device_t:s0 
/var/named/chroot_sdb/dev/zero                     character device   system_u:object_r:zero_device_t:s0 
/var/named/data(/.*)?                              all files          system_u:object_r:named_cache_t:s0 
/var/named/dynamic(/.*)?                           all files          system_u:object_r:named_cache_t:s0 
/var/named/named\.ca                               regular file       system_u:object_r:named_conf_t:s0 
/var/named/slaves(/.*)?                            all files          system_u:object_r:named_cache_t:s0 
/var/run/bind(/.*)?                                all files          system_u:object_r:named_var_run_t:s0 
/var/run/ecblp0                                    named pipe         system_u:object_r:cupsd_var_run_t:s0 
/var/run/initctl                                   named pipe         system_u:object_r:initctl_t:s0 
/var/run/named(/.*)?                               all files          system_u:object_r:named_var_run_t:s0 
/var/run/ndc                                       socket             system_u:object_r:named_var_run_t:s0 
/var/run/systemd/initctl/fifo                      named pipe         system_u:object_r:initctl_t:s0 
/var/run/unbound(/.*)?                             all files          system_u:object_r:named_var_run_t:s0 
/var/named/chroot/usr/lib64 = /usr/lib
/var/named/chroot/lib64 = /usr/lib
/var/named/chroot/var = /var
```
2.6 Видим что контексты разные Изменяем контекст на верный

```bash
[root@ns01 ~]# sudo chcon -R t named_zone_t /etc/named
chcon: invalid context: ‘t’: Invalid argument
[root@ns01 ~]# sudo chcon -R -t named_zone_t /etc/named
[root@ns01 ~]# ls -alZ /var/named
total 20
drwxrwx--T.  5 root  named system_u:object_r:named_zone_t:s0   127 Jul  6 22:27 .
drwxr-xr-x. 20 root  root  system_u:object_r:var_t:s0         4096 Jul  6 22:03 ..
drwxrwx---.  2 named named system_u:object_r:named_cache_t:s0   23 Jul  6 22:03 data
drwxrwx---.  2 named named system_u:object_r:named_cache_t:s0   94 Jul  6 22:28 dynamic
-rw-r-----.  1 root  named system_u:object_r:named_conf_t:s0  2112 Jun 24 13:47 named.ca
-rw-r-----.  1 root  named system_u:object_r:named_zone_t:s0   152 Jun 24 13:47 named.empty
-rw-r-----.  1 root  named system_u:object_r:named_zone_t:s0   152 Jun 24 13:47 named.localhost
-rw-r-----.  1 root  named system_u:object_r:named_zone_t:s0   168 Jun 24 13:47 named.loopback
drwxrwx---.  2 named named system_u:object_r:named_cache_t:s0    6 Jun 24 13:47 slaves

```
2.7 После перемаркировки  обьетов на клиенте пытаемся выполнить обновленеи зоны 
```bash

[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
> quit
[vagrant@client ~]$ dig www.ddns.lab

; <<>> DiG 9.16.23-RH <<>> www.ddns.lab
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12049
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: dd026de51413c1e501000000686aff842532be380be912d3 (good)
;; QUESTION SECTION:
;www.ddns.lab.			IN	A

;; ANSWER SECTION:
www.ddns.lab.		60	IN	A	192.168.50.15

;; Query time: 1 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Sun Jul 06 22:58:12 UTC 2025
;; MSG SIZE  rcvd: 85

[vagrant@client ~]$ dig @192.168.50.10  www.ddns.lab 

; <<>> DiG 9.16.23-RH <<>> @192.168.50.10 www.ddns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 64428
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 19006f16ccb492f701000000686b001f6566abb3a647e968 (good)
;; QUESTION SECTION:
;www.ddns.lab.			IN	A

;; ANSWER SECTION:
www.ddns.lab.		60	IN	A	192.168.50.15

;; Query time: 1 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Sun Jul 06 23:00:47 UTC 2025
;; MSG SIZE  rcvd: 85
```

Задание выполеннено. Зона успешно оновлена
</ul></details>