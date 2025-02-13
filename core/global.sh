#!/usr/bin/env bash

#
# Salomon - Simple log file monitor and analyzer
# Global variable core script
# Copyright (c) 2025 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

# Warning:  Do not change any of the values below! See the 'salomon.cfg' file
#           inside the main directory of Salomon for configuration options.

set_global_variables() {
    version="1.24.0"

    is_bsd=0
    is_openbsd=0
    uname=$(uname | tr '[:upper:]' '[:lower:]')
    if [[ "$uname" == *"bsd"* ]]; then
        is_bsd=1
        if [ "$uname" = "openbsd" ]; then
            is_openbsd=1
        else
            is_openbsd=0
        fi
        temp_file="$(dirname $(mktemp -u))/salomon_$$.tmp"
    else  # Linux
        temp_file="$(dirname $(mktemp -u --tmpdir))/salomon_$$.tmp"
    fi

    user_config="${HOME}/.config/salomon"
    user_colors="${user_config}/colors"
    user_filters="${user_config}/filters"

    git_clone=".git release snippets wiki"

    arg_case=""
    arg_list=$(readlink -f "$0")
    arg_list_compact=$(readlink -f "$0")
    input_file=""
    input_count=0

    action=""
    analyze_less=0
    canceled=0
    copy=0
    exit_prompt=0
    export_file=""
    export_log=0
    follow=1
    format_list=0
    header=1
    head_lines=0
    highlight_all=0
    highlight_cut_off=0
    highlight_matches=0
    highlight_upper=0
    interactive=0
    merge=0
    merge_append=1
    pause=0
    pause_lines=0
    prompt=0
    slow=0
    tail_lines=0
    timestamp=0
    wait_match=0

    colors=("aqua" "black" "blue" "brown" "darkblue" "darkcyan" "darkgray"
            "darkgreen" "darkpurple" "darkred" "fuchsia" "gray" "green"
            "lightblue" "lightcyan" "lightgray" "lightgreen" "lightpurple"
            "lightred"  "lime" "maroon" "navy" "olive" "purple" "red" "silver"
            "teal" "white" "yellow" "$(seq 1 256)" "random" "confetti")
    color_code=""
    color_dir="$script_dir/colors/"
    color_list="${colors[*]}"
    color_random_min=1
    color_random_max=256
    color_table=0
    color_force=""
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

    export NEWT_COLORS="root=,blue"

    unset color_temp
}
