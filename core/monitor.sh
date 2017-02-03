#!/bin/bash

# ============================================================================
# Project:      SaLoMon
# File:         File monitoring core script
# Copyright:    Copyright (C) 2017 by Ralf Kilian
# License:      Distributed under the MIT License
# ----------------------------------------------------------------------------
# Website:      http://www.urbanware.org
# GitHub:       https://github.com/urbanware-org/salomon
# ============================================================================

monitor_input_file() {
    check_patterns

    tail "$input_file" &>/dev/null
    if [ $? -ne 0 ]; then
        usage "error: No read permission on the given input file."
    fi 

    tail -F "$input_file" 2>/dev/null | while read line; do
        print_output_line "$line"

        if [ $slow -eq 1 ]; then
            sleep 0.$delay
        fi
    done
}

# EOF

