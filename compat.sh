#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Shell compatibility script
# Copyright (C) 2019 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
# ============================================================================

script_dir=$(dirname $(readlink -f $0))
. ${script_dir}/core/shell.sh   # Use POSIX standard instead of 'source' here
shell_precheck_compat

script_file=$(basename "$0")
script_temp="$(dirname $(mktemp -u))/salomon_compat.sh"
source ${script_dir}/core/common.sh
source ${script_dir}/core/global.sh
set_global_variables

echo
echo -e "${cl_lc}SaLoMon compatibility check script${cl_n}"

failure="${cl_lr}FAILURE${cl_n}"
missing="${cl_yl}MISSING${cl_n}"
success="${cl_lg}SUCCESS${cl_n}"

check_basename="$failure"
check_bash_major="$failure"
check_declare="$failure"
check_dialog="$missing"
check_dirname="$failure"
check_grep="$failure"
check_kernel="$failure"
check_paste="$failure"
check_printf="$failure"
check_readlink="$failure"
check_sed="$failure"
check_tail="$failure"
check_trap="$failure"
check_wget="$missing"
check_whiptail="$missing"
check_echo="$success"
check_function="$failure"
check_failed=0
check_missing=0
check_overall="$failure"
line="................"

kernel_name=$(uname -a | tr '[:upper:]' '[:lower:]')
if [[ $kernel_name =~ linux ]]; then
    check_kernel="$success"
else
    check_failed=1
fi

bash_major=$(sed -e "s/\..*//g" <<< $BASH_VERSION)
if [ $bash_major -ge 4 ]; then
    check_bash_major="$success"
else
    check_failed=1
fi

command -v basename &>/dev/null
if [ $? -eq 0 ]; then
    check_basename="$success"
else
    check_failed=1
fi

command -v declare &>/dev/null
if [ $? -eq 0 ]; then
    check_declare="$success"
else
    check_failed=1
fi

command -v dialog &>/dev/null
if [ $? -eq 0 ]; then
    check_dialog="$success"
else
    check_missing=1
fi

command -v dirname &>/dev/null
if [ $? -eq 0 ]; then
    check_dirname="$success"
else
    check_failed=1
fi

command -v grep &>/dev/null
if [ $? -eq 0 ]; then
    check_grep="$success"
else
    check_failed=1
fi

command -v paste &>/dev/null
if [ $? -eq 0 ]; then
    check_paste="$success"
else
    check_failed=1
fi

command -v printf &>/dev/null
if [ $? -eq 0 ]; then
    check_printf="$success"
else
    check_failed=1
fi

command -v readlink &>/dev/null
if [ $? -eq 0 ]; then
    check_readlink="$success"
else
    check_failed=1
fi

command -v sed &>/dev/null
if [ $? -eq 0 ]; then
    check_sed="$success"
else
    check_failed=1
fi

command -v tail &>/dev/null
if [ $? -eq 0 ]; then
    check_tail="$success"
else
    check_failed=1
fi

command -v trap &>/dev/null
if [ $? -eq 0 ]; then
    check_trap="$success"
else
    check_failed=1
fi

command -v wget &>/dev/null
if [ $? -eq 0 ]; then
    check_wget="$success"
else
    check_missing=1
fi

command -v whiptail &>/dev/null
if [ $? -eq 0 ]; then
    check_whiptail="$success"
else
    check_missing=1
fi

echo "#!${BASH}" > $script_temp
echo "foobar() {" >> $script_temp
echo "    echo \"foobar\"" >> $script_temp
echo "}" >> $script_temp
chmod +x $script_temp
$script_temp &>/dev/null
if [ $? -eq 0 ]; then
    check_function="$success"
else
    check_failed=1
fi

if [ $check_failed -eq 0 ]; then
    check_overall="$success"
    if [ $check_missing -eq 0 ]; then
        return_code=0
    else
        return_code=3
    fi
else
    check_overall="$failure"
    return_code=2
fi

echo
echo -e "Checking Linux kernel ................................$line"\
        "${check_kernel}"
echo -e "Checking Bash shell (version 4 or higher required) ...$line"\
        "${check_bash_major}"
echo
echo -e "Checking for 'basename' command ......................$line"\
        "${check_basename}"
echo -e "Checking for 'declare' command .......................$line"\
        "${check_declare}"
echo -e "Checking for 'dirname' command .......................$line"\
        "${check_dirname}"
echo -e "Checking for 'grep' command ..........................$line"\
        "${check_grep}"
echo -e "Checking for 'paste' command .........................$line"\
        "${check_printf}"
echo -e "Checking for 'printf' command ........................$line"\
        "${check_printf}"
echo -e "Checking for 'readlink' command ......................$line"\
        "${check_readlink}"
echo -e "Checking for 'sed' command ...........................$line"\
        "${check_sed}"
echo -e "Checking for 'tail' command ..........................$line"\
        "${check_tail}"
echo -e "Checking for 'trap' command ..........................$line"\
        "${check_trap}"
echo -e "Checking for 'wget' command ..........................$line"\
        "${check_wget}"
echo -e "Checking capabilities of the 'echo' command ..........$line"\
        "${check_echo}"
echo -e "Checking definition of functions .....................$line"\
        "${check_function}"
echo
echo -e "Checking optional 'dialog' command ...................$line"\
        "${check_dialog}"
echo -e "Checking optional 'whiptail' command .................$line"\
        "${check_whiptail}"
echo
echo -e "Overall status .......................................$line"\
        "${check_overall}"
echo

rm -f $script_temp

exit $return_code

# EOF
