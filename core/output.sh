#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Output core script
# Copyright (C) 2017 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
# 
# Website: http://www.urbanware.org
# GitHub: https://github.com/urbanware-org/salomon
# ============================================================================

print_line() {
    indent=30

    if [ "$1" = "" ]; then
        echo $em "${color_lightblue}*${color_none}"
    elif [ "$1" = "*" ]; then
        if [ "$em" = "-e" ]; then
            echo $em "${color_lightblue}${ce}"
                for number in $(seq 1 78); do
                echo $em "*${ce}"
            done
            echo $em "${color_none}"
        else
            echo "${seperator}${seperator}"
        fi
    else
        temp=$(printf "%-${indent}s" "$1")
        echo $em "${color_lightblue}* ${temp}${2}${color_none}"
    fi
}

print_line_count() {
    if [ ! $count_lines -eq $count_total ]; then
        if [ $count_lines -eq 0 ]; then
            count=$(printf "%+8s" "0")
            temp="${color_white}Lines returned: ${color_lightgray}"
            print_line "${temp}${count} (due to the given filter)"
        else
            count=$(printf "%+8s" $count_lines)
            temp="${color_white}Lines returned: ${color_yellow}${count}"
            print_line "$temp ${color_lightgray}(due to the given filter)"
        fi
    fi

    count=$(printf "%+8s" $count_total)
    if [ $count_total -eq 0 ]; then
        temp="${color_white}Lines total:    ${color_lightgray}"
        print_line "${temp}${count}${color_lightgray}"
    else
        temp="${color_white}Lines total:    ${color_yellow}"
        print_line "${temp}${count}${color_lightgray}"
    fi
}

print_output_header() {
    echo
    print_line "*"
    temp=$(readlink -f $input_file)
    print_line "${color_white}Input file:" "${color_yellow}$temp"

    if [ "$color_file" = "" ]; then
        print_line "${color_white}Color file:" "${color_lightgray}None"
    else
        temp=$(readlink -f $color_file)
        print_line "${color_white}Color file:" "${color_yellow}$temp"
    fi

    print_line
    if [ $follow -eq 1 ]; then
        print_line "${color_white}Follow (monitor):" "${color_lightgreen}Yes"
        if [ $prompt -eq 1 ]; then
            temp="${color_lightgreen}Yes"
        else
            temp="${color_lightred}No"
        fi
        print_line "${color_white}Prompt on exit:" "$temp"
    else
        print_line "${color_white}Follow (monitor):" "${color_lightred}No"
        if [ $slow -eq 1 ]; then
            temp="${color_lightgreen}Yes ${color_yellow}(0.$delay seconds)"
        else
            temp="${color_lightred}No"
        fi
        print_line "${color_white}Slow down:" "$temp"
    fi

    if [ $wait_match -gt 0 ]; then
        if [ $wait_match -eq 1 ]; then
            sec="second"
        else
            sec="seconds"
        fi
        temp="${color_lightgreen}Yes ${color_yellow}($wait_match.000 $sec)"
    else
        temp="${color_lightred}No"
    fi
    print_line "${color_white}Wait (on match):" "$temp"

    print_line
    if [ $exclude -eq 1 ]; then
        temp="${color_yellow}$exclude_pattern"
    else
        temp="${color_lightgray}None"
    fi
    print_line "${color_white}Exclude pattern:" "$temp"

    if [ $remove -eq 1 ]; then
        temp="${color_yellow}$remove_pattern"
    else
        temp="${color_lightgray}None"
    fi
    print_line "${color_white}Remove pattern:" "$temp"

    if [ $filter -eq 1 ]; then
        if [ ! -z "$filter_file" ]; then
            temp="${color_white}Filter file:"
            print_line "$temp" "${color_yellow}$filter_file"
        fi

        temp="${color_white}Filter pattern:"
        print_line "$temp" "${color_yellow}$filter_pattern"
        if [ "$arg_case" = "-i" ]; then
            temp="${color_lightgreen}Yes"
        else
            temp="${color_lightred}No"
        fi
        print_line "${color_white}Ignore case:" "${color_lightred}No"

        if [ $highlight -eq 0 ]; then
            temp="${color_lightred}No"
        else
            temp="${color_lightgreen}Yes"
        fi
        print_line "${color_white}Highlight:" "$temp"
    else
        print_line "${color_white}Filter pattern:" "${color_lightgray}None"
    fi

    if [ $follow -eq 1 ]; then
        print_line
        print_line "${ce}"
        if [ "$em" = "-e" ]; then
            temp=""
        else
            temp="* "
        fi
        echo $em "${temp}${color_white}Press${color_lightcyan}"\
                 "<Ctrl>${bs}${color_lightgray}+${color_lightcyan}<C>"\
                 "${color_white}to"\
                 "${color_lightred}cancel${color_white}."
    fi

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

    if [ $exclude -eq 1 ]; then
        for string in $(echo "$exclude_list"); do
            temp=$(sed -e "s/#/\ /g" <<< "$string")
            string="$temp"

            grep -i "$string" <<< "$line_lower" &>/dev/null
            if [ $? -eq 0 ]; then
                return
            fi
        done
    fi

    for color in $(echo "$color_list"); do
        if [ "${colorize_[$color]}" = "" ]; then
            continue
        fi

        items=$(echo "${colorize_[$color]}")
        for item in $(echo $items); do
            if [[ "$line_lower" = *$item* ]]; then
                color_match=1
                break
            fi
        done

        if [ $color_match -eq 1 ]; then
            get_color_code "$color"
            break
        else
            item=""
        fi
    done

    if [ "$color_code" = "0" ]; then
        color_code="$color_none"
    fi

    output="${color_code}${line}${color_none}"
    if [ ! -z "$filter_list" ]; then
        if [ $highlight -eq 1 ] || [ $highlight_upper -eq 1 ]; then
            if [ $color_match -eq 1 ]; then
                color_high=$((sed -e "s/0;/7;/g" | \
                              sed -e "s/1;/7;/g") <<< "$color_code")
            else
                if [ "$em" = "-e" ]; then
                    color_code="\e[0m"
                    color_high="\e[7m"
                else
                    color_code=""
                    color_high=""
                fi
            fi

            for filter_term in $(echo "$filter_list"); do
                term=$(sed -e "s/#/\ /g" <<< "$filter_term")
                term_upper=$(tr '[:lower:]' '[:upper:]' <<< "$term")

                grep $arg_case "$term" <<< "$line" &>/dev/null
                if [ $? -eq 0 ]; then
                    if [ $highlight_upper -eq 1 ]; then
                        term_case=$term_upper
                    else
                        term_case=$term
                    fi
                    temp=$(echo $em "${color_high}${term_case}${color_none}"\
                                    "${bs}${color_code}")

                    output=$(echo $em "${color_code}${line}${color_none}" | \
                             sed -e "s/$term_upper/$temp/ig")

                    line="$output"
                    filter_match=1
                fi
            done
        else
            for filter_term in $(echo "$filter_list"); do
                term=$(sed -e "s/#/\ /g" <<< "$filter_term")
                term_upper=$(tr '[:lower:]' '[:upper:]' <<< "$term")

                grep $arg_case "$term" <<< "$line" &>/dev/null
                if [ $? -eq 0 ]; then
                    output="${color_code}${line}${color_none}"
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
        for string in $(echo "$remove_list"); do
            temp=$(sed -e "s/#/\ /g" <<< "$string")
            line=$(echo $em "$output" | sed -e "s/${temp}//ig")
            output="$line"
        done
    fi

    echo $em "$output"
    count_lines=$(( count_lines + 1 ))

    if [ $color_match -eq 1 ]; then
        sleep $wait_match
    fi
}

# EOF

