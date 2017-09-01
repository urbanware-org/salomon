#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Main script
# Copyright (C) 2017 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# Website: http://www.urbanware.org
# GitHub: https://github.com/urbanware-org/salomon
# ============================================================================

# Check if the Bash shell is installed
bash --version >/dev/null 2>&1
if [ "$?" != "0" ]; then
    echo "error: The Bash shell does not seem to be installed, run the"\
         "'compat.sh'"
    echo "       script for details."
    exit 1
fi

script_dir=$(dirname $(readlink -f $0))
script_file=$(basename "$0")

source ${script_dir}/core/analyze.sh
source ${script_dir}/core/colors.sh
source ${script_dir}/core/common.sh
source ${script_dir}/core/dialogs.sh
source ${script_dir}/core/global.sh
source ${script_dir}/core/monitor.sh
source ${script_dir}/core/output.sh
declare -A "colorize_"
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
                input_file="$1"
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
            --cut-off)
                highlight_cut_off=1
                shift
            ;;
            -d|--delay)
                shift
                delay="$1"
                shift
            ;;
            -e|--exclude)
                shift
                exclude_pattern="$1"
                shift
            ;;
            -f|--filter)
                shift
                filter_pattern="$1"
                shift
            ;;
            -h|--help)
                usage
            ;;
            --highlight)
                highlight=1
                shift
            ;;
            --highlight-all)
                highlight_all=1
                shift
            ;;
            --highlight-upper)
                highlight_upper=1
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
            -r|--remove)
                shift
                remove_pattern="$1"
                shift
            ;;
            -s|--slow)
                slow=1
                shift
            ;;
            --start-line)
                shift
                start_line="$1"
                shift
            ;;
            -t|--temp-copy)
                copy=1
                shift
            ;;
            --version)
                echo "$version"
                exit
            ;;
            -w|--wait)
                shift
                wait_match="$1"
                shift
            ;;

            # Backwards compatibility arguments (still existing, but no longer
            # listed inside the usage information)
            --config-file)
                shift
                color_file="$1"
                check_argument "-c/--config-file" "$color_file" "file"
                shift
            ;;
            -n|--no-follow)
                follow=0
                shift
            ;;
            --no-header)
                header=0
                shift
            ;;

            # Unrecognized arguments
            *)
                usage "The given argument '$1' is unrecognized"
            ;;
        esac
    done

    if [ $interactive -eq 1 ]; then
        dialog --help &>/dev/null
        if [ $? -ne 0 ]; then
            interactive=0
            usage "The interactive mode requires the tool 'dialog' to work"
        fi
        predef_notice_dialog
    fi

    # Input file
    if [ -z "$input_file" ] && [ $interactive -eq 1 ]; then
        dialog_input_file
        input_file=$user_input
    fi
    if [ -z "$input_file" ]; then
        usage "No input file given"
    elif [ ! -e "$input_file" ]; then
        usage "The given input file does not exist"
    elif [ ! -f "$input_file" ]; then
        usage "The given input file path is not a file"
    fi

    # Action (processing mode)
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
        if [ $interactive -eq 1 ]; then
            dialog_action
            follow=$?
        fi
    fi

    # Filter pattern
    if [ -z "$filter_pattern" ] && [ $interactive -eq 1 ]; then
        dialog_filter
        filter_pattern=$user_input
    fi
    if [ -z "$filter_pattern" ]; then
        if [ "$arg_case" = "-i" ]; then
            usage \
                "The '--ignore-case' argument can only be used with a filter"
        fi
        if [ $highlight -eq 1 ] || [ $highlight_upper -eq 1 ]; then
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
            grep "#" <<< "$filter_pattern" &>/dev/null
            if [ $? -eq 0 ]; then
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

    # Exclude pattern
    if [ -z "$exclude_pattern" ] && [ $interactive -eq 1 ]; then
        dialog_exclude
        exclude_pattern=$user_input
    fi
    if [ ! -z "$exclude_pattern" ]; then
        grep "#" <<< "$exclude_pattern" &>/dev/null
        if [ $? -eq 0 ]; then
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
    if [ -z "$remove_pattern" ] && [ $interactive -eq 1 ]; then
        dialog_remove
        remove_pattern=$user_input
    fi
    if [ ! -z "$remove_pattern" ]; then
        grep "#" <<< "$remove_pattern" &>/dev/null
        if [ $? -eq 0 ]; then
            usage "The remove pattern must not contain any hashes"
        fi
        remove_list=$((tr -s ";;" ";" | \
                       sed -e "s/^;*//" \
                           -e "s/;*$//" \
                           -e "s/\ /#/g" \
                           -e "s/;/\n/g") <<< "$remove_pattern")
        remove=1
    fi

    # Highlighting
    highlight_params=$(( highlight + highlight_all + highlight_upper ))
    if [ $highlight_params -gt 1 ]; then
        usage \
            "Multiple highlighting arguments given (only one allowed)"
    else
        if [ $interactive -eq 1 ]; then
            dialog_highlight
            if [ $user_input -eq 2 ]; then
                highlight_all=1
            elif [ $user_input -eq 3 ]; then
                highlight_all=1
                highlight_cut_off=1
            elif [ $user_input -eq 4 ]; then
                highlight=1
            elif [ $user_input -eq 5 ]; then
                highlight_upper=1
            fi

            if [ $user_input -ge 2 ]; then
                dialog_color_file
                color_file=$user_input
                # FIXME: Check if file exists (also in non-interactive mode)
            fi
        fi
    fi
    if [ $highlight_all -eq 0 ] && [ $highlight_cut_off -eq 1 ]; then
        usage \
            "The '--cut-off' argument can only be used with '--highlight-all'"
    fi



    # FIXME: Further arguments... ----------------------



    if [ -z "$wait_match" ]; then
        usage "The wait value must not be empty"
    else
        grep -E "^[0-9]*$" <<< "$wait_match" &>/dev/null
        if [ $? -eq 0 ]; then
            if [ $wait_match -lt 0 ]; then
                wait=0
            fi
        else
            usage "The wait value must be a number greater than zero"
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
        usage "The delay must be a number between 100 and 900"
    fi


    if [ $follow -eq 0 ] && [ $prompt -eq 1 ]; then
        usage "The analyzing mode does not support a prompt before exit"
    fi

    if [ $follow -eq 1 ] && [ $copy -eq 1 ]; then
        usage "A temporary copy only makes sense when analyzing a file"
    fi


    # --------------------------

    # FIXME: Final checks
    check_command grep 0 grep
    check_command sed 0 sed
    check_command tail 0 coreutils

fi

# Process the given input file
if [ $header -eq 1 ]; then
    print_output_header
fi

if [ $follow -eq 1 ]; then
    monitor_input_file
else
    analyze_input_file
fi

# EOF

