#!/bin/bash

# ============================================================================
# Project:      SaLoMon
# File:         Color management core script
# Copyright:    Copyright (C) 2017 by Ralf Kilian
# License:      Distributed under the MIT License
# ----------------------------------------------------------------------------
# Website:      http://www.urbanware.org
# GitHub:       https://github.com/urbanware-org/salomon
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

