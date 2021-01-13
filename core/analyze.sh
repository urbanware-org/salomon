#!/usr/bin/env bash

#
# Salomon - Simple log file monitor and analyzer
# File analyzing core script
# Copyright (C) 2021 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

analyze_input_file() {
    check_patterns

    spaces=0
    for file in $input_file; do
        file=$(sed -e "s/^ *//g;s/ *$//g" <<< "$file")

        grep "//" <<< "$file" &>/dev/null
        if [ $? -eq 0 ]; then
            filepath="$(sed -e "s/\/\//\ /g" <<< "$file")"
            spaces=1
        else
            filepath="$file"
            spaces=0
        fi

        if [ $spaces -eq 1 ]; then
            filepath=$(sed -e "s/\ /\*/g" <<< $filepath)
            input_file_list="$input_file_list $filepath"
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

    if [ ! -z "$egrep_pattern" ]; then
        egrep -i $(sed -e "s/^|//g" <<< $egrep_pattern) $temp_file \
              > ${temp_file}.presort
        mv -f ${temp_file}.presort $temp_file
    fi

    if [ $merge -eq 1 ]; then
        merge_file="${temp_file}.merge"
        sort < $temp_file > $merge_file
        input_file=$merge_file
    else
        input_file=$temp_file
    fi

    if [ $analyze_less -eq 1 ]; then
        less_file="${temp_file}.less"
        rm -f $less_file
    fi

    count=0
    line_count=$(wc -l < $input_file)
    while read line; do
        if [ $analyze_less -eq 1 ]; then
            print_output_line "$line" >> $less_file
            if [ $line_count -gt 0 ]; then
                percent="$(( (count * 100) / line_count ))"
            fi
        else
            print_output_line "$line"
        fi

        if [ ! -z "$output" ]; then
            count=$(( count + 1 ))
            if [ $analyze_less -eq 1 ] && [ $header -eq 1 ]; then
                echo -e "${cl_lb}$ld_char${cl_n} ${cl_lg}Progress:${cl_n}" \
                        "${cl_wh}$(printf "%3s" "$percent") %" \
                        "${cl_ly}(line $count of $line_count)${cl_n}\r\c"
            fi
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
    if [ $analyze_less -eq 1 ] && [ $header -eq 1 ]; then
        echo -e "${cl_lb}$ld_char${cl_n}${cl_lg}" \
          "${cl_lg}Done.                                           ${cl_n}"
        echo
    fi

    if [ $analyze_less -eq 1 ]; then
        if [ -f $less_file ]; then
            less -r < $less_file
        fi
    else
        if [ $header -eq 1 ]; then
            echo
            print_line "*" 1
            print_line "${cl_lc}Reached the end of the given input file."
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
    fi
    rm -f ${temp_file}*
}

# EOF
