#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Common core script
# Copyright (C) 2018 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
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
        trap - 2 20
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
        usage "The argument '$arg_name' expects a $arg_expect"
    fi
}

check_command() {
    check_command=$1
    expected_code=$2
    required_pkg=$3

    $check_command --help &>/dev/null
    if [ $? -ne $expected_code ]; then
        usage "This script requires the '$required_pkg' package to work"
    fi
}

check_patterns() {
    if [ ! -z "$filter_list" ]; then
        for filter_term in $filter_list; do
            term=$(sed -e "s/#/\ /g" <<< "$filter_term")
            term_upper=$(tr '[:lower:]' '[:upper:]' <<< "$term")
            if [ ! -z "$exclude_list" ]; then
                for string in $exclude_list; do
                    temp=$(sed -e "s/#/\ /g" <<< "$string")
                    string_upper=$(tr '[:lower:]' '[:upper:]' <<< "$temp")
                    if [ "$term_upper" = "$string_upper" ]; then
                        usage "Exclude list must not contain a filter term"
                    fi
                done
            fi
            if [ ! -z "$remove_list" ]; then
                for string in $remove_list; do
                    temp=$(sed -e "s/#/\ /g" <<< "$string")
                    string_upper=$(tr '[:lower:]' '[:upper:]' <<< "$temp")
                    if [ "$term_upper" = "$string_upper" ]; then
                        usage "Remove list must not contain a filter term"
                    fi
                done
            fi
        done
    fi
}

check_update() {
    link_latest="https://github.com/urbanware-org/salomon/releases/latest"
    temp_file="$(dirname $(mktemp -u))/salomon_$$.tmp"

    wget -q $link_latest -O $temp_file
    if [ $? -ne 0 ]; then
        rm -f $temp_file
        usage "Unable to retrieve update information"
    else
        version_latest=$(grep "css-truncate-target" $temp_file |
                         sed -e "s/<\/.*//g" | sed -e "s/.*>//g")
        rm -f $temp_file
    fi

    echo
    if [ "$version" = "$version_latest" ]; then
        echo "This version of SaLoMon is up-to-date."
    else
        echo "There is a newer version of SaLoMon available."
        echo
        echo "For details see: $link_latest"
    fi
    echo

    exit
}

deprecated_argument() {
    arg_given="$1"
    arg_instead="$2"

    dep="The argument '\e[1;36m$arg_given\e[0m' is \e[1;33mdeprecated\e[0m."
    ins="You may use '\e[1;36m$arg_instead\e[0m' instead."

    echo -e "\e[1;34mnotice\e[0m: $dep $ins"
    sleep 1
}

prepare_path() {
    path_input="$1"
    while true; do
        grep "//" <<< $path_input &>/dev/null
        if [ $? -ne 0 ]; then
            break
        fi
        
        temp=$(sed -e "s/\/\//\//g" <<< $path_input)
        path_input=$temp
    done
    path_prepared=$(sed -e "s/^ *//g;s/ *$//g;s/\ /\/\//g" <<< $path_input)
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
        usage "The filter pattern must not contain any hashes"
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

    if [ "$usage_color" = "1" ]; then
        no=$color_none
        lb=$color_lightblue
        lc=$color_lightcyan
        lg=$color_lightgreen
        lr=$color_lightred
        yl=$color_yellow
    else
        no=$color_none
        lb=$color_none
        lc=$color_none
        lg=$color_none
        lr=$color_none
        yl=$color_none
    fi

    echo -e "${lc}usage: ${yl}$script_file -a {analyze,monitor} -i"\
                              "INPUT_FILE [-c COLOR_FILE]"
    echo -e "                  [-d DELAY] [-e EXCLUDE] [-f FILTER]"\
                              "[--highlight-all]"
    echo -e "                  [--highlight-matches] [--highlight-upper]"\
                              "[--ignore-case]"
    echo -e "                  [--no-info] [-p] [-r REMOVE] [-s] [--version]"\
                              "[-w WAIT]"
    echo
    echo -e "${lg}Monitor and analyze log and plain text files with various"\
            "filter and"
    echo -e "${lg}highlighting features."
    echo
    echo -e "${lr}required arguments:${no}"
    echo "  -a {analyze,monitor}, --action {analyze,monitor}"
    echo "                        action (processing mode) to perform with"\
                                 "the given"
    echo "                        input file(s)"
    echo "  -i INPUT_FILE, --input-file INPUT_FILE"
    echo "                        input file to analyze or monitor (can be"\
                                 "given"
    echo "                        multiple times)"
    echo
    echo -e "${lb}optional arguments:${no}"
    echo "  -c COLOR_FILE, --color-file COLOR_FILE"
    echo "                        color config file for colorizing lines"\
                                 "which contain"
    echo "                        certain terms"
    echo "  --color-table         print the 256-color table to see which"\
                                 "colors are"
    echo "                        supported (can be displayed) by the"\
                                 "terminal emulator"
    echo "                        currently used and exit"
    echo "  --cut-off             remove the trailing whitespaces used to"\
                                 "fill the line"
    echo "                        when using '--highlight-all'"
    echo "  -d, --delay DELAY     delay for the '--slow' argument below"\
                                 "(milliseconds,"
    echo "                        integer between 100 and 900, default is"\
                                 "$delay)"
    echo "  --dialogs             use interactive dialogs (for details see"\
                                 "section 2.6"
    echo "                        inside the documentation)"
    echo "  -e EXCLUDE, --exclude EXCLUDE"
    echo "                        exclude lines which a certain string (for"\
                                 "details see"
    echo "                        section 5 inside the documentation file)"
    echo "  --export-file EXPORT_FILE"
    echo "                        simultaneously export the output into a file"\
                                 "(for"
    echo "                        details see section 7 inside the"\
                                 "documentation file)"
    echo "  -f FILTER, --filter FILTER"
    echo "                        print the lines that contain the given"\
                                 "filter pattern,"
    echo "                        only (for details see section 4 inside the"
    echo "                        documentation file)"
    echo "  -ha, --highlight-all  highlight the whole lines by inverting"\
                                 "their color (no"
    echo "                        filter required)"
    echo "  -hm, --highlight-matches"
    echo "                        highlight the filter matches by inverting"\
                                 "their colors"
    echo "  -hu, --highlight-upper"
    echo "                        same as '--highlight-matches' and with"\
                                 "to uppercase"
    echo "                        converted letters"
    echo "  --ignore-case         ignore the case of the given filter pattern"
    echo "  --interactive         same as '--dialogs'"
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
    echo "  --version             print the version number and exit"
    echo "  --version-update      check for a newer version"
    echo "  -w, --wait WAIT       seconds to wait after printing a colorized"\
                                 "line"
    echo "  -?, -h, --help        print this help message and exit"
    echo
    echo -e "${yl}Further information and usage examples can be found inside"\
            "the documentation"
    echo -e "file for this script.${no}"
        if [ ! -z "$error_msg" ]; then
        if [ $interactive -eq 1 ] && [ ! -z $dialog_program ]; then
            predef_error_dialog "$error_msg"
            clear
        else
            echo
            echo -e "\e[1;31merror\e[0m: $error_msg."
        fi
        exit 1
    else
        exit 0
    fi
}

# EOF
