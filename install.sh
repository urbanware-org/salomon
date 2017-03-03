#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Install and uninstall script
# Copyright (C) 2017 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
# 
# Website: http://www.urbanware.org
# GitHub: https://github.com/urbanware-org/salomon
# ============================================================================

# Check if the Bash shell is installed
bash --version >/dev/null 2>&1
if [ "$?" != "0" ]; then
    echo "error: The Bash shell does not seem to be installed, run the"\
         "'compat.sh'"
    echo "       script for details."
    exit
fi

script_dir=$(dirname $(readlink -f $0))
script_file=$(basename "$0")

source ${script_dir}/core/common.sh
source ${script_dir}/core/global.sh
set_global_variables
shell_precheck

script_mode=""
symlink_sh="/usr/local/bin/"
target_dir="/opt/salomon"

confirm() {
    echo
    echo $em "${color_lightcyan}SaLoMon install/uninstall script${color_none}"
    echo
    read -p "This will $1 SaLoMon. Do you wish to proceed (Y/N)? " choice
    if [ "$choice" != "Y" ] && [ "$choice" != "y" ]; then
        echo
        echo $em "${color_lightred}Canceled${color_none} on user request."
        echo
        exit 0
    fi
}

error() {
    echo
    if [ -z "$2" ]; then
        echo $em "${color_lightred}error:${color_none} $1"
    else
        echo $em "${color_lightred}error:${color_none} $1"\
                 "'${color_yellow}${2}${color_none}'"
    fi
    echo
    exit 1
}

if [ "$(whoami)" != "root" ]; then
    error "Superuser privileges are required"
fi

if [ $# -gt 1 ]; then
    error "Too many arguments"
fi

if [ "$1" = "--uninstall" ] || [ "$1" = "-u" ]; then
    script_mode="uninstall"
elif [ "$1" = "--install" ] || [ "$1" = "-i" ] || [ -z "$1" ]; then
    script_mode="install"
else
    error "Invalid argument" "$1"
fi

if [ ! -d "$symlink_sh" ]; then
    symlink_sh="/usr/bin/"
fi

confirm $script_mode
echo
echo $em "${color_lightgreen}Started $script_mode process:${color_none}"
if [ "$script_mode" = "uninstall" ]; then
    rm -f "${symlink_sh}/salomon" &>/dev/null
    echo "  - Removed symbolic link for the main script."

    rm -fR "$target_dir" &>/dev/null
    echo $em "  - Removed project directory"\
             "'${color_yellow}${target_dir}${color_none}'."
else
    mkdir -p "$target_dir" &>/dev/null
    echo $em "  - Created target directory"\
             "'${color_yellow}${target_dir}${color_none}'."

    rsync -av "$script_dir"/* "$target_dir/" &>/dev/null
    echo "  - Copied project data to target directory."

    chown root:root "$target_dir" -R &>/dev/null
    echo "  - Set permissions on target directory."

    ln -s "${target_dir}/salomon.sh" "${symlink_sh}/salomon" &>/dev/null
    echo "  - Created symbolic link for the main script."
fi
echo $em "${color_lightgreen}Finished $script_mode process.${color_none}"
echo

# EOF

