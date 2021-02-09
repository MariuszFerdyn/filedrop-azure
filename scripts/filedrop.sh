#!/bin/bash
useradd -m glasswall
wget https://raw.githubusercontent.com/MariuszFerdyn/filedrop-azure/main/scripts/filedrop2.sh -O ~glasswall/filedrop2.sh
chmod 755 ~glasswall/filedrop2.sh
echo 'glasswall ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/glasswall
echo 0440 /etc/sudoers.d/glasswall
su -l glasswall ./filedrop2.sh
#rm -f /etc/sudoers.d/glasswall
#userdel -r glasswall
