#!/usr/bin/env bash

#
# Salomon - Simple log file monitor and analyzer
# Help dialog display script
# Copyright (c) 2021 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

script_dir=$(dirname $(readlink -f $0))
. ${script_dir}/core/shell.sh   # Use POSIX standard instead of 'source' here
shell_precheck

source ${script_dir}/core/compat.sh
compatibility_precheck

script_file=$(basename "$0")
source ${script_dir}/core/common.sh

read_config_file; check_config

dialog_help() {
    doc_file="$1"
    temp_file="/tmp/salomon_help_$$.tmp"

    cp ${script_dir}/docs/usage_${doc_file}.txt ${temp_file}
    dos2unix ${temp_file} &>/dev/null

    if [ "$dialog_program" = "dialog" ]; then
        dialog ${dlg_shadow} --exit-label "Exit" --textbox ${temp_file} 256 90
    else
        whiptail --ok-button "Exit" --textbox ${temp_file} 0 90
    fi

    rm -f ${temp_file}
}

if [ "${dialog_program}" = "auto" ]; then
    command -v dialog &>/dev/null
    if [ $? -eq 0 ]; then
        dialog_program="dialog"
    else
        command -v whiptail &>/dev/null
        if [ $? -eq 0 ]; then
            dialog_program="whiptail"
        else
            dialog_program=""
        fi
    fi
elif [ "${dialog_program}" = "dialog" ]; then
    command -v dialog &>/dev/null
    if [ $? -ne 0 ]; then
        dialog_program=""
    fi
elif [ "${dialog_program}" = "whiptail" ]; then
    command -v whiptail &>/dev/null
    if [ $? -ne 0 ]; then
        dialog_program=""
    fi
else
    dialog_program=""
    usage "The given dialog program is not supported"
fi

if [ -z "${dialog_program}" ]; then
    usage "No supported dialog program found"
fi

dlg_text="Available usage information files:"
if [ "${dialog_program}" = "dialog" ]; then
    user_input=$(dialog ${dlg_shadow} \
                        --ok-button "Select" \
                        --cancel-button "Exit" \
                        --title "Help" \
                        --menu "${dlg_text}" 10 40 3 \
                            "S" "Salomon (main help)" \
                            "I" "Installation" \
                            "C" "Compatibility" \
                        3>&1 1>&2 2>&3 3>&-)
else
    user_input=$(whiptail --ok-button "Select" \
                          --cancel-button "Exit" \
                          --title "Help" \
                          --menu "${dlg_text}" 12 40 3 \
                            "S" "Salomon (main help)" \
                            "I" "Installation" \
                            "C" "Compatibility" \
                        3>&1 1>&2 2>&3 3>&-)
fi

case "${user_input}" in
    [Ss]) dialog_help "salomon" ;;
    [Ii]) dialog_help "install" ;;
    [Cc]) dialog_help "compat" ;;
    *) ;;
esac
clear

# EOF