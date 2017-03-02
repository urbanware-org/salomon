#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# File analyzing core script
# Copyright (C) 2017 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
# 
# Website: http://www.urbanware.org
# GitHub: https://github.com/urbanware-org/salomon
# ============================================================================

analyze_input_file() {
    check_patterns

    tail "$input_file" &>/dev/null
    if [ $? -ne 0 ]; then
        usage "error: No read permission on the given input file."
    fi

    if [ $copy -eq 1 ]; then
        timestamp=$(date "+%Y%m%d%H%M%S%N")
        temp_file="/tmp/salomon_${timestamp}.tmp"
        cat "$input_file" > $temp_file
        input_file=$temp_file
    fi

    while read line; do
        print_output_line "$line"

        if [ $slow -eq 1 ]; then
            sleep 0.$delay
        fi
    done < $input_file

    if [ $copy -eq 1 ]; then
        rm -f $temp_file
    fi

    if [ $header -eq 1 ]; then
        echo
        temp="Reached the end of the given input file."
        print_line "*"
        print_line "${color_lightcyan}${temp}"
        print_line
        print_line_count
        print_line "*"
        echo
    fi
}

# EOF

