#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# File analyzing core script
# Copyright (C) 2020 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
# ============================================================================

analyze_input_file() {
    check_patterns

    spaces=0
    for file in $input_file; do
        temp=$(sed -e "s/^ *//g;s/ *$//g" <<< "$file")

        grep "//" <<< "$temp" &>/dev/null
        if [ $? -eq 0 ]; then
            filepath="$(sed -e "s/\/\//\ /g" <<< "$temp")"
            spaces=1
        else
            filepath="$temp"
            spaces=0
        fi

        if [ $spaces -eq 1 ]; then
            temp=$(sed -e "s/\ /\*/g" <<< $filepath)
            input_file_list="$input_file_list $temp"
        else
            input_file_list="$input_file_list $filepath"
        fi
    done

    temp_file="$(dirname $(mktemp -u))/salomon_$$.tmp"

    if [ $head_lines -eq 0 ] && [ $tail_lines -eq 0 ]; then
        paste -d "\n" $input_file_list | grep -v "^$" > $temp_file
    elif [ $head_lines -gt 0 ]; then
        paste -d "\n" $input_file_list | head -n $head_lines | grep -v "^$" \
              > $temp_file
    elif [ $tail_lines -gt 0 ]; then
        paste -d "\n" $input_file_list | tail -n $tail_lines | grep -v "^$" \
              > $temp_file
    fi

    if [ $merge -eq 1 ]; then
        merge_file="${temp_file}.merge"
        sort < $temp_file > $merge_file
        input_file=$merge_file
    else
        input_file=$temp_file
    fi

    count=0
    while read line; do
        print_output_line "$line"
        if [ ! -z "$output" ]; then
            count=$(( count + 1 ))
        fi

        if [ $pause -gt 0 ]; then
            if [ "$pause_lines" = "auto" ]; then
                term_lines=$(tput lines)
                if [ $(( count % $(( term_lines - 1 )) )) -eq 0 ]; then
                    pause_output
                    count=0
                fi
            else
                if [ $(( count % pause_lines )) -eq 0 ]; then
                    pause_output
                    count=0
                fi
            fi
        fi

        if [ $slow -eq 1 ]; then
            sleep 0.$delay
        fi
    done < $input_file
    rm -f ${temp_file}*

    if [ $header -eq 1 ]; then
        echo
        temp="Reached the end of the given input file."
        print_line "*" 1
        print_line "${cl_lc}${temp}"
        print_line
        print_line_count
        if [ $prompt -eq 1 ]; then
            print_line
            print_line "${cl_ly}Press any key to exit."
            print_line "*"
            read -n1 -r
        else
            print_line "*"
            echo
        fi
    else
        if [ $prompt -eq 1 ]; then
            print_line "${cl_ly}Press any key to exit"
            echo -e "\r\c"
            read -n1 -r
        fi
    fi
}

# EOF
