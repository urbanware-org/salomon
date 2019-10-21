#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Main script
# Copyright (C) 2019 by Ralf Kilian
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
source ${script_dir}/core/interactive.sh
source ${script_dir}/core/monitor.sh
source ${script_dir}/core/output.sh

# Script files stored inside the 'debug' sub-directory (if existing) will be
# loaded after the included ones listed above. This allows to overwrite
# existing functions from scripts inside the 'core' sub-directory without
# manipulating them
if [ -d "${script_dir}/debug" ]; then
    source ${script_dir}/debug/*.sh &>/dev/null
fi

if [ -f "${script_dir}/salomon.cfg" ]; then
    source ${script_dir}/salomon.cfg
elif [ -f "${script_dir}/salomon.conf" ]; then
    source ${script_dir}/salomon.conf
elif [ -f "${script_dir}/salomon.cf" ]; then
    # Postfix anyone?
    source ${script_dir}/salomon.cf
else
    usage "Global configuration file missing"
fi
set_global_variables

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
            --force-dark)
                color_force="dark"
                shift
            ;;
            --force-light)
                color_force="light"
                shift
            ;;
            -h|--head)
                shift
                head_lines="$1"
                shift
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
            -ic|--ignore-case)
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
            -t|--tail)
                shift
                tail_lines="$1"
                shift
            ;;
            -w|--wait)
                shift
                wait_match="$1"
                shift
            ;;

            # General arguments
            --color-table)
                color_table=1
                shift
            ;;
            --version)
                echo "$version"
                exit
            ;;
            --version-update)
                check_update
            ;;
            -\?|--help)
                usage
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
        interactive_mode
    else
        # Input file
        temp=$(sed -e "s/^ *//g;s/ *$//g" <<< "$input_file")
        input_file="$temp"

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
            usage \
              "No action given (must either be '--analyze' or '--monitor')"
        fi

        # Color file
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
        if [ -z "$filter_pattern" ]; then
            msg="can only be used with"
            if [ "$arg_case" = "-i" ]; then
                usage "The '--ignore-case' argument $msg a filter"
            fi
            if [ $highlight_matches -eq 1 ] || [ $highlight_upper -eq 1 ]; then
                usage "This highlighting argument $msg a filter"
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
        highlight_params=$((
            highlight_all + highlight_matches + highlight_upper ))

        if [ $highlight_params -gt 1 ]; then
            usage "Multiple highlighting arguments given (only one allowed)"
        fi

        if [ $highlight_all -eq 0 ] && [ $highlight_cut_off -eq 1 ]; then
            msg="can only be used with"
            usage "The '--cut-off' argument $msg '--highlight-all'"
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

        # Exclude pattern
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
            concat_arg "-e $exclude_pattern"
        fi

        # Remove pattern
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
            concat_arg "-r $remove_pattern"
        fi

        # Head and tail
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
                usage \
                  "The '--head' argument cannot be used with monitoring mode"
            fi
            if [ $head_lines -gt 0 ] && [ $tail_lines -gt 0 ]; then
                usage \
                  "Use either '--head' or '--tail', not both at the same time"
            elif [ $head_lines -gt 0 ] || [ $tail_lines -gt 0 ]; then
                if [ $input_count -gt 1 ]; then
                   temp="'--head' or '--tail'"
                   usage "When using $temp only one input file can be given"
                fi
            fi
        fi

        # Pause output
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

                concat_arg "--export-file $export_file"
            fi
        fi

        # Slow down (delay)
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

        # Wait on match
        if [ -z "$wait_match" ]; then
            usage "The wait value must not be empty"
        else
            grep -E "^[0-9]*$" <<< "$wait_match" &>/dev/null
            if [ $? -eq 0 ]; then
                if [ $wait_match -le 0 ]; then
                    wait=0
                else
                    concat_arg "-w $wait_match"
                fi
            else
                usage "The wait value must be a number greater than zero"
            fi
        fi
    fi

    # Force dark/light text colors
    if [ "$color_force" = "dark" ]; then
        color_lightblue=$cl_db            ; cl_lb=$color_lightblue
        color_lightcyan=$cl_dc            ; cl_lc=$color_lightcyan
        color_lightgray=$cl_dy            ; cl_ly=$color_lightgray
        color_lightgreen=$cl_dg           ; cl_lg=$color_lightgreen
        color_lightpurple=$cl_dp          ; cl_lp=$color_lightpurple
        color_lightred=$cl_dr             ; cl_lr=$color_lightred
        color_white=$cl_bk                ; cl_wh=$color_white
        color_yellow=$cl_br               ; cl_yl=$color_yellow
    elif [ "$color_force" = "light" ]; then
        color_black=$cl_wh                ; cl_bk=$color_black
        color_brown=$cl_yl                ; cl_br=$color_brown
        color_darkblue=$cl_lb             ; cl_db=$color_darkblue
        color_darkcyan=$cl_dc             ; cl_dc=$color_darkcyan
        color_darkgray=$cl_ly             ; cl_dy=$color_darkgray
        color_darkgreen=$cl_lg            ; cl_dg=$color_darkgreen
        color_darkpurple=$cl_lp           ; cl_dp=$color_darkpurple
        color_darkred=$cl_lr              ; cl_dr=$color_darkred
    fi
fi

# Check requirements
check_command grep grep
check_command sed sed
check_command tail coreutils

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
