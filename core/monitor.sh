#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# File monitoring core script
# Copyright (C) 2017 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# Website: http://www.urbanware.org
# GitHub: https://github.com/urbanware-org/salomon
# ============================================================================

monitor_input_file() {
    check_patterns

    tail "$input_file" &>/dev/null
    if [ $? -ne 0 ]; then
        usage "error: No read permission on the given input file"
    fi

    tail -n $start_line -F "$input_file" 2>/dev/null | while read line; do
        print_output_line "$line"

        if [ $slow -eq 1 ]; then
            sleep 0.$delay
        fi
    done
}

# EOF

