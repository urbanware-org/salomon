#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Output core script
# Copyright (C) 2019 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
# ============================================================================

pause_output() {
    anykey="${cl_lr}Press ${cl_yl}any key${cl_n} to ${cl_lg}continue${cl_n}"
    message="${cl_dy}==${cl_ly}[$anykey${cl_ly}]${cl_dy}"
    echo -e "${message}=================================================\r\c"
    read -n1 -r < /dev/tty
    echo
}

print_line() {
    indent=30

    if [ -z "$1" ]; then
        echo -e "${cl_lb}*${cl_n}"
    elif [ "$1" = "*" ]; then
        echo -e "${cl_lb}\c"
        for number in $(seq 1 78); do
            echo -e "*\c"
        done
        echo -e "${cl_n}"
    else
        temp=$(printf "%-${indent}s" "$1")
        echo -e "${cl_lb}* ${temp}${2}${cl_n}"
    fi
}

print_line_count() {
    if [ $filter -gt 0 ]; then
        if [ ! $count_lines -eq $count_total ]; then
            if [ $count_lines -eq 0 ]; then
                count=$(printf "%+8s" "0")
                temp="${cl_wh}Lines returned: ${cl_ly}"
                print_line "${temp}${count} (due to the given filter)"
            else
                count=$(printf "%+8s" $count_lines)
                temp="${cl_wh}Lines returned: ${cl_yl}${count}"
                print_line "$temp ${cl_ly}(due to the given filter)"
            fi
        fi
    fi

    count=$(printf "%+8s" $count_total)
    if [ $count_total -eq 0 ]; then
        temp="${cl_wh}Lines total:    ${cl_ly}"
        print_line "${temp}${count}${cl_ly}"
    else
        temp="${cl_wh}Lines total:    ${cl_yl}"
        print_line "${temp}${count}${cl_ly}"
    fi
}

print_output_header() {
    echo
    print_line "*"

    input_count=$(wc -w <<< $input_file)
    if [ $input_count -eq 1 ]; then
        filepath=$(readlink -f $input_file)
        print_line "${cl_wh}Input file:" "${cl_yl}$filepath"
    else
        desc="Input files:"
        for file in $input_file; do
            temp=$(sed -e "s/^ *//g;s/ *$//g;s/\/\//\ /g" <<< "$file")
            filepath=$(readlink -f "$temp")
            if [ -z "$filepath" ]; then
                continue
            fi
            print_line "${cl_wh}$desc" "${cl_yl}$filepath"
            if [ ! -z "$desc" ]; then
                desc=""
            fi
        done
        print_line
    fi

    if [ -z "$color_file" ]; then
        print_line "${cl_wh}Color file:" "${cl_ly}None"
    else
        temp=$(readlink -f $color_file)
        print_line "${cl_wh}Color file:" "${cl_yl}$temp"
    fi

    if [ -z "$export_file" ]; then
        print_line "${cl_wh}Export file:" "${cl_ly}None"
    else
        temp=$(readlink -f $export_file)
        print_line "${cl_wh}Export file:" "${cl_yl}$temp"
    fi

    print_line
    if [ $follow -eq 1 ]; then
        print_line "${cl_wh}Follow (monitor):" "${cl_lg}Yes"
        if [ $prompt -eq 1 ]; then
            temp="${cl_lg}Yes"
        else
            temp="${cl_lr}No"
        fi
        print_line "${cl_wh}Prompt on exit:" "$temp"
    else
        print_line "${cl_wh}Follow (monitor):" "${cl_lr}No"
        if [ $slow -eq 1 ]; then
            temp="${cl_lg}Yes ${cl_yl}(0.$delay seconds)"
        else
            temp="${cl_lr}No"
        fi
        print_line "${cl_wh}Slow down:" "$temp"
        if [ $pause -eq 1 ]; then
            if [ "$pause_lines" = "auto" ]; then
                temp="${cl_lg}Yes ${cl_yl}(based on terminal height)"
            elif [ $pause_lines -eq 1 ]; then
                temp="${cl_lg}Yes ${cl_yl}(after each line)"
            else
                temp="${cl_lg}Yes ${cl_yl}(after $pause_lines lines)"
            fi
        else
            temp="${cl_lr}No"
        fi
        print_line "${cl_wh}Pause output:" "$temp"
    fi

    if [ $wait_match -gt 0 ]; then
        if [ $wait_match -eq 1 ]; then
            sec="second"
        else
            sec="seconds"
        fi
        temp="${cl_lg}Yes ${cl_yl}($wait_match $sec)"
    else
        temp="${cl_lr}No"
    fi
    print_line "${cl_wh}Wait (on match):" "$temp"

    print_line
    if [ $exclude -eq 1 ]; then
        temp="${cl_yl}$exclude_pattern"
    else
        temp="${cl_ly}None"
    fi
    print_line "${cl_wh}Exclude pattern:" "$temp"

    if [ $remove -eq 1 ]; then
        temp="${cl_yl}$remove_pattern"
    else
        temp="${cl_ly}None"
    fi
    print_line "${cl_wh}Remove pattern:" "$temp"

    if [ $filter -eq 1 ]; then
        if [ ! -z "$filter_file" ]; then
            temp="${cl_wh}Filter file:"
            print_line "$temp" "${cl_yl}$filter_file"
        fi

        temp="${cl_wh}Filter pattern:"
        print_line "$temp" "${cl_yl}$filter_pattern"
        if [ "$arg_case" = "-i" ]; then
            temp="${cl_lg}Yes"
        else
            temp="${cl_lr}No"
        fi
        print_line "${cl_wh}Ignore case:" "${cl_lr}${temp}"

        if [ $highlight_matches -eq 1 ]; then
            temp="${cl_lg}Filter matches"
        elif [ $highlight_upper -eq 1 ]; then
            temp="${cl_lg}Filter matches (in uppercase)"
        elif [ $highlight_all -eq 1 ]; then
            temp="${cl_lg}All lines"
        else
            temp="${cl_lr}No"
        fi
        print_line "${cl_wh}Highlight:" "$temp"
    else
        print_line "${cl_wh}Filter pattern:" "${cl_ly}None"
        if [ $highlight_all -eq 1 ]; then
            temp="${cl_lg}All lines"
            print_line "${cl_wh}Highlight:" "$temp"
        else
            temp="${cl_lr}No"
            print_line "${cl_wh}Highlight:" "$temp"
        fi
    fi

    if [ $head_lines -gt 0 ] || [ $tail_lines -gt 0 ]; then
        print_line
        if [ $head_lines -gt 0 ]; then
            temp="${cl_wh}First lines (only):"
            print_line "$temp" "${cl_yl}$head_lines"
        fi
        if [ $tail_lines -gt 0 ]; then
            if [ $follow -eq 1 ]; then
                temp="${cl_wh}Last lines (also):"
                print_line "$temp" "${cl_yl}$tail_lines"
            else
                temp="${cl_wh}Last lines (only):"
                print_line "$temp" "${cl_yl}$tail_lines"
            fi
        fi
    fi

    print_line
    print_line "\c"

    echo -e "${cl_wh}Press"\
            "${cl_lc}Ctrl${cl_ly}+${cl_lc}C"\
            "${cl_wh}to ${cl_lr}cancel${cl_wh},"\
            "${cl_lc}Ctrl${cl_ly}+${cl_lc}S"\
            "${cl_wh}to ${cl_yl}freeze${cl_wh} and"\
            "${cl_lc}Ctrl${cl_ly}+${cl_lc}Q"\
            "${cl_wh}to ${cl_lg}defreeze${cl_wh} the output."

    print_line "*"
    echo
    trap "cancel_process" 2 20
}

print_output_line() {
    color_code=0
    color_match=0
    count_total=$(( count_total + 1 ))
    filter_match=0
    line_lower=$(tr '[:upper:]' '[:lower:]' <<< "$1")

    if [ $separator_line -eq 1 ]; then
        grep "^==>.*<==$" <<< $1 &>/dev/null
        if [ $? -eq 0 ]; then
            temp=$(sed -e "s/==>//g;s/<==//g;s/^ *//g;s/ *$//g" <<< $1)
            fp=$(readlink -f "$temp")
            ln=$(printf -- "-%.0s" $(seq 0 80))
            separator="${cl_dy}--${cl_ly}[${cl_yl}${fp}${cl_ly}]${cl_dy}$ln"
            echo -e "${separator}${cl_n}" | cut -c 1-113
            return
        fi
    fi

    if [ $highlight_cut_off = 0 ]; then
        term_cols=$(( $(tput cols) + 1 ))
        line_length=${#line_lower}

        while true; do
            if [ $line_length -lt $term_cols ]; then
                break
            fi

            line_length=$(( line_length - term_cols + 1 ))
        done

        line_filler=$(( term_cols - line_length ))
        line_spaces=$(seq -s " " ${line_filler} | tr -d '[:digit:]')
    else
        line_spaces=""
    fi

    if [ $exclude -eq 1 ]; then
        for string in $exclude_list; do
            temp=$(sed -e "s/#/\ /g" <<< "$string")
            string="$temp"

            grep -i "$string" <<< "$line_lower" &>/dev/null
            if [ $? -eq 0 ]; then
                return
            fi
        done
    fi

    get_color_match "$line"
    output="${color_code}${line}${cl_n}${line_spaces}"
    if [ ! -z "$filter_list" ]; then
        if [ $highlight_matches -eq 1 ] || [ $highlight_upper -eq 1 ]; then
            if [ $color_match -eq 1 ]; then
                if [ -z "$(grep "\[38;" <<< "$color_code")" ]; then
                    color_temp=$((sed -e "s/\[3/\[7;3/g" | \
                                  sed -e "s/\[9/\[7;9/g" | \
                                  sed -e "s/\[1;/\[1;7;/g") <<< "$color_code")
                    color_high="${hl_fgcolor}${color_temp}"
                else
                    if [ "$hl_fgcolor" = "$cl_n" ]; then
                        temp='s/\[38;/\[30;48;/g'
                        color_high="${hl_fgcolor}$((sed -e "$temp") \
                                    <<< "$color_code")"
                    else
                        temp='s/\[38;/\[48;/g'
                        color_high="${hl_fgcolor}$((sed -e "$temp") \
                                    <<< "$color_code")"
                    fi
                fi
            else
                color_code="\e[0m"
                color_high="\e[7m"
            fi

            for filter_term in $filter_list; do
                term=$(sed -e "s/#/\ /g" <<< "$filter_term")
                term_upper=$(tr '[:lower:]' '[:upper:]' <<< "$term")

                grep $arg_case "$term" <<< "$line" &>/dev/null
                if [ $? -eq 0 ]; then
                    if [ $highlight_upper -eq 1 ]; then
                        term_case=$term_upper
                    else
                        term_case=$term
                    fi
                    temp=$(echo -e "${color_high}${term_case}${cl_n}"\
                                   "\b${color_code}")

                    output=$(echo -e "${color_code}${line}${cl_n}" | \
                             sed -e "s/$term_upper/$temp/ig")

                    line="$output"
                    filter_match=1
                fi
            done
        else
            for filter_term in $filter_list; do
                term=$(sed -e "s/#/\ /g" <<< "$filter_term")
                term_upper=$(tr '[:lower:]' '[:upper:]' <<< "$term")

                grep $arg_case "$term" <<< "$line" &>/dev/null
                if [ $? -eq 0 ]; then
                    output="${color_code}${line}${cl_n}${line_spaces}"
                    filter_match=1
                    break
                fi
            done
        fi

        if [ $filter_match -eq 0 ]; then
            return
        fi
    fi

    if [ $remove -eq 1 ]; then
        for string in $remove_list; do
            temp=$(sed -e "s/#/\ /g" <<< "$string")
            line=$(echo -e "$output" | sed -e "s/${temp}//ig")
            output="$line"
        done
    fi

    if [ -z "$output" ]; then
        return
    fi

    if [ $highlight_matches -eq 1 ] || [ $highlight_upper -eq 1 ]; then
        highlight_all=0
    else
        if [ $highlight_all -eq 1 ]; then
            temp=$(echo -e "\e[7m$output" | sed -e "s/0m/7m/g")
            output="${temp}${cl_n}"
        fi
    fi

    if [ "$color_code" = "999" ]; then
        temp=$(sed -e "s/^$color_code//g" <<< "$output")
        output=$(sed -e "s/\\\e\[.*//g" <<< "$temp")
        random_colors "$output"
    else
        echo -e "$output"
    fi

    if [ $export_log -eq 1 ]; then
        echo -e "$output" >> $export_file
    fi

    count_lines=$(( count_lines + 1 ))

    if [ $color_match -eq 1 ]; then
        sleep $wait_match
    fi
}

# EOF
