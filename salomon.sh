#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Main script
# Copyright (C) 2018 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
# ============================================================================

# Pre-check if the Bash shell is installed and if this script has been
# executed using it
command -v bash >/dev/null 2>&1
if [ "$?" != "0" ]; then
    echo "error: The Bash shell does not seem to be installed, run the"\
                "compatibility"
    echo "       script ('compat.sh') for details."
    exit 1
elif [ ! -n "$BASH" ]; then
    echo "error: This script must be executed using the Bash shell, run the"
    echo "       compatibility script ('compat.sh') for details."
    exit 1
else
    bash_major=$(sed -e "s/\..*//g" <<< $BASH_VERSION)
    if [ $bash_major -lt 4 ]; then
        echo "error: This script requires at least version 4 of the Bash"\
                    "shell, run the"
        echo "       compatibility script ('compat.sh') for details."
        exit 1
    fi
fi

# General preparation
script_dir=$(dirname $(readlink -f $0))
script_file=$(basename "$0")
source ${script_dir}/core/analyze.sh
source ${script_dir}/core/colors.sh
source ${script_dir}/core/common.sh
source ${script_dir}/core/dialogs.sh
source ${script_dir}/core/global.sh
source ${script_dir}/core/monitor.sh
source ${script_dir}/core/output.sh
source ${script_dir}/salomon.cfg
set_global_variables
shell_precheck

# Check command-line arguments
if [ $# -eq 0 ]; then
    usage "At least one required argument is missing"
else
    while [[ $# > 0 ]]; do
        arg="$1"
        case "$arg" in
            # Required arguments
            -a|--action)
                shift
                action="$1"
                shift
            ;;
            -i|--input-file)
                shift
                prepare_path "$1"
                input_file="$input_file $path_prepared"
                check_argument "-i/--input-file" "$input_file" "file"
                shift
            ;;

            # Optional arguments
            -c|--color-file)
                shift
                color_file="$1"
                check_argument "-c/--color-file" "$color_file" "file"
                shift
            ;;
            --color-table)
                color_table=1
                shift
            ;;
            --cut-off)
                highlight_cut_off=1
                shift
            ;;
            -d|--delay)
                shift
                delay="$1"
                shift
            ;;
            --dialogs)
                interactive=1
                shift
            ;;
            -e|--exclude)
                shift
                exclude_pattern="$1"
                shift
            ;;
            --export-file)
                shift
                export_file="$1"
                export_log=1
                shift
            ;;
            -f|--filter)
                shift
                filter_pattern="$1"
                shift
            ;;
            -\?|-h|--help)
                usage
            ;;
            -ha|--highlight-all)
                highlight_all=1
                shift
            ;;
            -hm|--highlight-matches)
                highlight_matches=1
                shift
            ;;
            -hu|--highlight-upper)
                highlight_upper=1
                shift
            ;;
            --head)
                shift
                head_lines="$1"
                shift
            ;;
            --ignore-case)
                arg_case="-i"
                shift
            ;;
            --interactive)
                interactive=1
                shift
            ;;
            --no-info)
                header=0
                shift
            ;;
            -p|--prompt)
                prompt=1
                shift
            ;;
            --pause)
                shift
                pause_lines="$1"
                pause=1
                shift
            ;;
            -r|--remove)
                shift
                remove_pattern="$1"
                shift
            ;;
            -s|--slow)
                slow=1
                shift
            ;;
            --tail)
                shift
                tail_lines="$1"
                shift
            ;;
            --version)
                echo "$version"
                exit
            ;;
            --version-update)
                check_update
            ;;
            -w|--wait)
                shift
                wait_match="$1"
                shift
            ;;

            # Alternatives to the required arguments
            --analyze)
                action="analyze"
                shift
            ;;
            --monitor)
                action="monitor"
                shift
            ;;

            # Backwards compatibility arguments (still existing, but no longer
            # listed inside the usage information)
            --config-file)
                shift
                color_file="$1"
                check_argument "--config-file" "$color_file" "file"
                deprecated_argument "--config-file" "--color-file"
                shift
            ;;
            --highlight)
                highlight_matches=1
                deprecated_argument "--highlight" "--highlight-matches"
                shift
            ;;
            -n|--no-follow)
                follow=0
                deprecated_argument "--no-follow" "--action"
                shift
            ;;
            --no-header)
                header=0
                deprecated_argument "--no-header" "--no-info"
                shift
            ;;

            # Unrecognized arguments
            *)
                usage "The given argument '$1' is unrecognized"
            ;;
        esac
    done

    # Print color table (if requested)
    if [ $color_table -eq 1 ]; then
        print_color_table
        exit
    fi

    # Input file
    temp=$(sed -e "s/^ *//g;s/ *$//g" <<< "$input_file")
    input_file="$temp"

    if [ $interactive -eq 1 ]; then
        if [ "$dialog_program" = "auto" ]; then
            command -v dialog &>/dev/null
            if [ $? -eq 0 ]; then
                dialog_program="dialog"
            else
                command -v whiptail &>/dev/null
                if [ $? -eq 0 ]; then
                    dialog_program="whiptail"
                else
                    dialog_program=""
                fi
            fi
        elif [ "$dialog_program" = "dialog" ]; then
            command -v dialog &>/dev/null
            if [ $? -ne 0 ]; then
                dialog_program=""
            fi
        elif [ "$dialog_program" = "whiptail" ]; then
            command -v whiptail &>/dev/null
            if [ $? -ne 0 ]; then
                dialog_program=""
            fi
        else
            dialog_program=""
            usage "The given dialog program is not supported"
        fi

        if [ -z "$dialog_program" ]; then
            usage "No supported dialog program found"
        fi

        init_dialogs
        dialog_input_file "$input_file"
        input_file=$user_input
    fi

    if [ -z "$input_file" ]; then
        usage "No input file(s) given"
    fi

    for item in $input_file; do
        file=$(sed -e "s/^ *//g;s/ *$//g;s/\/\//\ /g" <<< $item)
        if [ -e "$file" ]; then
            filepath="$file"
        elif [ -e "/var/log/$file" ]; then
            filepath="/var/log/$file"
        else
            usage "The given input file '$file' does not exist"
        fi

        if [ ! -f "$filepath" ]; then
            usage "The given input file path '$file' is not a file"
        fi

        temp="$filelist $(sed -e "s/\ /\/\//g" <<< "$filepath")"
        filelist="$temp"
    done
    input_file="$filelist"

    # Action to perform
    if [ $interactive -eq 1 ]; then
        dialog_action "$action"
        if [ $? -eq 0 ]; then
            action="analyze"
            follow=0
        else
            action="monitor"
        fi
    fi

    if [ ! -z "$action" ]; then
        if [ "$action" = "analyze" ]; then
            follow=0
        elif [ "$action" = "monitor" ]; then
            if [ $follow -eq 0 ]; then
                usage "Multiple action arguments given (only one allowed)"
            fi
        else
            usage "The action '$action' does not exist"
        fi
    else
        usage "No action given (must either be '--analyze' or '--monitor')"
    fi

    # Prompt before exit
    if [ $interactive -eq 1 ]; then
        dialog_prompt_on_exit $prompt
        if [ $? -eq 0 ]; then
            prompt=1
        else
            prompt=0
        fi
    fi

    # Color file
    if [ $interactive -eq 1 ]; then
        dialog_color_file "$color_file"
        color_file="$user_input"
    fi

    if [ ! -z "$color_file" ]; then
        if [ ! -e "$color_file" ]; then
            color_file="${color_dir}${color_file}"
            if [ ! -e "$color_file" ]; then
                usage "The given color config file does not exist"
            fi
        fi
        if [ ! -f "$color_file" ]; then
            usage "The given color config file path is not a file"
        else
            read_color_file "$color_file"
        fi
    fi

    # Filter pattern
    if [ $interactive -eq 1 ]; then
        dialog_filter_pattern "$filter_pattern"
        filter_pattern="$user_input"

        if [ -z "$filter_pattern" ]; then
            arg_case=""
        else
            if [[ $filter_pattern == *"#"* ]]; then
                usage "The filter pattern must not contain any hashes"
            fi
            dialog_ignore_case "$arg_case"
            if [ $? -eq 0 ]; then
                arg_case="-i"
            else
                arg_case=""
            fi
        fi
    fi

    if [ -z "$filter_pattern" ]; then
        if [ "$arg_case" = "-i" ]; then
            usage \
                "The '--ignore-case' argument can only be used with a filter"
        fi
        if [ $highlight_matches -eq 1 ] || [ $highlight_upper -eq 1 ]; then
            usage \
                "This highlighting argument can only be used with a filter"
        fi
    else
        if [ -f "$filter_pattern" ]; then
            filter_file="$filter_pattern"
            read_filter
        elif [ -f "${filter_dir}${filter}" ]; then
            filter_file="${filter_dir}${filter}"
            read_filter
        else
            if [[ $filter_pattern == *"#"* ]]; then
                usage "The filter pattern must not contain any hashes"
            fi
        fi

        temp=$((tr -s ";;" ";" | \
                sed -e "s/^;//" \
                    -e "s/;$//") <<< "$filter_pattern")
        filter_list=$(sed -e "s/^;*//g" \
                          -e "s/;*$//g" \
                          -e "s/\ /#/g" \
                          -e "s/;/\n/g" <<< "$temp")
        filter_pattern=$(sed -e "s/#/\ /g" <<< "$temp")
        filter=1
    fi

    # Highlighting
    if [ $interactive -eq 1 ]; then
        dialog_highlight
        if [ $user_input -eq 2 ]; then
            highlight_all=1
        elif [ $user_input -eq 3 ]; then
            highlight_all=1
            highlight_cut_off=1
        elif [ $user_input -eq 4 ]; then
            highlight_matches=1
        elif [ $user_input -eq 5 ]; then
            highlight_upper=1
        fi
    fi

    highlight_params=$((
        highlight_all + highlight_matches + highlight_upper ))

    if [ $highlight_params -gt 1 ]; then
        usage \
            "Multiple highlighting arguments given (only one allowed)"
    fi

    if [ $highlight_all -eq 0 ] && [ $highlight_cut_off -eq 1 ]; then
        usage \
            "The '--cut-off' argument can only be used with '--highlight-all'"
    fi

    # Exclude pattern
    if [ $interactive -eq 1 ]; then
        dialog_exclude_pattern "$exclude_pattern"
        exclude_pattern="$user_input"
    fi

    if [ ! -z "$exclude_pattern" ]; then
        if [[ $exclude_pattern == *"#"* ]]; then
            usage "The exclude pattern must not contain any hashes"
        fi
        exclude_list=$((tr -s ";;" ";" | \
                        sed -e "s/^;*//" \
                            -e "s/;*$//" \
                            -e "s/\ /#/g" \
                            -e "s/;/\n/g") <<< "$exclude_pattern")
        exclude=1
    fi

    # Remove pattern
    if [ $interactive -eq 1 ]; then
        dialog_remove_pattern "$remove_pattern"
        remove_pattern="$user_input"
    fi

    if [ ! -z "$remove_pattern" ]; then
        if [[ $remove_pattern == *"#"* ]]; then
            usage "The remove pattern must not contain any hashes"
        fi
        remove_list=$((tr -s ";;" ";" | \
                       sed -e "s/^;*//" \
                           -e "s/;*$//" \
                           -e "s/\ /#/g" \
                           -e "s/;/\n/g") <<< "$remove_pattern")
        remove=1
    fi

    # Head and tail
    if [ $interactive -eq 1 ]; then
        if [ $follow -eq 0 ]; then
            if [ "$head_lines" = "0" ]; then
                dialog_head_lines ""
            else
                dialog_head_lines "$head_lines"
            fi
            if [ -z "$user_input" ]; then
                head_lines=0
            else
                head_lines="$user_input"
            fi
        fi
        if [ $head_lines -eq 0 ]; then
            if [ "$tail_lines" = "0" ]; then
                dialog_tail_lines ""
            else
                dialog_tail_lines "$tail_lines"
            fi
            if [ -z "$user_input" ]; then
                tail_lines=0
            else
                tail_lines="$user_input"
            fi
        fi
    fi

    input_count=$(wc -w <<< "$input_file")
    if [ -z "$head_lines" ]; then
        head_lines=0
    else
        re='^[0-9]+$'
        if [[ ! $head_lines =~ $re ]]; then
            usage "The argument '--head' expects a numeric value"
        fi
        if [[ ! $tail_lines =~ $re ]]; then
            usage "The argument '--tail' expects a numeric value"
        fi
        if [ $head_lines -gt 0 ] && [ $follow = 1 ]; then
            usage "The '--head' argument cannot be used with monitoring mode"
        fi
        if [ $head_lines -gt 0 ] && [ $tail_lines -gt 0 ]; then
            usage "Use either '--head' or '--tail', not both at the same time"
        elif [ $head_lines -gt 0 ] || [ $tail_lines -gt 0 ]; then
            if [ $input_count -gt 1 ]; then
               temp="'--head' or '--tail'"
               usage \
                   "When using $temp only one input file can be given"
            fi
        fi
    fi

    # Pause output
    if [ $interactive -eq 1 ]; then
        if [ "$pause_lines" = "0" ]; then
            dialog_pause_output ""
        else
            dialog_pause_output "$pause_lines"
        fi
        pause_lines="$user_input"
        if [ -z "$pause_lines" ]; then
            pause=0
        else
            pause=1
        fi
    fi

    if [ $pause -eq 1 ] && [ $follow -eq 1 ]; then
        usage "The '--pause' argument cannot be used with monitoring mode"
    fi
    if [ -z "$pause_lines" ] && [ $pause -eq 1 ]; then
        expects="expects a positive numeric value or 'auto'"
        usage "The '--pause' argument $expects"
    elif [ "$pause_lines" = "auto" ]; then
        pause=1
    else
        if [ $pause -eq 1 ]; then
            re='^[0-9]+$'
            if [ $pause_lines -lt 1 ] || [[ ! $pause_lines =~ $re ]]; then
                expects="expects a positive numeric value or 'auto'"
                usage "The '--pause' argument $expects"
            fi
        fi
    fi

    # Export file
    if [ $interactive -eq 1 ]; then
        dialog_export_file $export_file
        export_file="$user_input"
        export_log=1
    fi

    if [ $export_log -eq 1 ]; then
        temp="The given export file path '$export_file'"
        if [ -z "$export_file" ]; then
            export_log=0
        else
            if [ -e "$export_file" ]; then
                if [ -d "$export_file" ]; then
                    usage "$temp is not a file"
                elif [ -f "$export_file" ]; then
                    usage "$temp already exists"
                fi
            fi

            touch $export_file &>/dev/null
            if [ $? -ne 0 ]; then
                usage "$temp seems to be read-only"
            fi
        fi
    fi

    # Slow down (delay)
    if [ $interactive -eq 1 ]; then
        dialog_slow_down "$slow"
        if [ $? -eq 0 ]; then
            slow=1
            dialog_delay "$delay"
            delay="$user_input"
        fi
    fi

    grep -E "^[0-9]*$" <<< "$delay" &>/dev/null
    if [ $? -eq 0 ]; then
        temp=$delay
        if [ $delay -lt 100 ]; then
            temp=100
        elif [ $delay -gt 900 ]; then
            temp=900
        fi
        delay=$temp
    else
        usage "The delay must be an integer between 100 and 900"
    fi

    # Wait on match
    if [ $interactive -eq 1 ]; then
        if [ "$wait_match" = "0" ]; then
            dialog_wait_on_match
        else
            dialog_wait_on_match "$wait_match"
        fi

        wait_match="$user_input"
        if [ -z "$wait_match" ]; then
            wait_match=0
        fi
    fi

    if [ -z "$wait_match" ]; then
        usage "The wait value must not be empty"
    else
        grep -E "^[0-9]*$" <<< "$wait_match" &>/dev/null
        if [ $? -eq 0 ]; then
            if [ $wait_match -lt 0 ]; then
                wait=0
            fi
        else
            usage "The wait value must be an integer greater than zero"
        fi
    fi

    # Information header and footer
    if [ $interactive -eq 1 ]; then
        dialog_no_info $header
        if [ $? -eq 0 ]; then
            header=1
        else
            header=0
        fi
    fi

    # Check requirements
    check_command grep 0 grep
    check_command sed 0 sed
    check_command tail 0 coreutils
fi

# Prepare output first
if [ $interactive -eq 1 ]; then
    clear
fi

if [ $header -eq 1 ]; then
    print_output_header
fi

# Finally, process the given input file
if [ $follow -eq 1 ]; then
    monitor_input_file
else
    analyze_input_file
fi

# EOF
