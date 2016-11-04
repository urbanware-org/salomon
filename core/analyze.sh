#!/bin/bash

# ============================================================================
# Name:         Sane Log Monitor file analyzing core script
# Project:      SaLoMon
# Copyright:    Copyright (C) 2015 by Ralf Kilian
# Website:      http://www.urbanware.org
# ----------------------------------------------------------------------------
# File:         analyze.sh
# Version:      1.6.2
# Date:         2015-04-30
# Description:  Functions to analyze a file with SaLoMon.
# ----------------------------------------------------------------------------
# Distributed under the MIT License:
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
# ============================================================================

analyze_input_file() {
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

