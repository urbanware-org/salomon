#!/bin/bash

# ============================================================================
# Name:         Sane Log Monitor global variable core script
# Project:      SaLoMon
# Copyright:    Copyright (C) 2015 by Ralf Kilian
# Website:      http://www.urbanware.org
# ----------------------------------------------------------------------------
# File:         global.sh
# Version:      1.6.2
# Date:         2015-04-30
# Description:  Variables used by the main SaLoMon script as well as the
#               core components.
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

set_global_variables() {
    arg_case=""
    input_file=""
    temp_file="/tmp/salomon_$$.tmp"

    bs="\b"
    ce="\c"
    em="-e"
    op="=="

    action=""
    copy=0
    delay=200
    follow=1
    header=1
    highlight=0
    prompt=0
    slow=0
    wait_match=0

    color_code=""
    color_dir="$script_dir/colors/"
    color_list="black brown darkblue darkcyan darkgray darkgreen darkpurple"
    color_temp="$color_list darkred lightblue lightcyan lightgray lightgreen"
    color_list="$color_temp lightpurple lightred white yellow"

    color_none="\e[0m"
    color_black="\e[0;30m"
    color_brown="\e[0;33m"
    color_darkblue="\e[0;34m"
    color_darkcyan="\e[0;36m"
    color_darkgray="\e[1;30m"
    color_darkgreen="\e[0;32m"
    color_darkpurple="\e[0;35m"
    color_darkred="\e[0;31m"
    color_lightblue="\e[1;34m"
    color_lightcyan="\e[1;36m"
    color_lightgray="\e[0;37m"
    color_lightgreen="\e[1;32m"
    color_lightpurple="\e[1;35m"
    color_lightred="\e[1;31m"
    color_white="\e[1;37m"
    color_yellow="\e[1;33m"

    count_lines=0
    count_total=0

    exclude=0
    exclude_list=""
    exclude_pattern=""

    filter=0
    filter_dir="$script_dir/filters/"
    filter_file=""
    filter_list=""
    filter_pattern=""

    remove=0
    remove_list=""
    remove_pattern=""
}

# EOF

