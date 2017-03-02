#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Color management core script
# Copyright (C) 2017 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
# 
# Website: http://www.urbanware.org
# GitHub: https://github.com/urbanware-org/salomon
# ============================================================================

get_color_code() {
    color_name=$1

    if [ "$color_name" = "black" ]; then
        color_code="$color_black"
    elif [ "$color_name" = "brown" ]; then
        color_code="$color_brown"
    elif [ "$color_name" = "darkblue" ]; then
        color_code="$color_darkblue"
    elif [ "$color_name" = "darkcyan" ]; then
        color_code="$color_darkcyan"
    elif [ "$color_name" = "darkgray" ]; then
        color_code="$color_darkgray"
    elif [ "$color_name" = "darkgreen" ]; then
        color_code="$color_darkgreen"
    elif [ "$color_name" = "darkpurple" ]; then
        color_code="$color_darkpurple"
    elif [ "$color_name" = "darkred" ]; then
        color_code="$color_darkred"
    elif [ "$color_name" = "lightblue" ]; then
        color_code="$color_lightblue"
    elif [ "$color_name" = "lightcyan" ]; then
        color_code="$color_lightcyan"
    elif [ "$color_name" = "lightgray" ]; then
        color_code="$color_lightgray"
    elif [ "$color_name" = "lightgreen" ]; then
        color_code="$color_lightgreen"
    elif [ "$color_name" = "lightpurple" ]; then
        color_code="$color_lightpurple"
    elif [ "$color_name" = "lightred" ]; then
        color_code="$color_lightred"
    elif [ "$color_name" = "white" ]; then
        color_code="$color_white"
    elif [ "$color_name" = "yellow" ]; then
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

        if [ "$color_line" = "" ]; then
            continue
        fi

        colorize_[$color]=$(tr '[:upper:]' '[:lower:]' <<< "$color_line")
    done
    rm -f $temp_file
}

# EOF

