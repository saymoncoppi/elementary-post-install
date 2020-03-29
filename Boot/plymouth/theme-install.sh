#!/usr/bin/env bash
#
# theme-install.sh
#=======================================================
# About: A simple wrapper script to install Elementary OS minimalist theme for Plymouth
# Source : https://github.com/saymoncoppi/elementary-post-install
# Author:     Saymon Coppi <saymoncoppi@gmail.com>
# Maintainer: Saymon Coppi <saymoncoppi@gmail.com>
# Created: 29/02/2020
#
# License:
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Text styles 
bold=$(tput bold)
normal=$(tput sgr0)

clear; set -e
printf "${bold}Elementary OS minimalist theme for Plymouth${normal}\n"
echo "--------------------------------------------------"

# CHECKING CONNECTION
#=======================================================
# Base URLs
GIT_URL="https://github.com/saymoncoppi/elementary-post-install"

# Check Internet connection
function check_connection {
    wget --quiet --tries=1 --spider "${GIT_URL}"
    if [ $? -eq 0 ]; then
        # Check Page content
        PAGE_TEST=$(wget --spider --server-response ${GIT_URL} ip-current 2>&1 | grep -c 'HTTP/1.1 200 OK')
        if [ $PAGE_TEST = 1 ]; then
            echo "Installing..."
        else
            echo "Ops! $GIT_URL is DOWN, sorry..."
            exit
        fi
    else
        echo "Ops! No Internet Connection!"
        exit
    fi
}

check_connection

# RUN AS ROOT
#=======================================================
ROOT_UID=0 # check command avalibility
function has_command() {
    command -v $1 > /dev/null
}
if [ "$UID" -eq "$ROOT_UID" ]; then



# BACKUPING THEME FOLDER
#=======================================================
PLYMOUTH_PATH="/usr/share/plymouth"
THEME_FOLDER="${PLYMOUTH_PATH}/themes"
THEME_FOLDER_BKP="${THEME_FOLDER}_BKP"

if [ -d ${THEME_FOLDER_BKP} ]; then
    rm -rf ${THEME_FOLDER_BKP}
    cp -R ${THEME_FOLDER} ${THEME_FOLDER_BKP}
else
    cp -R ${THEME_FOLDER} ${THEME_FOLDER_BKP}
fi



cd $THEME_FOLDER
# keeping folders (details text tribar)
ls -1 | grep -E -v 'details|text|tribar' | xargs rm -rf

efolder="${THEME_FOLDER}/elementary"
mkdir "$efolder"
cd "$efolder"
THEME_URL="https://raw.githubusercontent.com/saymoncoppi/elementary-post-install/master/Boot/plymouth/elementary/"
for THEME_FILE in logo.png elementary.plymouth elementary.script
	do
		wget -q "${THEME_URL}${THEME_FILE}"
	done


#MOVING ASSETS
#=======================================================
if [ -f "/usr/share/plymouth/themes/default.plymouth" ]; then
    rm -rf "/usr/share/plymouth/themes/default.plymouth"
fi

if [ -f "/etc/alternatives/default.plymouth" ]; then
    rm -rf "/etc/alternatives/default.plymouth"
fi

ln -s "/usr/share/plymouth/themes/elementary/elementary.plymouth" "/etc/alternatives/default.plymouth"
ln -s "/etc/alternatives/default.plymouth" "/usr/share/plymouth/themes/default.plymouth"


#UPDATING /ETC/ALTERNATIVES
#=======================================================
update-alternatives --install "/usr/share/plymouth/themes/default.plymouth" "default.plymouth" "/usr/share/plymouth/themes/elementary/elementary.plymouth" "100"
update-initramfs -u



# TESTING 
#=======================================================
DO_TEST="YES"
if [ $DO_TEST == "YES" ]; then
DURATION=5
plymouthd; plymouth --show-splash ; for ((I=0; I<$DURATION; I++)); do plymouth --update=test$I ; sleep 1; done; plymouth quit
fi

else



# SUDO CONFIRMATION
#=======================================================
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"
fi

# SUCESS!
#=======================================================
rm -rf ${THEME_FOLDER_BKP}
echo "Done! Erasing backup files" 
exit
