#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Install and uninstall script
# Copyright (C) 2019 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
# ============================================================================

# Pre-check if the Bash shell is installed and if this script has been
# executed using it
command -v bash >/dev/null 2>&1
if [ "$?" != "0" ]; then
    echo "error: The Bash shell does not seem to be installed, run the"\
                "compatibility"
    echo "       script ('compat.sh') for details."
    exit 1
elif [ ! -n "$BASH" ]; then
    echo "error: This script must be executed using the Bash shell, run the"
    echo "       compatibility script ('compat.sh') for details."
    exit 1
fi

script_dir=$(dirname $(readlink -f $0))
script_file=$(basename "$0")

source ${script_dir}/core/common.sh
source ${script_dir}/core/global.sh
set_global_variables

script_mode=""
temp_file="/tmp/salomon_install_$$.tmp"
target_dir="/opt/salomon"

target="${cl_yl}${target_dir}${cl_n}"
yesno="${cl_yl}Y${cl_n}/${cl_yl}N${cl_n}"
proceed="Do you wish to proceed"

available="everyone"
dirmod=775
filemod=664
execmod=$dirmod

confirm() {
    msg="$1"
    while true; do
        echo -e "$msg"
        read choice
        egrep "^yes$|^y$|^no$|^n$" -i <<< $choice &>/dev/null
        if [ $? -eq 0 ]; then
            egrep "^yes$|^y$" -i <<< $choice &>/dev/null
            if [ $? -eq 0 ]; then
                choice=1
                break
            else
                choice=0
                break
            fi
        fi
    done
}

perform() {
    echo
    echo -e "${cl_lc}SaLoMon install/uninstall script${cl_n}"
    echo
    if [ "$script_mode" = "install" ]; then
        echo -e "Installing SaLoMon is ${cl_yl}optional${cl_n} and not"\
                "mandatory in order to use it. Further"
        echo    "information can be found inside the documentation file for"\
                "this script."
        echo
    fi
    confirm "This will $script_action SaLoMon. $proceed ($yesno)? \c"
    if [ $choice -ne 1 ]; then
        echo
        echo -e "${cl_lr}Canceled${cl_n} on user request."
        echo
        exit
    fi
    echo
    if [ "$script_mode" = "install" ]; then
        echo "You can either make SaLoMon available for all users or only"\
             "for root. Do you"
        confirm "want to make it available for all users ($yesno)? \c"
        if [ $choice -ne 1 ]; then
            available="rootonly"
        fi
        echo
    fi
}

set_permissions() {
    chown -R root:root $target_dir
    if [ "$available" = "rootonly" ]; then
        dirmod=770
        filemod=660
        execmod=$dirmod
    fi
    find $target_dir > $temp_file
    while read line; do
        if [ -f "$line" ]; then
            grep "\.sh$" <<< $line &>/dev/null
            if [ $? -eq 0 ]; then
                chmod $execmod $line
            else
                chmod $filemod $line
            fi
        elif [ -d "$line" ]; then
            chmod $dirmod $line
        fi
    done < $temp_file
    rm -f $temp_file
}

usage() {
    error_msg=$1
    given_arg=$2

    echo "usage: salomon.sh [-i] [-u]"
    echo
    echo "  -i, --install         install SaLoMon (requires superuser"\
         "privileges)"
    echo "  -u, --uninstall       uninstall SaLoMon (requires superuser"\
         "privileges)"
    echo "  -?, -h, --help        print this help message and exit"
    echo
    echo "Further information and usage examples can be found inside the"\
         "documentation"
    echo "file for this script."
    if [ ! -z "$error_msg" ]; then
        echo
        if [ -z "$given_arg" ]; then
            echo -e "${cl_lr}error:${cl_n} $error_msg."
        else
            echo -e "${cl_lr}error:${cl_n} $error_msg"\
                    "'${cl_yl}${given_arg}${cl_n}'."
        fi
        exit 1
    else
        exit 0
    fi
}

if [ $# -gt 1 ]; then
    usage "Too many arguments"
elif [ $# -lt 1 ]; then
    usage "Missing argument (to install or uninstall)"
fi

if [ "$1" = "--install" ] || [ "$1" = "-i" ]; then
    script_mode="install"
    script_action="${cl_lg}${script_mode}${cl_n}"
elif [ "$1" = "--uninstall" ] || [ "$1" = "-u" ]; then
    script_mode="uninstall"
    script_action="${cl_lr}${script_mode}${cl_n}"
elif [ "$1" = "-?" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
else
    usage "Invalid argument" "$1"
fi

if [ "$(whoami)" != "root" ]; then
    error="${cl_lr}error:${cl_n}"
    echo
    echo -e "$error Superuser privileges are required"
    echo
    exit 1
fi

grep "\/usr\/local\/bin" <<< $PATH &>/dev/null
if [ $? -eq 0 ]; then
    symlink_sh="/usr/local/bin/"
else
    symlink_sh="/usr/bin/"
fi

perform $script_mode
if [ $script_mode = "install" ]; then
    echo -e "Creating target directory '${target}'... \c"
    if [ -d $target_dir ]; then
        echo -e "${cl_lb}(already exists)${cl_n}"
    else
        mkdir -p $target_dir &>/dev/null
        echo
    fi

    echo "Copying project data into target directory..."
    rsync -av $script_dir/* $target_dir/ &>/dev/null

    echo "Setting permissions on target directory..."
    set_permissions

    echo -e "Creating symbolic link for main script... \c"
    if [ -f ${symlink_sh}/salomon ]; then
        echo -e "${cl_lb}(already exists)${cl_n}"
    else
        ln -s ${target_dir}/salomon.sh ${symlink_sh}/salomon &>/dev/null
        echo
    fi
else  # uninstall
    cd $(pwd | sed -e "s/\/salomon$//g")

    echo -e "Removing symbolic link for main script... \c"
    if [ -f ${symlink_sh}/salomon ]; then
        rm -f ${symlink_sh}/salomon &>/dev/null
        echo
    else
        echo -e "${cl_lb}(does not exist)${cl_n}"
    fi

    echo -e "Removing project directory '${target}'... \c"
    if [ -d $target_dir ]; then
        rm -fR $target_dir &>/dev/null
        echo
    else
        echo -e "${cl_lb}(does not exist)${cl_n}"
    fi
fi
echo
echo -e "SaLoMon has been ${script_mode}ed."
if [ $script_mode = "install" ]; then
    echo -e "You can now directly run the '${cl_yl}salomon${cl_n}' command"\
            "in order to use it."
fi
echo

# EOF
