#!/bin/bash

# ============================================================================
# Name:         Sane Log Monitor common core script
# Project:      SaLoMon
# Copyright:    Copyright (C) 2015 by Ralf Kilian
# Website:      http://www.urbanware.org
# ----------------------------------------------------------------------------
# File:         common.sh
# Version:      1.6.2
# Date:         2015-04-30
# Description:  Common core functions for the SaLoMon project.
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

cancel_process() {
    echo
    print_line "*"
    temp="${color_lightred}cancelled ${color_lightgray}on"
    print_line "${temp}${color_lightcyan} user request${color_lightgray}."

    if [ $follow $op 0 ]; then
        print_line
        print_line_count
    fi
    if [ $prompt $op 1 ]; then
        print_line
        print_line "${color_lightgray}Press any key to exit."
        print_line "*"
        read -n1 -r
    else
        print_line "*"
        echo
    fi

    exit 2
}

check_argument() {
    arg_name=$1
    arg_value=$2
    arg_expect=$3

    echo "$arg_value" | grep "^-" &>/dev/null
    if [ $? $op 0 ]; then
        usage "The argument '$arg_name' expects a $arg_expect."
    fi
}

check_command() {
    check_command=$1
    expected_code=$2
    required_pkg=$3

    $check_command --help &>/dev/null
    if [ $? != $expected_code ]; then
        usage "This script requires the '$required_pkg' package to work."
    fi
}

shell_precheck() {
    precheck=$(echo -e "precheck" | grep "\-e")
    if [ $? $op 0 ]; then
        color_none=""
        color_black=""
        color_brown=""
        color_darkblue=""
        color_darkcyan=""
        color_darkgray=""
        color_darkgreen=""
        color_darkpurple=""
        color_darkred=""
        color_lightblue=""
        color_lightcyan=""
        color_lightgray=""
        color_lightgreen=""
        color_lightpurple=""
        color_lightred=""
        color_white=""
        color_yellow=""
        bs=""
        ce=""
        em=""
    fi
}

read_filter() {
    cat "$filter_file" | grep -v "^#" | grep "#" &>/dev/null
    if [ $? $op 0 ]; then
        usage "The filter pattern must not contain any hashes."
    fi

    filter_pattern=""
    cat "$filter_file" | grep -v "#" | sed -e "s/\ /#/g" > $temp_file
    while read line; do
        temp="$filter_pattern;$line"
        filter_pattern="$temp"
    done < $temp_file
    rm -f $temp_file
}

usage() {
    error_msg=$1

    echo "usage: $script_file -a {analyze,monitor} -i INPUT_FILE"\
                           "[-c COLOR_FILE]"
    echo "                  [-d DELAY] [-e EXCLUDE] [-f FILTER] [-h]"\
                           "[--highlight]"
    echo "                  [--ignore-case] [--no-info] [-p] [-r REMOVE]"
    echo "                  [-s] [--version] [-w WAIT]"
    echo
    echo "Monitor or analyze log as well as plain text files and colorize as"\
         "well as"
    echo "highlight lines containing certain terms."
    echo
    echo "required arguments:"
    echo "  -a {analyze,monitor}, --action {analyze,monitor}"
    echo "                        action to perform with the input file"
    echo "  -i INPUT_FILE, --input-file INPUT_FILE"
    echo "                        input file to monitor"
    echo
    echo "optional arguments:"
    echo "  -c COLOR_FILE, --color-file COLOR_FILE"
    echo "                        color config file for colorizing lines"\
                                 "which contain"
    echo "                        certain terms"
    echo "  -d, --delay DELAY     delay for the '--slow' argument below"\
                                 "(milliseconds,"
    echo "                        number between 100 and 900, default is 200)"
    echo "  -e EXCLUDE, --exclude EXCLUDE"
    echo "                        exclude lines which a certain string (for"\
                                 "details see"
    echo "                        section 5 inside the documentation file)"
    echo "  -f FILTER, --filter FILTER"
    echo "                        print the lines that contain the given"\
                                 "filter pattern,"
    echo "                        only (for details see section 4 inside the"
    echo "                        documentation file)"
    echo "  -h, --help            print this help message and exit"
    echo "  --highlight           highlight the filter terms (by inverting"\
                                 "their colors)"
    echo "  --ignore-case         ignore the case of the given filter pattern"
    echo "  --no-info             do not display the information header and"\
                                 "footer"
    echo "  -p, --prompt          prompt before exit (in case the process"\
                                 "gets cancelled"
    echo "                        on user request)"
    echo "  -r REMOVE, --remove REMOVE"
    echo "                        remove a certain string from each line"\
                                 "(for details"
    echo "                        see section 6 inside the documentation"\
                                 "file)"
    echo "  -s, --slow            slow down the process (decreases CPU"\
                                 "usage)"
    echo "  -t, --temp-copy       process temporary copy of the input file"\
                                 "instead of"
    echo "                        the input file itself"
    echo "  --version             print the version number and exit"
    echo "  -w, --wait WAIT       seconds to wait after printing a colorized"\
                                 "line"
    echo
    echo "Further information and usage examples can be found inside the"\
         "documentation"
    echo "file for this script."
    if [ "$error_msg" != "" ]; then
        echo
        echo "error: $error_msg"
        exit 1
    else
        exit 0
    fi
}

# EOF

