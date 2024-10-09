#!/usr/bin/env bash

#
# Salomon - Simple log file monitor and analyzer
# Output core script
# Copyright (c) 2024 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

pause_output() {
    anykey="${cl_lr}Press ${cl_yl}any key${cl_n} to ${cl_lg}continue${cl_n}"
    anykey="${cl_ly}[$anykey${cl_ly}]"
    message="${cl_dy}$char_line_single$char_line_single$anykey${cl_dy}"
    echo -e "${message}\c"

    if [ "$line_width" = "auto" ]; then
        term_cols=$(( $(tput cols) - 29 ))
    else
        term_cols=49
    fi

    for (( term_col = 1; term_col <= $term_cols; term_col++ )); do
          echo -e "$char_line_single\c"
    done
    echo -e "\r\c"
    read -n1 -r < /dev/tty
    echo
}

print_line() {
    string_leading="$1"
    string_value="$2"
    indent=30

    if [ $exit_prompt -eq 1 ]; then
        if [ $canceled -eq 1 ]; then
            lc="${cl_lr}$char_prompt"
        else
            lc="${cl_lb}$char_prompt"
        fi
    else
        lc="${cl_lb}$char_header_line_v"
    fi

    if [ -z "$string_value" ]; then
        line_leading=0
    else
        line_leading=1
    fi

    if [ $boxdrawing_chars -eq 1 ]; then
        if [ "$line_width" = "auto" ]; then
            term_cols=$(( $(tput cols) - 2 ))
        else
            term_cols=76
        fi
    else
        if [ "$line_width" = "auto" ]; then
            term_cols=$(( $(tput cols) ))
        else
            term_cols=78
        fi
    fi

    if [ -z "$string_leading" ]; then
        echo -e "${cl_lb}$lc${cl_n}"
    elif [ "$string_leading" = "*" ]; then
        if [ "$lc" = "*" ]; then
            echo -e "${cl_lb}\c"
            for (( term_col = 1; term_col <= $term_cols; term_col++ )); do
                echo -e "*\c"
            done
            echo -e "${cl_n}"
        else
            if [ $line_leading -eq 1 ]; then
                echo -e "${cl_lb}$char_header_ctl\c"
            else
                echo -e "${cl_lb}$char_header_cbl\c"
            fi
            for (( term_col = 1; term_col <= $term_cols; term_col++ )); do
                echo -e "${char_header_line_h}\c"
            done
            if [ $line_leading -eq 1 ]; then
                echo -e "${cl_lb}$char_header_ctr\c"
            else
                echo -e "${cl_lb}$char_header_cbr\c"
            fi
            echo -e "${cl_n}"
        fi
    else
        string=$(printf "%-${indent}s" "$string_leading")
        echo -e "$lc ${string}${string_value}${cl_n}"
    fi
}

print_line_count() {
    if [ $filter -gt 0 ]; then
        if [ ! $count_lines -eq $count_total ]; then
            if [ $count_lines -eq 0 ]; then
                count=$(printf "%+8s" "0")
                msg_lines="${cl_wh}Lines returned: ${cl_ly}"
                print_line "${msg_lines}${count} (due to the given filter)"
            else
                count=$(printf "%+8s" $count_lines)
                msg_lines="${cl_wh}Lines returned: ${cl_yl}${count}"
                print_line "$msg_lines ${cl_ly}(due to the given filter)"
            fi
        fi
    fi

    count=$(printf "%+8s" $count_total)
    if [ $count_total -eq 0 ]; then
        msg_lines="${cl_wh}Lines total:    ${cl_ly}"
        print_line "${msg_lines}${count}${cl_ly}"
    else
        msg_lines="${cl_wh}Lines total:    ${cl_yl}"
        print_line "${msg_lines}${count}${cl_ly}"
    fi
}

print_output_header() {
    head_version="${cl_lc}Salomon ${version}${cl_n}"
    head_timestamp="${cl_lc}$(date)${cl_n}"
    head_pid="${cl_lc}$$${cl_n}"
    echo
    print_line "*" 1
    print_line "$head_version started on $head_timestamp with PID $head_pid"
    print_line

    input_count=$(wc -w <<< $input_file)
    if [ $input_count -eq 1 ]; then
        filepath=$(readlink -f $input_file)
        print_line "${cl_wh}Input file:" "${cl_yl}$filepath"
    else
        desc="Input files:"
        for file in $input_file; do
            file=$(sed -e "s/^ *//g;s/ *$//g;s/\/\//\ /g" <<< "$file")
            filepath=$(readlink -f "$file")
            if [ -z "$filepath" ]; then
                continue
            fi
            print_line "${cl_wh}$desc" "${cl_yl}$filepath"
            if [ -n "$desc" ]; then
                desc=""
            fi
        done
        print_line
        if [ $merge -eq 1 ]; then
            print_line "${cl_wh}Merge input files:" "${cl_lg}Yes"
        else
            print_line "${cl_wh}Merge input files:" "${cl_lr}No"
        fi
        print_line
    fi

    if [ -z "$color_file" ]; then
        print_line "${cl_wh}Color file:" "${cl_ly}None"
    else
        msg_color_file=$(readlink -f "$color_file")
        print_line "${cl_wh}Color file:" "${cl_yl}$msg_color_file"
    fi

    if [ -z "$export_file" ]; then
        print_line "${cl_wh}Export file:" "${cl_ly}None"
    else
        msg_export_file=$(readlink -f "$export_file")
        print_line "${cl_wh}Export file:" "${cl_yl}$msg_export_file"
    fi

    print_line
    if [ $follow -eq 1 ]; then
        print_line "${cl_wh}Follow (monitor):" "${cl_lg}Yes"

        if [ $prompt -eq 1 ]; then
            msg_prompt="${cl_lg}Yes"
        else
            msg_prompt="${cl_lr}No"
        fi
        print_line "${cl_wh}Prompt on exit:" "$msg_prompt"

    else
        print_line "${cl_wh}Follow (monitor):" "${cl_lr}No"

        if [ $merge -eq 1 ]; then
            msg_merge="${cl_lg}Yes"
        else
            msg_merge="${cl_lr}No"
        fi
        print_line "${cl_wh}Merge input files:" "$msg_merge"

        if [ $slow -eq 1 ]; then
            msg_slow="${cl_lg}Yes ${cl_yl}(0.$delay seconds)"
        else
            msg_slow="${cl_lr}No"
        fi
        print_line "${cl_wh}Slow down:" "$msg_slow"

        if [ $pause -eq 1 ]; then
            if [ "$pause_lines" = "auto" ]; then
                msg_pause="${cl_lg}Yes ${cl_yl}(based on terminal height)"
            elif [ $pause_lines -eq 1 ]; then
                msg_pause="${cl_lg}Yes ${cl_yl}(after each line)"
            else
                msg_pause="${cl_lg}Yes ${cl_yl}(after $pause_lines lines)"
            fi
        else
            msg_pause="${cl_lr}No"
        fi
        print_line "${cl_wh}Pause output:" "$msg_pause"
    fi

    if [ $wait_match -gt 0 ]; then
        if [ $wait_match -eq 1 ]; then
            sec="second"
        else
            sec="seconds"
        fi
        msg_wait="${cl_lg}Yes ${cl_yl}($wait_match $sec)"
    else
        msg_wait="${cl_lr}No"
    fi
    print_line "${cl_wh}Wait (on match):" "$msg_wait"

    print_line
    if [ $exclude -eq 1 ]; then
        msg_exclude="${cl_dy}\"${cl_yl}$exclude_pattern${cl_dy}\""
    else
        msg_exclude="${cl_ly}None"
    fi
    print_line "${cl_wh}Exclude pattern:" "$msg_exclude"

    if [ $remove -eq 1 ]; then
        msg_remove="${cl_dy}\"${cl_yl}$remove_pattern${cl_dy}\""
    else
        msg_remove="${cl_ly}None"
    fi
    print_line "${cl_wh}Remove pattern:" "$msg_remove"

    if [ $filter -eq 1 ]; then
        if [ -n "$filter_file" ]; then
            msg_filter="${cl_wh}Filter file:"
            print_line "$msg_filter" "${cl_yl}$filter_file"
        fi

        msg_pattern="${cl_wh}Filter pattern:"
        print_line "$msg_pattern" \
                    "${cl_dy}\"${cl_yl}$filter_pattern${cl_dy}\""

        if [ "$arg_case" = "-i" ]; then
            msg_case="${cl_lg}Yes"
        else
            msg_case="${cl_lr}No"
        fi
        print_line "${cl_wh}Ignore case:" "${cl_lr}${msg_case}"

        if [ $highlight_matches -eq 1 ]; then
            msg_highlight="${cl_lg}Filter matches"
        elif [ $highlight_upper -eq 1 ]; then
            msg_highlight="${cl_lg}Filter matches (in uppercase)"
        elif [ $highlight_all -eq 1 ]; then
            msg_highlight="${cl_lg}All lines"
        else
            msg_highlight="${cl_lr}No"
        fi
        print_line "${cl_wh}Highlight:" "$msg_highlight"
    else
        print_line "${cl_wh}Filter pattern:" "${cl_ly}None"
        if [ $highlight_all -eq 1 ]; then
            msg_highlight="${cl_lg}All lines"
            print_line "${cl_wh}Highlight:" "$msg_highlight"
        else
            msg_highlight="${cl_lr}No"
            print_line "${cl_wh}Highlight:" "$msg_highlight"
        fi
    fi

    if [ $head_lines -gt 0 ] || [ $tail_lines -gt 0 ]; then
        print_line
        if [ $head_lines -gt 0 ]; then
            msg_head="${cl_wh}First lines (only):"
            print_line "$msg_head" "${cl_yl}$head_lines"
        fi
        if [ $tail_lines -gt 0 ]; then
            if [ $follow -eq 1 ]; then
                msg_tail="${cl_wh}Last lines (also):"
                print_line "$msg_tail" "${cl_yl}$tail_lines"
            else
                msg_tail="${cl_wh}Last lines (only):"
                print_line "$msg_tail" "${cl_yl}$tail_lines"
            fi
        fi
    fi

    if [ $analyze_less -eq 0 ]; then
        print_line
        print_line "\c"

        # The following keystrokes are pre-defined by the terminal driver.
        # Salomon handles them as follows:
        #
        #   Ctrl+C = cancel (exit)
        #   Ctrl+S = stop printing output
        #   Ctrl+Q = continue printing output (or "qontinue" as the 'C' key
        #            is already taken)
        #
        # Pressing Ctrl+Z sends stop signal 20 (SIGTSTP) which prints the
        # status "Stopped" when pressed. So, to avoid confusion the term
        # "freeze" is used for stopping the output instead. Its counterpart
        # is "unfreeze" (formerly "defreeze") to unify the terms.
        echo -e "${cl_wh}Press" \
                "${cl_lc}Ctrl${cl_ly}+${cl_lc}C" \
                "${cl_wh}to ${cl_lr}cancel${cl_wh}," \
                "${cl_lc}Ctrl${cl_ly}+${cl_lc}S" \
                "${cl_wh}to ${cl_yl}freeze${cl_wh} and" \
                "${cl_lc}Ctrl${cl_ly}+${cl_lc}Q" \
                "${cl_wh}to ${cl_lg}unfreeze${cl_wh} the output."
    fi
    print_line "*"
    echo

    if [ $analyze_less -eq 1 ]; then
        print_line "${cl_yl}Processing the input files for analyzing them \c"
        echo -e "using the '${cl_wh}less${cl_yl}' command."
        print_line "${cl_yl}Please wait. Depending on the amount of data" \
                    "this may take a while."
        print_line
        print_line "\c"
        echo -e "${cl_wh}Press" \
                "${cl_lc}Ctrl${cl_ly}+${cl_lc}C" \
                "${cl_wh}to ${cl_lr}cancel${cl_wh}."
        print_line
    fi
    if [ $is_bsd -eq 1 ]; then
        trap "cancel_process" 2
    fi
}

print_output_line() {
    color_code=0
    color_match=0
    count_total=$(( count_total + 1 ))
    filter_match=0

    line="$1"
    if [ -z "$line" ] && [ $merge -eq 1 ]; then
        return
    fi

    is_separator=0
    grep "^==>.*<==$" <<< $line &>/dev/null
    if [ $? -eq 0 ]; then
        is_separator=1
        string=$(sed -e "s/==>//g;s/<==//g;s/^ *//g;s/ *$//g" <<< $line)
        fp=$(readlink -f "$string")
        fp_len=$(wc -c <<< $fp)
        if [ $merge -eq 1 ]; then
            return
        fi
    fi

    if [ $separator_line -eq 1 ]; then
        if [ $is_separator -eq 1 ]; then
            if [ "$line_width" = "auto" ]; then
                term_cols=$(( $(tput cols) + 1 - fp_len - 4 ))
            else
                term_cols=$(( 79 - fp_len - 4))
            fi
            fpc="${cl_ly}[${cl_yl}$fp${cl_ly}]"
            echo -e "${cl_dy}$char_line_single$char_line_single$fpc${cl_dy}\c"
            for (( term_col = 1; term_col <= $term_cols; term_col++ )); do
                echo -e "$char_line_single\c"
            done
            echo -e "${cl_n}"
            return
        fi
    fi
    line_lower=$(tr '[:upper:]' '[:lower:]' <<< "$line")

    if [ -n "$line" ] && [ $timestamp -eq 1 ]; then
        lstamp=$(date -r "$fp" "${leading_timestamp}")
        line="${lstamp}${line}"
    fi
    line_lower=$(tr '[:upper:]' '[:lower:]' <<< "$line")

    if [ $highlight_cut_off = 0 ]; then
        term_cols=$(( $(tput cols) + 1 ))
        line_length=${#line_lower}

        if [ $leading_line_char -eq 1 ]; then
            term_cols=$(( term_cols - 2 ))
        fi

        while true; do
            if [ $line_length -lt $term_cols ]; then
                break
            fi
            line_length=$(( line_length - term_cols + 1 ))
        done

        line_filler=$(( ( term_cols - line_length ) - 1 ))
        line_spaces=$(printf "%${line_filler}s" | tr -d '[:digit:]')
    else
        line_spaces=""
    fi

    if [ $exclude -eq 1 ]; then
        for string in $exclude_list; do
            string=$(sed -e "s/#/\ /g" <<< "$string")
            grep -i "$string" <<< "$line_lower" &>/dev/null
            if [ $? -eq 0 ]; then
                return
            fi
        done
    fi

    get_color_match "$line"
    output="${color_code}${line}${cl_n}${line_spaces}"
    if [ -n "$filter_list" ]; then
        if [ $highlight_matches -eq 1 ] || [ $highlight_upper -eq 1 ]; then
            if [ $color_match -eq 1 ]; then
                if [ -z "$(grep "\[38;" <<< "$color_code")" ]; then
                    color_temp=$((sed -e "s/\[3/\[7;3/g" | \
                                  sed -e "s/\[9/\[7;9/g" | \
                                  sed -e "s/\[1;/\[1;7;/g") <<< "$color_code")
                    color_high="${hl_fgcolor}${color_temp}"
                else
                    if [ "$hl_fgcolor" = "$cl_n" ]; then
                        color_temp='s/\[38;/\[30;48;/g'
                        color_high="${hl_fgcolor}$((sed -e "$color_temp") \
                                    <<< "$color_code")"
                    else
                        color_temp='s/\[38;/\[48;/g'
                        color_high="${hl_fgcolor}$((sed -e "$color_temp") \
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
                    color_temp=$(echo -e "${color_high}${term_case}${cl_n}" \
                                   "\b${color_code}")

                    if [ $is_openbsd -eq 1 ]; then
                        if [ $highlight_upper -eq 1 ]; then
                            line=$(tr '[:lower:]' '[:upper:]' <<< "$line")
                        fi
                        output=$(echo -e "${color_code}${line}${cl_n}" | \
                                 sed -e "s/$term_upper/$color_temp/g")
                    else
                        output=$(echo -e "${color_code}${line}${cl_n}" | \
                                 sed -e "s/$term_upper/$color_temp/ig")
                    fi

                    line="$output"
                    filter_match=1
                    if [ $is_openbsd -eq 1 ]; then
                        break
                    fi
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
            output=""
            return
        fi
    fi

    if [ $remove -eq 1 ]; then
        for string in $remove_list; do
            string=$(sed -e "s/#/\ /g" <<< "$string")
            if [ $is_openbsd -eq 1 ]; then
                if [ $highlight_upper -eq 1 ]; then
                    string=$(tr '[:lower:]' '[:upper:]' <<< "$string")
                fi
                line=$(echo -e "$output" | sed -e "s/${string}//g")
            else
                line=$(echo -e "$output" | sed -e "s/${string}//ig")
            fi
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
            line=$(echo -e "\e[7m$output" | sed -e "s/0m/7m/g")
            output="${line}${cl_n}"
        fi
    fi

    if [ $leading_line_char_colored -eq 1 ]; then
        if [ $leading_line_char_custom_color -ge 1 ] &&
           [ $leading_line_char_custom_color -le 255 ]; then
            get_color_code $leading_line_char_custom_color
            char_ll="${color_code}${char_line_leading}${cl_n}"
        else
            char_ll="${color_code}${char_line_leading}${cl_n}"
        fi
    else
        char_ll="${cl_n}${char_line_leading}${cl_n}"
    fi

    if [ "$color_code" = "999" ]; then
        line=$(sed -e "s/^$color_code//g" <<< "$output")
        output=$(sed -e "s/\\\e\[.*//g" <<< "$line")
        random_colors "$output"
    elif [ "$color_code" = "${cl_n}" ] && [ $highlight_all -eq 0 ]; then
        if [ $leading_line_char -eq 1 ]; then
            echo -e "${cl_n}${char_ll} ${line}${cl_n}"
        else
            echo -e "${cl_n}${line}${cl_n}"
        fi
    else

        if [ $leading_line_char -eq 1 ]; then
            echo -e "${char_ll} ${output}"
        else
            echo -e "${output}"
        fi
    fi

    if [ $export_log -eq 1 ]; then
        echo -e "$output" >> $export_file
    fi

    count_lines=$(( count_lines + 1 ))

    if [ $color_match -eq 1 ]; then
        sleep $wait_match
    fi
}
