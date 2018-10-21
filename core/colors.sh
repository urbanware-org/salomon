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
declare -A colorize

get_color_code() {
    color_name=$1

    if [ "$color_name" = "none" ] || [ -z "$color_name" ]; then
        color_code="$cl_n"
    elif [ "$color_name" = "black" ]; then
        color_code="$cl_bk"
    elif [ "$color_name" = "brown" ]; then
        color_code="$cl_br"
    elif [ "$color_name" = "darkblue" ]; then
        color_code="$cl_db"
    elif [ "$color_name" = "darkcyan" ]; then
        color_code="$cl_dc"
    elif [ "$color_name" = "darkgray" ]; then
        color_code="$cl_dy"
    elif [ "$color_name" = "darkgreen" ]; then
        color_code="$cl_dg"
    elif [ "$color_name" = "darkpurple" ]; then
        color_code="$cl_dp"
    elif [ "$color_name" = "darkred" ]; then
        color_code="$cl_dr"
    elif [ "$color_name" = "lightblue" ]; then
        color_code="$cl_lb"
    elif [ "$color_name" = "lightcyan" ]; then
        color_code="$cl_lc"
    elif [ "$color_name" = "lightgray" ]; then
        color_code="$cl_ly"
    elif [ "$color_name" = "lightgreen" ]; then
        color_code="$cl_lg"
    elif [ "$color_name" = "lightpurple" ]; then
        color_code="$cl_lp"
    elif [ "$color_name" = "lightred" ]; then
        color_code="$cl_lr"
    elif [ "$color_name" = "white" ]; then
        color_code="$cl_wh"
    elif [ "$color_name" = "yellow" ]; then
        color_code="$cl_yl"
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

get_color_match() {
    color_match=0
    line_input="$1"
    shopt -s nocasematch

    for term in $color_terms; do
        if [[ $line == *"$term"* ]]; then
            color_match=1
            break
        fi
    done

    if [ $color_match -eq 1 ]; then
        get_color_code ${colorize[$term]}
    else
        get_color_code none
    fi
    shopt -u nocasematch
}

print_color_table() {
    echo
    echo "This terminal emulator supports (can display) the following colors:"
    echo

    cpl=1
    for color in $(seq 0 255); do
        printf "\x1b[48;5;%sm%4d${cl_n}" "$color" "$color";
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

read_color_file() {
#  | xargs -n1 | sort -u | xargs
    while read line; do
        if [ -z "$line" ] || [[ $line == *"#"* ]]; then
            continue
        fi
        color_line_code=$(awk '{ print $1 }' <<< "$line")
        color_line_term=$(awk '{ print $2 }' <<< "$line")
        color_temp="$color_terms $color_line_term"
        color_terms=$(xargs -n1 <<< "$color_temp" | sort -u | xargs)
        colorize+=( ["$color_line_term"]="$color_line_code" )
    done < $color_file
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
                color_char="\e[48;5;${color_confetti}m${char}${cl_n}"
            else
                color_char="\e[38;5;${color_confetti}m${char}${cl_n}"
            fi
        else
            if [ $highlight -eq 1 ]; then
                color_char="\e[48;5;${color_confetti}m${char}${cl_n}"
            else
                color_char="\e[38;5;${color_confetti}m${char}${cl_n}"
            fi
        fi

        temp="${line_output}${color_char}"
        line_output="$temp"
    done

    echo -e "$line_output"
}

# EOF
