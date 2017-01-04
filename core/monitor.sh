#!/bin/bash

# ============================================================================
# Name:         Sane Log Monitor file monitoring core script
# Project:      SaLoMon
# Copyright:    Copyright (C) 2017 by Ralf Kilian
# Website:      http://www.urbanware.org
# GitHub:       https://github.com/urbanware-org/salomon
# ----------------------------------------------------------------------------
# File:         monitor.sh
# Version:      1.7.1
# Date:         2017-01-03
# Description:  Functions to monitor a file with SaLoMon.
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

