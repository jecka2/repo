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