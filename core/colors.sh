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
    elif [ ! -z $(grep "^black" <<< "$color_name") ]; then
        color_code="$cl_bk"
    elif [ ! -z $(grep "^brown" <<< "$color_name") ]; then
        color_code="$cl_br"
    elif [ ! -z $(grep "^darkblue" <<< "$color_name") ]; then
        color_code="$cl_db"
    elif [ ! -z $(grep "^darkcyan" <<< "$color_name") ]; then
        color_code="$cl_dc"
    elif [ ! -z $(grep "^darkgray" <<< "$color_name") ]; then
        color_code="$cl_dy"
    elif [ ! -z $(grep "^darkgreen" <<< "$color_name") ]; then
        color_code="$cl_dg"
    elif [ ! -z $(grep "^darkpurple" <<< "$color_name") ]; then
        color_code="$cl_dp"
    elif [ ! -z $(grep "^darkred" <<< "$color_name") ]; then
        color_code="$cl_dr"
    elif [ ! -z $(grep "^lightblue" <<< "$color_name") ]; then
        color_code="$cl_lb"
    elif [ ! -z $(grep "^lightcyan" <<< "$color_name") ]; then
        color_code="$cl_lc"
    elif [ ! -z $(grep "^lightgray" <<< "$color_name") ]; then
        color_code="$cl_ly"
    elif [ ! -z $(grep "^lightgreen" <<< "$color_name") ]; then
        color_code="$cl_lg"
    elif [ ! -z $(grep "^lightpurple" <<< "$color_name") ]; then
        color_code="$cl_lp"
    elif [ ! -z $(grep "^lightred" <<< "$color_name") ]; then
        color_code="$cl_lr"
    elif [ ! -z $(grep "^white" <<< "$color_name") ]; then
        color_code="$cl_wh"
    elif [ ! -z $(grep "^yellow" <<< "$color_name") ]; then
        color_code="$cl_yl"
    else
        # Support for 256 colors (color code instead of name)
        if [ "$color_name" = "random" ]; then
            temp=$(shuf -i ${color_random_min}-${color_random_max} -n 1)
            color_code="\e[38;5;${temp}m"
        elif [ "$color_name" = "confetti" ]; then
            color_code="999"
        else
            re='^[0-9]+$'
            if [[ $color_name =~ $re ]]; then
                if [ $color_name -lt 0 ] || [ $color_name -gt 256 ]; then
                    warn "The color '${cl_yl}$color_name${cl_n}' is invalid" 1
                    color_name=""
                    color_code="${cl_n}"
                else
                    color_code="\e[38;5;${color_name}m"
                fi
            else
                warn "The color '${cl_yl}$color_name${cl_n}' does not exist" 1
                color_name=""
                color_code="${cl_n}"
            fi
        fi
    fi

    if [ ! -z $(grep "\-bold$" <<< "$color_name") ]; then
        temp=$(sed -e "s/\[/\[1;/g" <<< $color_code)
        color_code="$temp"
    elif [ ! -z $(grep "\-underlined$" <<< "$color_name") ]; then
        temp=$(sed -e "s/\[/\[4;/g" <<< $color_code)
        color_code="$temp"
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
    echo -e "    \c"
    for color in $(seq 0 255); do
        printf "\x1b[48;5;%sm%4d${cl_n}" "$color" "$color";
        cpl=$(( ++cpl ))
        if [ $cpl -gt 16 ] || [ $color -eq 255 ]; then
            cpl=1
            echo -e "\n    \c"
        fi
    done

    echo
    echo "All numbers with black background are colors that cannot be"\
         "displayed (except"
    echo "for number 0). When running SaLoMon on a text-based user interface"\
         "there are"
    echo "most likely only 16 colors available which occur multiple times in"\
         "the table."
    echo
}

read_color_file() {
    while read line; do
        if [ -z "$line" ] || [[ $line == *"#"* ]]; then
            continue
        fi
        color_line_code=$(awk '{ print $1 }' <<< "$line")
        color_line_term=$(awk '{ print $2 }' <<< "$line")
        color_temp="$color_terms $color_line_term"
        xargs -n1 <<< "$color_temp" &>/dev/null
        if [ $? -ne 0 ]; then
            warn "Please check the color config for quotes and remove them." 0
            color_terms="$color_temp"
        else
            color_terms=$(xargs -n1 <<< "$color_temp" | sort -u | xargs)
        fi

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
