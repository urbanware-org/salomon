#!/bin/bash

# ============================================================================
# Name:         Sane Log Monitor file analyzing core script
# Project:      SaLoMon
# Copyright:    Copyright (C) 2017 by Ralf Kilian
# License:      Distributed under the MIT License
# Website:      http://www.urbanware.org
# GitHub:       https://github.com/urbanware-org/salomon
# ----------------------------------------------------------------------------
# File:         analyze.sh
# Version:      1.7.1
# Date:         2017-01-03
# Description:  Functions to analyze a file with SaLoMon.
# ============================================================================

analyze_input_file() {
    check_patterns

    tail "$input_file" &>/dev/null
    if [ $? != 0 ]; then
        usage "error: No read permission on the given input file."
    fi

    if [ $copy $op 1 ]; then
        timestamp=$(date "+%Y%m%d%H%M%S%N")
        temp_file="/tmp/salomon_${timestamp}.tmp"
        cat "$input_file" > $temp_file
        input_file=$temp_file
    fi

    while read line; do
        print_output_line "$line"

        if [ $slow $op 1 ]; then
            sleep 0.$delay
        fi
    done < $input_file

    if [ $copy $op 1 ]; then
        rm -f $temp_file
    fi

    if [ $header $op 1 ]; then
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

