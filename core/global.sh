#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Global variable core script
# Copyright (C) 2018 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
# ============================================================================

set_global_variables() {
    # ------------------------------------------------------------------------
    # Do not change any values below! See the 'salomon.cfg' file inside the
    # main directory of SaLoMon for configuration options.
    # ------------------------------------------------------------------------

    version="1.12.1"

    arg_case=""
    input_file=""
    input_count=0
    temp_file="$(dirname $(mktemp -u))/salomon_$$.tmp"

    action=""
    copy=0
    export_file=""
    export_log=0
    follow=1
    header=1
    head_lines=0
    highlight_all=0
    highlight_cut_off=0
    highlight_matches=0
    highlight_upper=0
    interactive=0
    pause=0
    pause_lines=0
    prompt=0
    slow=0
    tail_lines=0
    wait_match=0

    color_code=""
    color_dir="$script_dir/colors/"
    color_list="black brown darkblue darkcyan darkgray darkgreen darkpurple"
    color_temp="$color_list darkred lightblue lightcyan lightgray lightgreen"
    color_list="$color_temp lightpurple lightred white yellow"
    color_temp="$color_list $(seq 1 256) random confetti"
    color_list="$color_temp"
    color_random_min=1
    color_random_max=256
    color_table=0
    color_terms=""

    color_none="\e[0m"                ; cl_n=$color_none
    color_black="\e[30m"              ; cl_bk=$color_black
    color_brown="\e[33m"              ; cl_br=$color_brown
    color_darkblue="\e[34m"           ; cl_db=$color_darkblue
    color_darkcyan="\e[36m"           ; cl_dc=$color_darkcyan
    color_darkgray="\e[90m"           ; cl_dy=$color_darkgray
    color_darkgreen="\e[32m"          ; cl_dg=$color_darkgreen
    color_darkpurple="\e[35m"         ; cl_dp=$color_darkpurple
    color_darkred="\e[31m"            ; cl_dr=$color_darkred
    color_lightblue="\e[94m"          ; cl_lb=$color_lightblue
    color_lightcyan="\e[96m"          ; cl_lc=$color_lightcyan
    color_lightgray="\e[37m"          ; cl_ly=$color_lightgray
    color_lightgreen="\e[92m"         ; cl_lg=$color_lightgreen
    color_lightpurple="\e[95m"        ; cl_lp=$color_lightpurple
    color_lightred="\e[91m"           ; cl_lr=$color_lightred
    color_white="\e[97m"              ; cl_wh=$color_white
    color_yellow="\e[93m"             ; cl_yl=$color_yellow

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

    unset color_temp
}

# EOF
