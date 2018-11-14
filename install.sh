#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Install and uninstall script
# Copyright (C) 2018 by Ralf Kilian
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
target_dir="/opt/salomon"
target="${cl_yl}${target_dir}${cl_n}"
yesno="${cl_yl}Y${cl_n}/${cl_yl}N${cl_n}"

confirm() {
    echo
    echo -e "${cl_lc}SaLoMon install/uninstall script${cl_n}"
    echo
    echo -e "This will $script_action SaLoMon. Do you wish to proceed"\
             "($yesno)? \c"
    read choice

    egrep "^yes$|^y$" -i <<< $choice &>/dev/null
    if [ $? -ne 0 ]; then
        echo
        echo -e "${cl_lr}Canceled${cl_n} on user request."
        echo
        exit
    fi
}

usage() {
    error_msg=$1
    given_arg=$2

    echo "usage: salomon.sh [-i] [-u]"
    echo
    echo "  -i, --install         install SaLoMon"
    echo "  -u, --uninstall       uninstall SaLoMon"
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
    usage "Missing arguments"
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

confirm $script_mode
echo
echo -e "${cl_lg}Started $script_mode process:${cl_n}"
if [ $script_mode = "uninstall" ]; then
    cd $(pwd | sed -e "s/\/salomon$//g")

    if [ -f ${symlink_sh}/salomon ]; then
        rm -f ${symlink_sh}/salomon &>/dev/null
        echo "  - Removed symbolic link for the main script."
    else
        echo "  - Symbolic link for the main script does not exist."
    fi

    if [ -d $target_dir ]; then
        rm -fR $target_dir &>/dev/null
        echo -e "  - Removed project directory '${target}'."
    else
        echo -e "  - Project directory '${target}' does not exist."
    fi
else
    if [ -d $target_dir ]; then
        echo -e "  - Target directory '${target}' already exists."
    else
        mkdir -p $target_dir &>/dev/null
        echo -e "  - Created target directory '${target}'."
    fi

    rsync -av $script_dir/* $target_dir/ &>/dev/null
    echo "  - Copied project data to target directory."

    chown root:root $target_dir -R &>/dev/null
    echo "  - Set permissions on target directory."

    chmod +x $target_dir/*.sh
    echo "  - Set executable flag for main script files."

    if [ -f ${symlink_sh}/salomon ]; then
        echo "  - Symbolic link for the main script already exists."
    else
        ln -s ${target_dir}/salomon.sh ${symlink_sh}/salomon &>/dev/null
        echo "  - Created symbolic link for the main script."
    fi
fi
echo -e "${cl_lg}Finished $script_mode process.${cl_n}"
echo

# EOF
