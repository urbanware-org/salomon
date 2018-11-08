#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Shell compatibility script
# Copyright (C) 2018 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
# ============================================================================

# Pre-check if the Bash shell is installed and if this script has been
# executed using it
separator="***************************************"
command -v bash >/dev/null 2>&1
if [ "$?" != "0" ]; then
    echo
    echo "${separator}${separator}"
    echo "* This script has determined that the Bash shell (which is"\
         "required) does    *"
    echo "* not seem to be installed.                                      "\
         "           *"
    echo "*                                                                "\
         "           *"
    echo "* The SaLoMon project was developed on (and for) the Bash shell,"\
         "which is    *"
    echo "* the default shell on many Unix-like systems (or at least on"\
        "many Linux     *"
    echo "* distributions).                                                "\
         "           *"
    echo "*                                                                "\
         "           *"
    echo "* No matter which shell you are using, the Bash shell must be"\
         "installed in   *"
    echo "* order to use SaLoMon. As a matter of fact, the SaLoMon project"\
         "takes       *"
    echo "* advantage of certain features provided by the Bash shell."\
         "                 *"
    echo "${separator}${separator}"
    echo
    exit 1
elif [ ! -n "$BASH" ]; then
    echo
    echo "${separator}${separator}"
    echo "* This script has determined that it has not been executed using"\
         "the Bash    *"
    echo "* shell, but (maybe explicitly) with another one which is not"\
         "supported.     *"
    echo "*                                                                "\
         "           *"
    echo "* The SaLoMon project was developed on (and for) the Bash shell,"\
         "which is    *"
    echo "* the default shell on many Unix-like systems (or at least on"\
        "many Linux     *"
    echo "* distributions).                                                "\
         "           *"
    echo "*                                                                "\
         "           *"
    echo "* No matter which shell you are using, the Bash shell (version 4"\
         "or higher)  *"
    echo "* must be installed in order to use SaLoMon, as the project"\
         "takes advantage  *"
    echo "* of certain features provided by the Bash shell."\
         "                           *"
    echo "${separator}${separator}"
    echo
    exit 1
fi

script_dir=$(dirname $(readlink -f $0))
script_file=$(basename "$0")
script_temp="$(dirname $(mktemp -u))/salomon_compat.sh"

source ${script_dir}/core/common.sh
source ${script_dir}/core/global.sh
set_global_variables

echo
echo $em "${cl_lc}SaLoMon compatibility check script"\
         "${cl_n}"

check_basename="${cl_lr}FAILURE${cl_n}"
check_bash_major="${cl_lr}FAILURE${cl_n}"
check_declare="${cl_lr}FAILURE${cl_n}"
check_dialog="${cl_yl}MISSING${cl_n}"
check_dirname="${cl_lr}FAILURE${cl_n}"
check_grep="${cl_lr}FAILURE${cl_n}"
check_paste="${cl_lr}FAILURE${cl_n}"
check_printf="${cl_lr}FAILURE${cl_n}"
check_readlink="${cl_lr}FAILURE${cl_n}"
check_sed="${cl_lr}FAILURE${cl_n}"
check_tail="${cl_lr}FAILURE${cl_n}"
check_trap="${cl_lr}FAILURE${cl_n}"
check_whiptail="${cl_yl}MISSING${cl_n}"
check_echo="${cl_lg}SUCCESS${cl_n}"
check_function="${cl_lr}FAILURE${cl_n}"
check_failed=0
check_missing=0
check_overall="${cl_lr}FAILURE${cl_n}"
line="................"

bash_major=$(sed -e "s/\..*//g" <<< $BASH_VERSION)
if [ $bash_major -ge 4 ]; then
    check_bash_major="${cl_lg}SUCCESS${cl_n}"
else
    check_failed=1
fi

command -v basename &>/dev/null
if [ $? -eq 0 ]; then
    check_basename="${cl_lg}SUCCESS${cl_n}"
else
    check_failed=1
fi

command -v declare &>/dev/null
if [ $? -eq 0 ]; then
    check_declare="${cl_lg}SUCCESS${cl_n}"
else
    check_failed=1
fi

command -v dialog &>/dev/null
if [ $? -eq 0 ]; then
    check_dialog="${cl_lg}SUCCESS${cl_n}"
else
    check_missing=1
fi

command -v dirname &>/dev/null
if [ $? -eq 0 ]; then
    check_dirname="${cl_lg}SUCCESS${cl_n}"
else
    check_failed=1
fi

command -v grep &>/dev/null
if [ $? -eq 0 ]; then
    check_grep="${cl_lg}SUCCESS${cl_n}"
else
    check_failed=1
fi

command -v paste &>/dev/null
if [ $? -eq 0 ]; then
    check_paste="${cl_lg}SUCCESS${cl_n}"
else
    check_failed=1
fi

command -v printf &>/dev/null
if [ $? -eq 0 ]; then
    check_printf="${cl_lg}SUCCESS${cl_n}"
else
    check_failed=1
fi

command -v readlink &>/dev/null
if [ $? -eq 0 ]; then
    check_readlink="${cl_lg}SUCCESS${cl_n}"
else
    check_failed=1
fi

command -v sed &>/dev/null
if [ $? -eq 0 ]; then
    check_sed="${cl_lg}SUCCESS${cl_n}"
else
    check_failed=1
fi

command -v tail &>/dev/null
if [ $? -eq 0 ]; then
    check_tail="${cl_lg}SUCCESS${cl_n}"
else
    check_failed=1
fi

command -v trap &>/dev/null
if [ $? -eq 0 ]; then
    check_trap="${cl_lg}SUCCESS${cl_n}"
else
    check_failed=1
fi

command -v whiptail &>/dev/null
if [ $? -eq 0 ]; then
    check_whiptail="${cl_lg}SUCCESS${cl_n}"
else
    check_missing=1
fi

echo "#!/bin/bash" > $script_temp
echo "foobar() {" >> $script_temp
echo "    echo \"foobar\"" >> $script_temp
echo "}" >> $script_temp
chmod +x $script_temp
$script_temp &>/dev/null
if [ $? -eq 0 ]; then
    check_function="${cl_lg}SUCCESS${cl_n}"
else
    check_failed=1
fi

if [ $check_failed -eq 0 ]; then
    check_overall="${cl_lg}SUCCESS${cl_n}"
    if [ $check_missing -eq 0 ]; then
        return_code=0
    else
        return_code=3
    fi
else
    check_overall="${cl_lr}FAILURE${cl_n}"
    return_code=2
fi

echo
echo $em "Checking Bash shell (version 4 or higher required)....$line"\
         "${check_bash_major}"
echo
echo $em "Checking 'basename' command ..........................$line"\
         "${check_basename}"
echo $em "Checking 'declare' command ...........................$line"\
         "${check_declare}"
echo $em "Checking 'dirname' command ...........................$line"\
         "${check_dirname}"
echo $em "Checking 'grep' command ..............................$line"\
         "${check_grep}"
echo $em "Checking 'paste' command .............................$line"\
         "${check_printf}"
echo $em "Checking 'printf' command ............................$line"\
         "${check_printf}"
echo $em "Checking 'readlink' command ..........................$line"\
         "${check_readlink}"
echo $em "Checking 'sed' command ...............................$line"\
         "${check_sed}"
echo $em "Checking 'tail' command ..............................$line"\
         "${check_tail}"
echo $em "Checking 'trap' command ..............................$line"\
         "${check_trap}"
echo $em "Checking capabilities of the 'echo' command ..........$line"\
         "${check_echo}"
echo $em "Checking definition of functions .....................$line"\
         "${check_function}"
echo
echo $em "Checking optional 'dialog' command ...................$line"\
         "${check_dialog}"
echo $em "Checking optional 'whiptail' command .................$line"\
         "${check_whiptail}"
echo
echo $em "Overall status .......................................$line"\
         "${check_overall}"
echo

rm -f $script_temp

exit $return_code

# EOF
