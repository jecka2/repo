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

