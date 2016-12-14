#!/bin/bash

# ============================================================================
# Name:         Sane Log Monitor color management core script
# Project:      SaLoMon
# Copyright:    Copyright (C) 2016 by Ralf Kilian
# Website:      http://www.urbanware.org
# ----------------------------------------------------------------------------
# File:         colors.sh
# Version:      1.7.0
# Date:         2016-12-14
# Description:  Functions to read the color config files and to return the
#               appropriate color code.
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

get_color_code() {
    color_name=$1

    if [ "$color_name" $op "black" ]; then
        color_code="$color_black"
    elif [ "$color_name" $op "brown" ]; then
        color_code="$color_brown"
    elif [ "$color_name" $op "darkblue" ]; then
        color_code="$color_darkblue"
    elif [ "$color_name" $op "darkcyan" ]; then
        color_code="$color_darkcyan"
    elif [ "$color_name" $op "darkgray" ]; then
        color_code="$color_darkgray"
    elif [ "$color_name" $op "darkgreen" ]; then
        color_code="$color_darkgreen"
    elif [ "$color_name" $op "darkpurple" ]; then
        color_code="$color_darkpurple"
    elif [ "$color_name" $op "darkred" ]; then
        color_code="$color_darkred"
    elif [ "$color_name" $op "lightblue" ]; then
        color_code="$color_lightblue"
    elif [ "$color_name" $op "lightcyan" ]; then
        color_code="$color_lightcyan"
    elif [ "$color_name" $op "lightgray" ]; then
        color_code="$color_lightgray"
    elif [ "$color_name" $op "lightgreen" ]; then
        color_code="$color_lightgreen"
    elif [ "$color_name" $op "lightpurple" ]; then
        color_code="$color_lightpurple"
    elif [ "$color_name" $op "lightred" ]; then
        color_code="$color_lightred"
    elif [ "$color_name" $op "white" ]; then
        color_code="$color_white"
    elif [ "$color_name" $op "yellow" ]; then
        color_code="$color_yellow"
    fi
}

read_colors() {
    for color in $(echo "$color_list"); do
        color_line=""
        (grep -v "#" | grep "^$color\ .*" | \
         sed -e "s/^$color//g") < "$color_file" > $temp_file
        while read line; do
            color_temp="$color_line $line"
            color_line="$color_temp"
        done < $temp_file

        if [ "$color_line" $op "" ]; then
            continue
        fi

        colorize_[$color]=$(tr '[:upper:]' '[:lower:]' <<< "$color_line")
    done
    rm -f $temp_file
}

# EOF

