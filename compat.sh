#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Shell compatibility script
# Copyright (C) 2017 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# Website: http://www.urbanware.org
# GitHub: https://github.com/urbanware-org/salomon
# ============================================================================

# Check if the Bash shell is installed
seperator="***************************************"
bash --version >/dev/null 2>&1
if [ "$?" != "0" ]; then
    echo
    echo "${seperator}${seperator}"
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
    echo "${seperator}${seperator}"
    echo
    exit 1
fi

script_dir=$(dirname $(readlink -f $0))
script_file=$(basename "$0")
script_temp="/tmp/salomon_compat.sh"

source ${script_dir}/core/common.sh
source ${script_dir}/core/global.sh
set_global_variables
shell_precheck

echo
echo $em "${color_lightcyan}SaLoMon compatibility check script"\
         "${color_none}"

if [ "$em" = "" ]; then
    check_error=" [!]"
    check_echo="${color_lightred}FAILURE${color_none}${check_error}"
    temp="............"
else
    check_error=""
    check_echo="${color_lightgreen}SUCCESS${color_none}"
    temp="................"
fi

check_basename="${color_lightred}FAILURE${color_none}${check_error}"
check_declare="${color_lightred}FAILURE${color_none}${check_error}"
check_dialog="${color_yellow}MISSING${color_none}${check_error}"
check_dirname="${color_lightred}FAILURE${color_none}${check_error}"
check_grep="${color_lightred}FAILURE${color_none}${check_error}"
check_printf="${color_lightred}FAILURE${color_none}${check_error}"
check_readlink="${color_lightred}FAILURE${color_none}${check_error}"
check_sed="${color_lightred}FAILURE${color_none}${check_error}"
check_tail="${color_lightred}FAILURE${color_none}${check_error}"
check_trap="${color_lightred}FAILURE${color_none}${check_error}"
check_function="${color_lightred}FAILURE${color_none}${check_error}"
check_failed=0
check_overall="${color_lightred}FAILURE${color_none}"

touch $script_temp
chmod +x $script_temp

basename $script_temp &>/dev/null
if [ $? -eq 0 ]; then
    check_basename="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

echo "#!/bin/bash" > $script_temp
echo "declare salomon=foobar" >> $script_temp
$script_temp &>/dev/null
if [ $? -eq 0 ]; then
    check_declare="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

dialog --help &>/dev/null
if [ $? -eq 0 ]; then
    check_dialog="${color_lightgreen}SUCCESS${color_none}"
fi

dirname $script_temp &>/dev/null
if [ $? -eq 0 ]; then
    check_dirname="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

grep "sh" <<< $script_temp &>/dev/null
if [ $? -eq 0 ]; then
    check_grep="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

printf ""
if [ $? -eq 0 ]; then
    check_printf="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

readlink -f $script_temp &>/dev/null
if [ $? -eq 0 ]; then
    check_readlink="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

sed -e "s/sh/foo/g" <<< $script_temp &>/dev/null
if [ $? -eq 0 ]; then
    check_sed="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

tail $script_temp &>/dev/null
if [ $? -eq 0 ]; then
    check_tail="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

trap &>/dev/null
if [ $? -eq 0 ]; then
    check_trap="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

echo "#!/bin/bash" > $script_temp
echo "foobar() {" >> $script_temp
echo "    echo \"foobar\"" >> $script_temp
echo "}" >> $script_temp
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
echo $em "Checking 'basename' command ..........................$temp"\
         "${check_basename}"
echo $em "Checking 'declare' command ...........................$temp"\
         "${check_declare}"
echo $em "Checking 'dialog' command ............................$temp"\
         "${check_dialog}"
echo $em "Checking 'dirname' command ...........................$temp"\
         "${check_dirname}"
echo $em "Checking 'grep' command ..............................$temp"\
         "${check_grep}"
echo $em "Checking 'printf' command ............................$temp"\
         "${check_printf}"
echo $em "Checking 'readlink' command ..........................$temp"\
         "${check_readlink}"
echo $em "Checking 'sed' command ...............................$temp"\
         "${check_sed}"
echo $em "Checking 'tail' command ..............................$temp"\
         "${check_tail}"
echo $em "Checking 'trap' command ..............................$temp"\
         "${check_trap}"
echo $em "Checking capabilities of the 'echo' command ..........$temp"\
         "${check_echo}"
echo $em "Checking definition of functions .....................$temp"\
         "${check_function}"
echo
echo $em "Overall status .......................................$temp"\
         "${check_overall}"
echo

rm -f $script_temp

# EOF

