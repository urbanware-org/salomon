#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Color management core script
# Copyright (C) 2018 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
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
        elif [ "$color_name" = "confetti" ]; then
            color_code="999"
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
        if [ $cpl -gt 19 ] || [ $color -eq 255 ]; then
            echo
            cpl=1
        fi
    done

    echo
    echo "All numbers that have a black background are colors cannot be"\
         "displayed"
    echo "(except for number 0, which actually has a black background)."
    echo
    echo "When running SaLoMon on a text-based user interface, there are"\
         "most likely"
    echo "only 16 colors available which occur multiple times in the table."
    echo
}

read_colors() {
    # Support for 256 colors
    color_temp="$color_list random $(seq 1 256) confetti"
    color_list="$color_temp"

    for color in $(echo "$color_list"); do
        color_line=""
        (grep -v "#" | grep "^$color\ .*" | \
         sed -e "s/^$color//g") < "$color_file" > $temp_file
        while read line; do
            color_temp="$color_line $line"
            color_line="$color_temp"
        done < $temp_file

        if [ -z "$color_line" ]; then
            continue
        fi

        colorize_[$color]=$(tr '[:upper:]' '[:lower:]' <<< "$color_line")
    done

    rm -f $temp_file
}

rnd_colors() {
    # Useless function with the side effect of increasing CPU load
    highlight=$2
    highlight_random=0
    line_input="$1"
    line_output=""

    if [ -z "$highlight" ]; then
        highlight_random=1
    fi

    for char in $(sed -e "s/\(.\)/\1\n/g" <<< "$line_input"); do
        color_confetti=$(shuf -i 1-256 -n 1)
        if [ $highlight_random -eq 1 ]; then
            color_highlight=$(shuf -i 0-1 -n 1)
            if [ $color_highlight -eq 1 ]; then
                color_char="\e[48;5;${color_confetti}m${char}\e[0m"
            else
                color_char="\e[38;5;${color_confetti}m${char}\e[0m"
            fi
        else
            if [ $highlight -eq 1 ]; then
                color_char="\e[48;5;${color_confetti}m${char}\e[0m"
            else
                color_char="\e[38;5;${color_confetti}m${char}\e[0m"
            fi
        fi

        temp="${line_output}${color_char}"
        line_output="$temp"
    done

    echo -e "$line_output"
}

# EOF
