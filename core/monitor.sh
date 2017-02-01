#!/bin/bash

# ============================================================================
# Name:         Sane Log Monitor file monitoring core script
# Project:      SaLoMon
# Copyright:    Copyright (C) 2017 by Ralf Kilian
# License:      Distributed under the MIT License
# Website:      http://www.urbanware.org
# GitHub:       https://github.com/urbanware-org/salomon
# ----------------------------------------------------------------------------
# File:         monitor.sh
# Version:      1.7.1
# Date:         2017-01-03
# Description:  Functions to monitor a file with SaLoMon.
# ============================================================================

monitor_input_file() {
    check_patterns

    tail "$input_file" &>/dev/null
    if [ $? != 0 ]; then
        usage "error: No read permission on the given input file."
    fi 

    tail -F "$input_file" 2>/dev/null | while read line; do
        print_output_line "$line"

        if [ $slow $op 1 ]; then
            sleep 0.$delay
        fi
    done
}

# EOF

