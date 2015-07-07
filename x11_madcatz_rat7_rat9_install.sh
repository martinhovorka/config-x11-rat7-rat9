#!/bin/bash
#    Configuration script that installs X11 configuration file for MadCatz RAT7 or RAT9 mouse
#    Copyright (C) 2015  Martin Hovorka
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


readonly INSTALL_DIR_DEFAULT="/etc/X11/xorg.conf.d"
readonly INSTALL_FILE_DEFAULT="910-rat.conf"
INSTALL_DIR="$INSTALL_DIR_DEFAULT"
INSTALL_FILE="$INSTALL_FILE_DEFAULT"

# print error messages and exit
exit_with_err()
{
    echo "Error: $@, exiting..." 1>&2
    exit 1
}

# clean opterr before parsing arguments
OPTERR=0

# parse arguments
while getopts "hd:f:" opt
do
    case "$opt" in
        h)
            echo -e "\nUsage $(basename $0) [ -f some_file_name ] [ -d some_directory ]\n" \
                "  -f some_file_name : specify custom name for installation file (default: $INSTALL_FILE_DEFAULT)\n" \
                "  -d some_directory : specify custom directory for installation (default: $INSTALL_DIR_DEFAULT)\n"
            exit 0
            ;;
        f)
            INSTALL_FILE=$OPTARG
            if [[ -z "$INSTALL_FILE" ]]
            then
                exit_with_err "File not specified"
            fi
            ;;
        d)
            INSTALL_DIR=$OPTARG
            if [[ -z "$INSTALL_DIR" ]]
            then
                exit_with_err "Installation directory not specified"
            fi
            ;;
    esac
    if [[ $OPTERR -ne 0 ]]
    then
        exit 1
    fi
done

if [[ $EUID -ne 0 ]]
then
    echo "Superuser (root) privileges required for execution of this script, exiting..." 1>&2
    exit 1
fi

# compose destination
readonly INSTALL_DEST="$INSTALL_DIR/$INSTALL_FILE"

# test if destination exits
if [[ -f $INSTALL_DEST ]]
then
    exit_with_err "Destination file '$INSTALL_DEST' already exist"
fi

# if destination directory does not exist create it
if [[ ! -d $INSTALL_DIR ]]
then
    mkdir -p $INSTALL_DIR
    if [[ $? -ne 0 ]]
    then
        exit_with_err "Failed to create destination directory '$INSTALL_DIR'"
    fi
fi

# write MadCatz RAT7/9 configuration
echo -e \
'Section "InputClass"
\tIdentifier "R.A.T."
\tMatchProduct "R.A.T.7|R.A.T.9"
\tMatchDevicePath "/dev/input/event*"
\tOption "Buttons" "17"
\tOption "ButtonMapping" "1 2 3 4 5 0 0 8 9 7 6 12 0 0 0 16 17"
\tOption "AutoReleaseButtons" "13 14 15"
\tOption "ZAxisMapping" "4 5 6 7"
EndSection' > $INSTALL_DEST

if [[ $? -ne 0 ]]
then
    exit_with_err "Failed to create file '$INSTALL_DEST' - installation unsuccessful"
fi

# write installation message and check if file is readable (just to be sure)
echo -e "File '$INSTALL_DEST' successfully installed... Configuration file content is as follows:"
cat $INSTALL_DEST
if [[ $? -ne 0 ]]
then
    exit_with_err "File '$INSTALL_DEST' was installed, however for some reason it is not readable"
fi

echo "PLEASE RESTART YOUR XSERVER FOR CHANGES TO TAKE PLACE IF APPLICABLE!"

exit 0
