#!/bin/bash
apt-get update
cd /tmp
wget https://raw.githubusercontent.com/MariuszFerdyn/filedrop-azure/main/scripts/filedrop.sh
chmod 755 filedrop.sh
/bin/bash filedrop.sh
