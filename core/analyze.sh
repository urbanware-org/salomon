#!/usr/bin/env bash

#
# Salomon - Simple log file monitor and analyzer
# File analyzing core script
# Copyright (c) 2024 by Ralf Kilian
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

    if [ $is_bsd -eq 1 ]; then
        temp_file="$(dirname $(mktemp -u))/salomon_$$.tmp"
    else
        temp_file="$(dirname $(mktemp -u --tmpdir))/salomon_$$.tmp"
    fi

    if [ $head_lines -eq 0 ] && [ $tail_lines -eq 0 ]; then
        for input_file in $input_file_list; do
            cat $input_file | grep -v "^$" >> $temp_file
        done
    elif [ $head_lines -gt 0 ]; then
        for input_file in $input_file_list; do
            cat $input_file | head -n $head_lines | grep -v "^$" >> $temp_file
        done
    elif [ $tail_lines -gt 0 ]; then
        for input_file in $input_file_list; do
            cat $input_file | tail -n $tail_lines | grep -v "^$" >> $temp_file
        done
    fi

    if [ -n "$egrep_pattern" ]; then
        grep -Ei $(sed -e "s/^|//g" <<< $egrep_pattern) $temp_file \
             > ${temp_file}.presort
        mv -f ${temp_file}.presort $temp_file
    fi

    if [ $merge -eq 1 ]; then
        merge_file="${temp_file}.merge"
        sort -u < $temp_file > $merge_file
        input_file=$merge_file
    else
        seq_file="${temp_file}.seq"
        uniq < $temp_file > $seq_file
        input_file=$seq_file
    fi

    if [ $analyze_less -eq 1 ]; then
        less_file="${temp_file}.less"
        rm -f $less_file
    fi

    if [ $less_delay -lt 1 ]; then
        less_delay=1
    elif [ $less_delay -gt 900 ]; then
        less_delay=900
    fi
    less_delay=$(printf "%03d\n" $less_delay)

    count=0
    if [ $is_bsd -eq 1 ]; then
        line_count=$(wc -l < $input_file | sed -e "s/\ //g")
    else  # Linux
        line_count=$(wc -l < $input_file)
    fi

    while read line; do
        if [ $analyze_less -eq 1 ]; then
            print_output_line "$line" >> $less_file
            if [ $line_count -gt 0 ]; then
                percent="$(( (count * 100) / line_count ))"
            fi
        else
            print_output_line "$line"
        fi

        count=$(( count + 1 ))
        if [ $analyze_less -eq 1 ] && [ $header -eq 1 ]; then
            echo -e "${cl_lb}$char_header_line_v${cl_n}" \
                    "${cl_lg}Progress:${cl_n}" \
                    "${cl_wh}$(printf "%3s" "$percent") %" \
                    "${cl_ly}(line $count of $line_count)${cl_n}\r\c"

            sleep 0.${less_delay}   # reduce the CPU load, at least a bit
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
    done < "$input_file"
    if [ $analyze_less -eq 1 ] && [ $header -eq 1 ]; then
        echo -e "${cl_lb}$char_header_line_v${cl_n}${cl_lg}" \
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
                exit_prompt=1
                print_line "${cl_ly}Press any key to exit."
                echo -e "\r\c"
                read -n1 -r
            fi
        fi
    fi
    rm -f ${temp_file}*
}
