#!/bin/bash

# ============================================================================
# Name:         Sane Log Monitor global variable core script
# Project:      SaLoMon
# Copyright:    Copyright (C) 2017 by Ralf Kilian
# License:      Distributed under the MIT License
# Website:      http://www.urbanware.org
# GitHub:       https://github.com/urbanware-org/salomon
# ----------------------------------------------------------------------------
# File:         global.sh
# Version:      1.7.1
# Date:         2017-01-03
# Description:  Variables used by the main SaLoMon script as well as the
#               core components.
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
    highlight_upper=0
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

