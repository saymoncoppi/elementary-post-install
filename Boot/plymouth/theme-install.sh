#!/usr/bin/env bash
#
# theme-install.sh
#=======================================================
# About: A simple wrapper script to install Elementary OS minimalist theme for Plymouth
# Source : https://github.com/saymoncoppi/slide
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

clear; set -e

# CHECKING CONNECTION
#=======================================================
# Base URLs
GIT_URL="https://github.com/saymoncoppi/slide"

# Check Internet connection
function check_connection {
    wget --quiet --tries=1 --spider "${GIT_URL}"
    if [ $? -eq 0 ]; then
        # Check Page content
        LINK_TEST=$(HEAD $GIT_URL | grep '200\ OK' | wc -l)
        if [ $LINK_TEST = 1 ]; then
            echo "$GIT_URL is ok! Great, let's go..."
        else
            echo "Ops! $GIT_URL is not available, sorry..."
            exit
        fi
    else
        echo "Ops! No Internet Connection!"
        exit
    fi
}



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

THEME_URL="${GIT_URL}/boot/plymouth"
for THEME_FILE in logo.png elementary.plymouth elementary.script
	do
		sh -c 'wget -q --show-progress ${THEME_URL}/${THEME_FILE}'
	done



#MOVING ASSETS
#=======================================================
mv $TMP_FOLDER $PLYMOUTH_FOLDER
if [ -f "/usr/share/plymouth/themes/default.plymouth" ]; then
    rm -rf "/usr/share/plymouth/themes/default.plymouth"
fi

ln -s "/usr/share/plymouth/themes/elementary/elementary.plymouth" "/etc/alternatives/default.plymouth"

if [ -f "/etc/alternatives/default.plymouth" ]; then
    rm -rf "/etc/alternatives/default.plymouth"
fi
ln -s "/etc/alternatives/default.plymouth" "/usr/share/plymouth/themes/default.plymouth"



#UPDATING /ETC/ALTERNATIVES
#=======================================================
update-alternatives --install "/usr/share/plymouth/themes/default.plymouth" "default.plymouth" "/usr/share/plymouth/themes/elementary/elementary.plymouth" "100"
update-initramfs -u



# TESTING 
#=======================================================
DO_TEST="YES"
if [ $DO_TEST == "YES" ]; then
    plymouthd; plymouth --show-splash
    sleep ${1:-2}
    plymouth quit
fi

else



# SUDO CONFIRMATION
#=======================================================
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"
fi

# SUCESS!
#=======================================================
exit
