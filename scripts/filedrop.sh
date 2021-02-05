#!/bin/bash
apt-get update
useradd -m glasswall
#userdel -r myinstalluser
#cd /tmp
wget https://raw.githubusercontent.com/MariuszFerdyn/filedrop-azure/main/scripts/filedrop2.sh -O ~glasswall/filedrop2.sh
chmod 755 ~glasswall/filedrop2.sh
su -l glasswall ./filedrop2.sh
