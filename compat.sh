#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Shell compatibility script
# Copyright (C) 2018 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# Website: http://www.urbanware.org
# GitHub: https://github.com/urbanware-org/salomon
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
    echo "* No matter which shell you are using, the Bash shell must be"\
         "installed in   *"
    echo "* order to use SaLoMon. As a matter of fact, the SaLoMon project"\
         "takes       *"
    echo "* advantage of certain features provided by the Bash shell."\
         "                 *"
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
shell_precheck

echo
echo $em "${color_lightcyan}SaLoMon compatibility check script"\
         "${color_none}"

check_basename="${color_lightred}FAILURE${color_none}"
check_declare="${color_lightred}FAILURE${color_none}"
check_dialog="${color_yellow}MISSING${color_none}"
check_dirname="${color_lightred}FAILURE${color_none}"
check_grep="${color_lightred}FAILURE${color_none}"
check_paste="${color_lightred}FAILURE${color_none}"
check_printf="${color_lightred}FAILURE${color_none}"
check_readlink="${color_lightred}FAILURE${color_none}"
check_sed="${color_lightred}FAILURE${color_none}"
check_tail="${color_lightred}FAILURE${color_none}"
check_trap="${color_lightred}FAILURE${color_none}"
check_whiptail="${color_yellow}MISSING${color_none}"
check_echo="${color_lightgreen}SUCCESS${color_none}"
check_function="${color_lightred}FAILURE${color_none}"
check_failed=0
check_overall="${color_lightred}FAILURE${color_none}"
line="................"

command -v basename &>/dev/null
if [ $? -eq 0 ]; then
    check_basename="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

command -v declare &>/dev/null
if [ $? -eq 0 ]; then
    check_declare="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

command -v dialog &>/dev/null
if [ $? -eq 0 ]; then
    check_dialog="${color_lightgreen}SUCCESS${color_none}"
fi

command -v dirname &>/dev/null
if [ $? -eq 0 ]; then
    check_dirname="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

command -v grep &>/dev/null
if [ $? -eq 0 ]; then
    check_grep="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

command -v paste &>/dev/null
if [ $? -eq 0 ]; then
    check_paste="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

command -v printf &>/dev/null
if [ $? -eq 0 ]; then
    check_printf="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

command -v readlink &>/dev/null
if [ $? -eq 0 ]; then
    check_readlink="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

command -v sed &>/dev/null
if [ $? -eq 0 ]; then
    check_sed="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

command -v tail &>/dev/null
if [ $? -eq 0 ]; then
    check_tail="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

command -v trap &>/dev/null
if [ $? -eq 0 ]; then
    check_trap="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

command -v whiptail &>/dev/null
if [ $? -eq 0 ]; then
    check_whiptail="${color_lightgreen}SUCCESS${color_none}"
fi

echo "#!/bin/bash" > $script_temp
echo "foobar() {" >> $script_temp
echo "    echo \"foobar\"" >> $script_temp
echo "}" >> $script_temp
chmod +x $script_temp
$script_temp &>/dev/null
if [ $? -eq 0 ]; then
    check_function="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

if [ $check_failed -eq 0 ]; then
    check_overall="${color_lightgreen}SUCCESS${color_none}"
else
    check_overall="${color_lightred}FAILURE${color_none}"
fi

echo
echo $em "Checking 'basename' command ..........................$line"\
         "${check_basename}"
echo $em "Checking 'declare' command ...........................$line"\
         "${check_declare}"
echo $em "Checking 'dialog' command (optional) .................$line"\
         "${check_dialog}"
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
echo $em "Checking 'whiptail' command (optional) ...............$line"\
         "${check_whiptail}"
echo $em "Checking capabilities of the 'echo' command ..........$line"\
         "${check_echo}"
echo $em "Checking definition of functions .....................$line"\
         "${check_function}"
echo
echo $em "Overall status .......................................$line"\
         "${check_overall}"
echo

rm -f $script_temp

# EOF

