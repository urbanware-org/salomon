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
    else
        # Support for 256 colors (color code instead of name)
        if [ "$color_name" = "random" ]; then
            temp=$(shuf -i ${color_random_min}-${color_random_max} -n 1)
            color_code="\e[38;5;${temp}m"
        else
            color_code="\e[38;5;${color_name}m"
        fi
    fi
}

print_color_table() {
    echo
    echo "This terminal emulator supports (can display) the following colors:"
    echo
    
    cpl=1
    for color in $(seq 0 255); do
        printf "\x1b[48;5;%sm%4d\e[0m" "$color" "$color";
        cpl=$(( ++cpl ))
        if [ $cpl -gt 16 ]; then
            echo
            cpl=1
        fi 
    done

    echo
    echo "All numbers that have a black background are colors cannot be"\
         "displayed"
    echo "(except for number 0, which actually has a black background)."
    echo
}

read_colors() {
    # Support for 256 colors
    color_temp="$color_list random $(seq 1 256)"
    color_list="$color_temp"

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

