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

    for i in $input_file; do
        tail "$i" &>/dev/null
        if [ $? -ne 0 ]; then
            usage "No read permission on the given input file '$i'"
        fi
    done  

    #if [ $copy -eq 1 ]; then
        timestamp=$(date "+%Y%m%d%H%M%S%N")
        temp_file="/tmp/salomon_${timestamp}.tmp"
        paste -d "\n" $input_file | grep -v "^$" > $temp_file 
        input_file=$temp_file
    #fi

    count=0
    while read line; do
        if [ $start_line -gt 1 ]; then
            if [ $count -lt $start_line ]; then
                count=$(( count + 1 ))
                continue
            fi
        fi

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
    
    rm -f "$temp_file"
}

# EOF

