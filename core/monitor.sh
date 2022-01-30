#!/usr/bin/env bash

#
# Salomon - Simple log file monitor and analyzer
# File monitoring core script
# Copyright (C) 2021 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

monitor_input_file() {
    check_patterns

    spaces=0
    for file in $input_file; do
        file=$(sed -e "s/^ *//g;s/ *$//g" <<< "$file")

        grep "//" <<< "$file" &>/dev/null
        if [ $? -eq 0 ]; then
            filepath="$(sed -e "s/\/\//\ /g" <<< "$file")"
            spaces=1
        else
            filepath="$file"
            spaces=0
        fi

        if [ $spaces -eq 1 ]; then
            filepath=$(sed -e "s/\ /\*/g" <<< $filepath)
            input_file_list="$input_file_list $filepath"
        else
            input_file_list="$input_file_list $filepath"
        fi
    done

    if [ $is_openbsd -eq 1 ]; then
        param_files="-f"
    else
        param_files="-F"
    fi

    tail -n $tail_lines $param_files $input_file_list 2>/dev/null | \
    while read line; do
        print_output_line "$line"
        if [ $slow -eq 1 ]; then
            sleep 0.$delay
        fi
    done
}

# EOF
