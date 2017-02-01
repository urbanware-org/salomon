#!/bin/bash

# ============================================================================
# Project:      SaLoMon
# File:         Main script
# Copyright:    Copyright (C) 2017 by Ralf Kilian
# License:      Distributed under the MIT License
# ----------------------------------------------------------------------------
# Website:      http://www.urbanware.org
# GitHub:       https://github.com/urbanware-org/salomon
# ============================================================================

# Check if the Bash shell is installed
bash --version >/dev/null 2>&1
if [ $? != 0 ]; then
    echo
    echo "error: The Bash shell does not seem to be installed, run the"\
         "'compat.sh'"
    echo "       script for details."
    echo
    exit
fi

script_dir=$(dirname $(readlink -f $0))
script_file=$(basename "$0")

source ${script_dir}/core/analyze.sh
source ${script_dir}/core/colors.sh
source ${script_dir}/core/common.sh
source ${script_dir}/core/global.sh
source ${script_dir}/core/monitor.sh
source ${script_dir}/core/output.sh
declare -A "colorize_"
set_global_variables
shell_precheck

# Check command-line arguments
if [ $# = 0 ]; then
    usage "At least one required argument is missing."
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
            --highlight-upper)
                highlight_upper=1
                shift
            ;;
            --ignore-case)
                arg_case="-i"
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
            -t|--temp-copy)
                copy=1
                shift
            ;;
            --version)
                echo "$script_version"
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
                usage "The given argument '$1' is unrecognized."
            ;;
        esac
    done

    if [ ! -z "$action" ]; then
        if [ "$action" = "analyze" ]; then
            follow=0
        elif [ "$action" = "monitor" ]; then
            if [ "$follow" = 0 ]; then
                usage "Argument conflict (different actions given)."
            fi
        else
            usage "The action '$action' does not exist."
        fi
    fi

    if [ $follow = 0 ] && [ $prompt = 1 ]; then
        usage "The analyzing mode does not support a prompt before exit."
    fi

    if [ $follow = 1 ] && [ $copy = 1 ]; then
        usage "A temporary copy only makes sense when analyzing a file."
    fi

    if [ -z "$input_file" ]; then
        usage "No input file given."
    elif [ ! -e "$input_file" ]; then
        usage "The given input file does not exist."
    elif [ ! -f "$input_file" ]; then
        usage "The given input file path is not a file."
    fi

    if [ ! -z "$color_file" ]; then
        if [ ! -e "$color_file" ]; then
            color_file="${color_dir}${color_file}"
            if [ ! -e "$color_file" ]; then
                usage "The given color config file does not exist."
            fi
        fi
        if [ ! -f "$color_file" ]; then
            usage "The given color config file path is not a file."
        else
            read_colors "$color_file"
        fi
    fi

    if [ -z "$filter_pattern" ]; then
        if [ "$arg_case" = "-i" ]; then
            usage \
                "The '--ignore-case' argument can only be used with a filter."
        fi
        if [ $highlight = 1 ] || [ $highlight_upper = 1 ]; then
            usage \
                "The '--highlight' arguments can only be used with a filter."
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
            if [ $? = 0 ]; then
                usage "The filter pattern must not contain any hashes."
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
    grep -E "^[0-9]*$" <<< "$delay" &>/dev/null
    if [ $? = 0 ]; then
        temp=$delay
        if [ $delay -lt 100 ]; then
            temp=100
        elif [ $delay -gt 900 ]; then
            temp=900
        fi
        delay=$temp
    else
        usage "The delay must be a number between 100 and 900."
    fi
    if [ ! -z "$exclude_pattern" ]; then
        grep "#" <<< "$exclude_pattern" &>/dev/null
        if [ $? = 0 ]; then
            usage "The exclude pattern must not contain any hashes."
        fi
        exclude_list=$((tr -s ";;" ";" | \
                        sed -e "s/^;*//" \
                            -e "s/;*$//" \
                            -e "s/\ /#/g" \
                            -e "s/;/\n/g") <<< "$exclude_pattern")
        exclude=1
    fi
    if [ ! -z "$remove_pattern" ]; then
        grep "#" <<< "$remove_pattern" &>/dev/null
        if [ $? = 0 ]; then
            usage "The remove pattern must not contain any hashes."
        fi
        remove_list=$((tr -s ";;" ";" | \
                       sed -e "s/^;*//" \
                           -e "s/;*$//" \
                           -e "s/\ /#/g" \
                           -e "s/;/\n/g") <<< "$remove_pattern")
        remove=1
    fi
    if [ -z "$wait_match" ]; then
        usage "The wait value must not be empty."
    else
        grep -E "^[0-9]*$" <<< "$wait_match" &>/dev/null
        if [ $? = 0 ]; then
            if [ $wait_match -lt 0 ]; then
                wait=0
            fi
        else
            usage "The wait value must be a number greater than zero."
        fi
    fi
    check_command grep 0 grep
    check_command sed 0 sed
    check_command tail 0 coreutils
fi

# Process the given input file
if [ $header = 1 ]; then
    print_output_header
fi

if [ $follow = 1 ]; then
    monitor_input_file
else
    analyze_input_file
fi

# EOF

