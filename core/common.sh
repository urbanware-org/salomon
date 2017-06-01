#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Common core script
# Copyright (C) 2017 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# Website: http://www.urbanware.org
# GitHub: https://github.com/urbanware-org/salomon
# ============================================================================

cancel_process() {
    echo
    print_line "*"
    temp="${color_lightred}Canceled ${color_lightgray}on"
    print_line "${temp}${color_lightcyan} user request${color_lightgray}."

    if [ $follow -eq 0 ]; then
        print_line
        print_line_count
    fi
    if [ $prompt -eq 1 ]; then
        print_line
        print_line "${color_lightgray}Press any key to exit."
        print_line "*"
        read -n1 -r
    else
        print_line "*"
        echo
    fi

    rm -f $temp_file
    exit 2
}

check_argument() {
    arg_name=$1
    arg_value=$2
    arg_expect=$3

    grep "^-" <<< "$arg_value" &>/dev/null
    if [ $? -eq 0 ]; then
        usage "The argument '$arg_name' expects a $arg_expect."
    fi
}

check_command() {
    check_command=$1
    expected_code=$2
    required_pkg=$3

    $check_command --help &>/dev/null
    if [ $? != $expected_code ]; then
        usage "This script requires the '$required_pkg' package to work."
    fi
}

check_patterns() {
    if [ ! -z "$filter_list" ]; then
        for filter_term in $(echo "$filter_list"); do
            term=$(sed -e "s/#/\ /g" <<< "$filter_term")
            term_upper=$(tr '[:lower:]' '[:upper:]' <<< "$term")
            if [ ! -z "$exclude_list" ]; then
                for string in $(echo "$exclude_list"); do
                    temp=$(sed -e "s/#/\ /g" <<< "$string")
                    string_upper=$(tr '[:lower:]' '[:upper:]' <<< "$temp")
                    if [ "$term_upper" = "$string_upper" ]; then
                        usage "Exclude list must not contain a filter term."
                    fi
                done
            fi
            if [ ! -z "$remove_list" ]; then
                for string in $(echo "$remove_list"); do
                    temp=$(sed -e "s/#/\ /g" <<< "$string")
                    string_upper=$(tr '[:lower:]' '[:upper:]' <<< "$temp")
                    if [ "$term_upper" = "$string_upper" ]; then
                        usage "Remove list must not contain a filter term."
                    fi
                done
            fi
        done
    fi
}

shell_precheck() {
    precheck=$(echo -e "precheck" | grep "\-e")
    if [ $? -eq 0 ]; then
        color_none=""
        color_black=""
        color_brown=""
        color_darkblue=""
        color_darkcyan=""
        color_darkgray=""
        color_darkgreen=""
        color_darkpurple=""
        color_darkred=""
        color_lightblue=""
        color_lightcyan=""
        color_lightgray=""
        color_lightgreen=""
        color_lightpurple=""
        color_lightred=""
        color_white=""
        color_yellow=""
        bs=""
        ce=""
        em=""
    fi
}

read_filter() {
    (grep -v "^#" | grep "#") < "$filter_file" &>/dev/null
    if [ $? -eq 0 ]; then
        usage "The filter pattern must not contain any hashes."
    fi

    filter_pattern=""
    (grep -v "#" | sed -e "s/\ /#/g") < "$filter_file" > $temp_file
    while read line; do
        temp="$filter_pattern;$line"
        filter_pattern="$temp"
    done < $temp_file
    rm -f $temp_file
}

usage() {
    error_msg=$1

    echo "usage: $script_file -a {analyze,monitor} -i INPUT_FILE"\
                           "[-c COLOR_FILE]"
    echo "                  [-d DELAY] [-e EXCLUDE] [-f FILTER] [-h]"\
                           "[--highlight]"
    echo "                  [--ignore-case] [--no-info] [-p] [-r REMOVE]"
    echo "                  [-s] [--version] [-w WAIT]"
    echo
    echo "Monitor and analyze log and plain text files with various filter"\
         "and highlighting features."
    echo
    echo "required arguments:"
    echo "  -a {analyze,monitor}, --action {analyze,monitor}"
    echo "                        action to perform with the input file"
    echo "  -i INPUT_FILE, --input-file INPUT_FILE"
    echo "                        input file to monitor"
    echo
    echo "optional arguments:"
    echo "  -c COLOR_FILE, --color-file COLOR_FILE"
    echo "                        color config file for colorizing lines"\
                                 "which contain"
    echo "                        certain terms"
    echo "  -d, --delay DELAY     delay for the '--slow' argument below"\
                                 "(milliseconds,"
    echo "                        number between 100 and 900, default is 200)"
    echo "  -e EXCLUDE, --exclude EXCLUDE"
    echo "                        exclude lines which a certain string (for"\
                                 "details see"
    echo "                        section 5 inside the documentation file)"
    echo "  -f FILTER, --filter FILTER"
    echo "                        print the lines that contain the given"\
                                 "filter pattern,"
    echo "                        only (for details see section 4 inside the"
    echo "                        documentation file)"
    echo "  -h, --help            print this help message and exit"
    echo "  --highlight           highlight the filter terms by inverting"\
                                 "their colors"
    echo "  --highlight-all       highlight the whole lines by inverting"\
                                 "their color (no filter required)"
    echo "  --highlight-upper     same as '--highlight', but with uppercase"\
                                 "letters (also reuqires a filter)"
    echo "  --ignore-case         ignore the case of the given filter pattern"
    echo "  --no-info             do not display the information header and"\
                                 "footer"
    echo "  -p, --prompt          prompt before exit (in case the process"\
                                 "gets canceled"
    echo "                        on user request)"
    echo "  -r REMOVE, --remove REMOVE"
    echo "                        remove a certain string from each line"\
                                 "(for details"
    echo "                        see section 6 inside the documentation"\
                                 "file)"
    echo "  -s, --slow            slow down the process (decreases CPU"\
                                 "usage)"
    echo "  -t, --temp-copy       process temporary copy of the input file"\
                                 "instead of"
    echo "                        the input file itself"
    echo "  --version             print the version number and exit"
    echo "  -w, --wait WAIT       seconds to wait after printing a colorized"\
                                 "line"
    echo
    echo "Further information and usage examples can be found inside the"\
         "documentation"
    echo "file for this script."
    if [ ! -z "$error_msg" ]; then
        echo
        echo "error: $error_msg"
        exit 1
    else
        exit 0
    fi
}

# EOF

