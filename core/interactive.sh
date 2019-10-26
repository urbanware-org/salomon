#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Interactive dialog mode core script
# Copyright (C) 2019 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
# ============================================================================

interactive_mode() {
    dialog_welcome

    dialog_valid=0
    while [ $dialog_valid -eq 0 ]; do
        get_input_file
    done

    dialog_action "$action"
    if [ $? -eq 0 ]; then
        action="analyze"
        follow=0
    else
        action="monitor"
    fi
    concat_arg "-a $action"

    dialog_prompt_on_exit $prompt
    if [ $? -eq 0 ]; then
        prompt=1
        concat_arg "-p"
    else
        prompt=0
    fi

    dialog_valid=0
    while [ $dialog_valid -eq 0 ]; do
        get_color_file
    done

    dialog_valid=0
    while [ $dialog_valid -eq 0 ]; do
        get_filter_pattern
    done

    if [ -z "$color_file" ]; then
        highlight_all=0
        highlight_cut_off=0
        highlight_matches=0
        highlight_upper=0
    else
        dialog_highlight
        if [ $user_input -eq 2 ]; then
            highlight_all=1
            concat_arg "-ha"
        elif [ $user_input -eq 3 ]; then
            highlight_all=1
            highlight_cut_off=1
            concat_arg "-ha --cut-off"
        elif [ $user_input -eq 4 ]; then
            highlight_matches=1
            concat_arg "-hm"
        elif [ $user_input -eq 5 ]; then
            highlight_upper=1
            concat_arg "-hu"
        fi

        if [ "$highlight_forecolor" = "1" ] || \
           [ "$highlight_forecolor" = "black" ]; then
            hl_fgcolor="$cl_bk"
        elif [ "$highlight_forecolor" = "2" ] || \
             [ "$highlight_forecolor" = "white" ]; then
            hl_fgcolor="$cl_wh"
        else
            hl_fgcolor="$cl_n"
        fi
    fi

    dialog_valid=0
    while [ $dialog_valid -eq 0 ]; do
        get_exclude_pattern
    done

    dialog_valid=0
    while [ $dialog_valid -eq 0 ]; do
        get_remove_pattern
    done

    input_count=$(wc -w <<< "$input_file")
    if [ $input_count -eq 1 ]; then
        if [ $follow -eq 0 ]; then
            dialog_valid=0
            while [ $dialog_valid -eq 0 ]; do
                get_head_lines
            done
        else
            head_lines=0
        fi
        if [ $head_lines -eq 0 ]; then
            dialog_valid=0
            while [ $dialog_valid -eq 0 ]; do
                get_tail_lines
            done
        else
            tail_lines=0
        fi
    fi

    if [ $follow -eq 1 ]; then
        pause=0
    else
        dialog_valid=0
        while [ $dialog_valid -eq 0 ]; do
            get_pause_lines
        done
    fi

    dialog_slow_down "$slow"
    if [ $? -eq 0 ]; then
        dialog_valid=0
        while [ $dialog_valid -eq 0 ]; do
            get_slow_down_delay
        done
    else
        slow=0
        delay=0
    fi

    dialog_valid=0
    while [ $dialog_valid -eq 0 ]; do
        get_wait_on_match
    done

    dialog_valid=0
    while [ $dialog_valid -eq 0 ]; do
        get_export_file
    done

    dialog_no_info $header
    if [ $? -eq 0 ]; then
        header=1
    else
        header=0
        concat_arg "--no-info"
    fi

    dialog_arg_list
    clear
}

get_color_file() {
    dialog_color_file "$color_file"
    color_file="$user_input"

    if [ -z "$color_file" ]; then
        predef_info_dialog \
          "Without a color file there are no highlighting options available"
        dialog_valid=1
        return
    else
        filemsg="The given color config file"
        if [ ! -e "$color_file" ]; then
            color_file="${color_dir}${color_file}"
            if [ ! -e "$color_file" ]; then
                predef_error_dialog "$filemsg '$user_input' does not exist"
                color_file="$user_input"
                return
            fi
        fi

        if [ ! -f "$color_file" ]; then
            predef_error_dialog "$filemsg path '$user_input' is not a file"
            color_file="$user_input"
            return
        else
            concat_arg "-c $color_file"
            dialog_valid=1
        fi
    fi
}

get_exclude_pattern() {
    dialog_exclude_pattern "$exclude_pattern"
    exclude_pattern="$user_input"

    if [ -z "$exclude_pattern" ]; then
        dialog_valid=1
        return
    else
        if [[ $exclude_pattern == *"#"* ]]; then
            predef_error_dialog \
              "The exclude pattern must not contain any hashes"
            return
        else
            exclude_list=$((tr -s ";;" ";" | \
                            sed -e "s/^;*//" \
                                -e "s/;*$//" \
                                -e "s/\ /#/g" \
                                -e "s/;/\n/g") <<< "$exclude_pattern")
            exclude=1
            concat_arg "-e $exclude_pattern"
            dialog_valid=1
        fi
    fi
}

get_export_file() {
    dialog_export_file $export_file
    export_file="$user_input"

    if [ -z "$export_file" ]; then
        export_log=0
        dialog_valid=1
        return
    else
        filemsg="The given export file path '$export_file'"
        if [ -e "$export_file" ]; then
            if [ -d "$export_file" ]; then
                predef_error_dialog "$filemsg is not a file"
                return
            elif [ -f "$export_file" ]; then
                predef_error_dialog "$filemsg already exists"
                return
            fi
        else
            touch $export_file &>/dev/null
            if [ $? -ne 0 ]; then
                predef_error_dialog "$filemsg seems to be read-only"
                return
            else
                export_log=1
                concat_arg "--export-file $export_file"
                dialog_valid=1
            fi
        fi
    fi
}

get_filter_pattern() {
    dialog_filter_pattern "$filter_pattern"
    filter_pattern="$user_input"

    if [ -z "$filter_pattern" ]; then
        arg_case=""
        dialog_valid=1
        return
    else
        if [ -f "$filter_pattern" ]; then
            filter_file="$filter_pattern"
            read_filter
        elif [ -f "${filter_dir}${filter}" ]; then
            filter_file="${filter_dir}${filter}"
            read_filter
        else
            if [[ $filter_pattern == *"#"* ]]; then
                predef_error_dialog \
                  "The filter pattern must not contain any hashes"
                return
            else
                temp=$((tr -s ";;" ";" | \
                        sed -e "s/^;//" \
                            -e "s/;$//") <<< "$filter_pattern")
                filter_list=$(sed -e "s/^;*//g" \
                                  -e "s/;*$//g" \
                                  -e "s/\ /#/g" \
                                  -e "s/;/\n/g" <<< "$temp")
                filter_pattern=$(sed -e "s/#/\ /g" <<< "$temp")
                filter=1
                concat_arg "-f $filter_pattern"
                dialog_valid=1
            fi
        fi
    fi
}

get_head_lines() {
    if [ "$head_lines" = "0" ]; then
        dialog_head_lines
    else
        dialog_head_lines "$head_lines"
    fi
    head_lines="$user_input"

    if [ -z "$head_lines" ] || [ $head_lines -eq 0 ]; then
        head_lines=0
        dialog_valid=1
        return
    else
        re='^[0-9]+$'
        if [[ ! $head_lines =~ $re ]]; then
            predef_error_dialog "The given value is not a number"
        else
            concat_arg "--head $head_lines"
            dialog_valid=1
        fi
    fi
}

get_input_file() {
    dialog_input_file "$input_file"
    input_file="$user_input"
    input_valid=0

    if [ -z "$input_file" ]; then
        predef_error_dialog "No input file(s) given"
        return
    fi

    for item in $input_file; do
        filemsg="The given input file"
        file=$(sed -e "s/^ *//g;s/ *$//g;s/\/\//\ /g" <<< $item)
        if [ -e "$file" ]; then
            filepath="$file"
        elif [ -e "/var/log/$file" ]; then
            filepath="/var/log/$file"
        else
            predef_error_dialog "$filemsg '$file' does not exist"
            return
        fi

        if [ ! -f "$filepath" ]; then
            predef_error_dialog "$filemsg path '$file' is not a file"
            return
        else
            tail "$filepath" &>/dev/null
            if [ $? -ne 0 ]; then
                predef_error_dialog \
                  "No read permission on the given input file '$filepath'"
            else
                concat_arg "-i $filepath"
                input_valid=1
                temp="$filelist $(sed -e "s/\ /\/\//g" <<< "$filepath")"
                filelist="$temp"
            fi
        fi
    done

    if [ $input_valid -eq 1 ]; then
        dialog_valid=1
    fi
}

get_pause_lines() {
    if [ "$pause_lines" = "0" ]; then
        dialog_pause_output
    else
        dialog_pause_output "$pause_lines"
    fi
    pause_lines="$user_input"

    if [ -z "$pause_lines" ] || [ $pause_lines -eq 0 ]; then
        pause=0
        dialog_valid=1
        return
    else
        if [ "$pause_lines" = "auto" ]; then
            pause=1
            concat_arg "--pause auto"
            dialog_valid=1
            return
        else
            re='^[0-9]+$'
            if [ $pause_lines -lt 1 ] || [[ ! $pause_lines =~ $re ]]; then
                predef_error_dialog \
                  "The amount must be a number greater than zero or 'auto'"
            else
                pause=1
                concat_arg "--pause $pause_lines"
                dialog_valid=1
            fi
        fi
    fi
}

get_remove_pattern() {
    dialog_remove_pattern "$remove_pattern"
    remove_pattern="$user_input"

    if [ -z "$remove_pattern" ]; then
        dialog_valid=1
        return
    else
        if [[ $remove_pattern == *"#"* ]]; then
            predef_error_dialog \
              "The remove pattern must not contain any hashes"
            return
        else
            remove_list=$((tr -s ";;" ";" | \
                           sed -e "s/^;*//" \
                               -e "s/;*$//" \
                               -e "s/\ /#/g" \
                               -e "s/;/\n/g") <<< "$remove_pattern")
            remove=1
            concat_arg "-r $remove_pattern"
            dialog_valid=1
        fi
    fi
}

get_slow_down_delay() {
    dialog_delay "$delay"
    delay="$user_input"

    if [ -z "$delay" ] || [ $delay -eq 0 ]; then
        slow=0
        delay=0
        dialog_valid=1
        return
    fi

    grep -E "^[0-9]*$" <<< "$delay" &>/dev/null
    if [ $? -ne 0 ]; then
        predef_error_dialog \
          "The delay must be zero (for none) or a number between 100 and 900"
        return
    elif [ $delay -lt 100 ] || [ $delay -gt 900 ]; then
        predef_error_dialog \
          "The delay must be zero (for none) or a number between 100 and 900"
        return
    else
        slow=1
        concat_arg "-s --delay $delay"
        dialog_valid=1
  fi
}

get_tail_lines() {
    if [ "$tail_lines" = "0" ]; then
        dialog_tail_lines
    else
        dialog_tail_lines "$tail_lines"
    fi
    tail_lines="$user_input"

    if [ -z "$tail_lines" ] || [ $tail_lines -eq 0 ]; then
        tail_lines=0
        dialog_valid=1
        return
    else
        re='^[0-9]+$'
        if [[ ! $tail_lines =~ $re ]]; then
            predef_error_dialog "The given value is not a number"
        else
            concat_arg "--tail $tail_lines"
            dialog_valid=1
        fi
    fi
}

get_wait_on_match() {
    if [ "$wait_match" = "0" ]; then
        dialog_wait_on_match
    else
        dialog_wait_on_match "$wait_match"
    fi
    wait_match="$user_input"

    if [ -z "$wait_match" ] || [ $wait_match -eq 0 ]; then
        wait_match=0
        dialog_valid=1
        return
    else
        grep -E "^[0-9]*$" <<< "$wait_match" &>/dev/null
        if [ $? -ne 0 ]; then
            predef_error_dialog \
              "The wait value must be a number greater than zero"
        else
            if [ $wait_match -le 0 ]; then
                wait=0
            else
                concat_arg "-w $wait_match"
                dialog_valid=1
            fi
        fi
    fi
}

# EOF
