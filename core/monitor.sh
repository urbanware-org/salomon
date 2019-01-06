#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# File monitoring core script
# Copyright (C) 2019 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
# ============================================================================

monitor_input_file() {
    check_patterns

    spaces=0
    for file in $input_file; do
        temp=$(sed -e "s/^ *//g;s/ *$//g" <<< "$file")

        grep "//" <<< "$temp" &>/dev/null
        if [ $? -eq 0 ]; then
            filepath="$(sed -e "s/\/\//\ /g" <<< "$temp")"
            spaces=1
        else
            filepath="$temp"
            spaces=0
        fi

        tail "$filepath" &>/dev/null
        if [ $? -ne 0 ]; then
            usage "No read permission on the given input file '$filepath'"
        fi

        if [ $spaces -eq 1 ]; then
            temp=$(sed -e "s/\ /\*/g" <<< $filepath)
            input_file_list="$input_file_list $temp"
        else
            input_file_list="$input_file_list $filepath"
        fi

    done

    tail -n $tail_lines -F $input_file_list 2>/dev/null | while read line; do
        print_output_line "$line"
        if [ $slow -eq 1 ]; then
            sleep 0.$delay
        fi
    done
}

# EOF
