#!/bin/bash
apt-get update
cd /tmp
wget https://raw.githubusercontent.com/MariuszFerdyn/filedrop-azure/main/scripts/filedrop2.sh
chmod 755 filedrop.sh
./filedrop.sh
