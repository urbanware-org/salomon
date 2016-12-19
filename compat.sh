#!/bin/bash

# ============================================================================
# Name:         Sane Log Monitor shell compatibility script
# Project:      SaLoMon
# Copyright:    Copyright (C) 2016 by Ralf Kilian
# Website:      http://www.urbanware.org
# GitHub:       https://github.com/urbanware-org/salomon
# ----------------------------------------------------------------------------
# File:         compat.sh
# Version:      1.7.0
# Date:         2016-12-14
# Description:  A script that checks if SaLoMon will run in the current
#               environment.
# ----------------------------------------------------------------------------
# Distributed under the MIT License:
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
# ============================================================================

script_version="1.7.0"

# Pre-check if the Bash shell is installed
seperator="***************************************"
bash --version >/dev/null 2>&1
if [ $? != 0 ]; then
    echo
    echo "${seperator}${seperator}"
    echo "* A pre-check already has determined that the Bash shell (which is"\
         "required) *"
    echo "* does not seem to be installed.                                 "\
         "           *"
    echo "*                                                                "\
         "           *"
    echo "* No matter which shell you are using, the Bash shell must be"\
         "installed in   *"
    echo "* order to run SaLoMon.                                          "\
         "           *"
    echo "*                                                                "\
         "           *"
    echo "* Without the Bash shell, the scripts can also be executed, but"\
         "will either  *"
    echo "* not work properly or not work at all.                          "\
         "           *"
    echo "${seperator}${seperator}"
    echo
    exit
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

if [ "$em" $op "" ]; then
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
if [ $? $op 0 ]; then
    check_basename="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

echo "#!/bin/bash" > $script_temp
echo "declare salomon=foobar" >> $script_temp
$script_temp &>/dev/null
if [ $? $op 0 ]; then
    check_declare="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

dirname $script_temp &>/dev/null
if [ $? $op 0 ]; then
    check_dirname="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

grep "sh" <<< $script_temp &>/dev/null
if [ $? $op 0 ]; then
    check_grep="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

printf ""
if [ $? $op 0 ]; then
    check_printf="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

readlink -f $script_temp &>/dev/null
if [ $? $op 0 ]; then
    check_readlink="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

sed -e "s/sh/foo/g" <<< $script_temp &>/dev/null
if [ $? $op 0 ]; then
    check_sed="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

tail $script_temp &>/dev/null
if [ $? $op 0 ]; then
    check_tail="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

trap &>/dev/null
if [ $? $op 0 ]; then
    check_trap="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

echo "#!/bin/bash" > $script_temp
echo "foobar() {" >> $script_temp
echo "    echo \"foobar\"" >> $script_temp
echo "}" >> $script_temp
$script_temp &>/dev/null
if [ $? $op 0 ]; then
    check_function="${color_lightgreen}SUCCESS${color_none}"
else
    check_failed=1
fi

if [ $check_failed $op 0 ]; then
    check_overall="${color_lightgreen}SUCCESS${color_none}"
else
    check_overall="${color_lightred}FAILURE${color_none}"
fi

echo
echo $em "Checking 'basename' command ..........................$temp"\
         "${check_basename}"
echo $em "Checking 'declare' command ...........................$temp"\
         "${check_declare}"
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

