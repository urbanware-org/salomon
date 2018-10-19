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
    temp="${cl_lr}Canceled ${cl_ly}on"
    print_line "${temp}${cl_lc} user request${cl_ly}."

    if [ $follow -eq 0 ]; then
        print_line
        print_line_count
    fi
    if [ $prompt -eq 1 ]; then
        trap - 2 20
        print_line
        print_line "${cl_ly}Press any key to exit."
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
        temp=$(grep "css-truncate-target" $temp_file |
               sed -e "s/<\/.*//g" | sed -e "s/.*>//g ")
        version_latest=$(echo $temp | awk '{ print $1 }')
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
    arg_g="$1"
    arg_i="$2"

    dep="The argument '${cl_lc}${arg_g}${cl_n}' is ${cl_yl}deprecated${cl_n}."
    ins="You may use '${cl_lc}${arg_i}${cl_n}' instead."

    echo -e "${cl_lb}notice${cl_n}: $dep $ins"
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
        color_none=""                 ; cl_n=$color_none
        color_black=""                ; cl_bk=$color_black
        color_brown=""                ; cl_br=$color_brown
        color_darkblue=""             ; cl_db=$color_darkblue
        color_darkcyan=""             ; cl_dc=$color_darkcyan
        color_darkgray=""             ; cl_dy=$color_darkgray
        color_darkgreen=""            ; cl_dg=$color_darkgreen
        color_darkpurple=""           ; cl_dp=$color_darkpurple
        color_darkred=""              ; cl_dr=$color_darkred
        color_lightblue=""            ; cl_lb=$color_lightblue
        color_lightcyan=""            ; cl_lc=$color_lightcyan
        color_lightgray=""            ; cl_ly=$color_lightgray
        color_lightgreen=""           ; cl_lg=$color_lightgreen
        color_lightpurple=""          ; cl_lp=$color_lightpurple
        color_lightred=""             ; cl_lr=$color_lightred
        color_white=""                ; cl_wh=$color_white
        color_yellow=""               ; cl_yl=$color_yellow
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
        no=$cl_n
        lb=$cl_lb
        lc=$cl_lc
        lg=$cl_lg
        lr=$cl_lr
        yl=$cl_yl
    else
        no=$cl_n
        lb=$cl_n
        lc=$cl_n
        lg=$cl_n
        lr=$cl_n
        yl=$cl_n
    fi

    echo -e "${lc}usage: ${no}$script_file -a {analyze,monitor} -i"\
                              "INPUT_FILE [-c COLOR_FILE]"
    echo -e "                  [--cut-off] [-d DELAY] [--dialogs]"\
                              "[-e EXCLUDE]"
    echo -e "                  [--export-file EXPORT_FILE] [-f FILTER]"\
                              "[--head HEAD]"
    echo -e "                  [--highlight-all] [--highlight-matches]"\
                              "[--highlight-upper]"
    echo -e "                  [--ignore-case] [--no-info] [-p]"\
                              "[--pause PAUSE] [-r REMOVE]"
    echo -e "                  [-s] [--tail TAIL] [--version] [-w WAIT]"
    echo
    echo -e "${lg}Monitor and analyze log and plain text files with various"\
            "filter and"
    echo -e "${lg}highlighting features."
    echo
    echo -e "${lr}required arguments:${no}"
    echo "  -a {analyze,monitor}, --action {analyze,monitor}"
    echo "                        action (processing mode) to perform with"\
                                 "the given"
    echo "                        input file(s) (this can also be given via"\
                                 "'--analyze'"
    echo "                        or '--monitor' instead)"
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
    echo "                        simultaneously export the output into a"\
                                 "file (for"
    echo "                        details see section 9 inside the"\
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
    echo "  --head HEAD           only return the given number of first"\
                                 "lines of the"
    echo "                        input file"
    echo "  --ignore-case         ignore the case of the given filter pattern"
    echo "  --interactive         same as '--dialogs'"
    echo "  --no-info             do not display the information header and"\
                                 "footer"
    echo "  -p, --prompt          prompt before exit (in case the process"\
                                 "gets canceled"
    echo "  --pause PAUSE         Pause output after a certain amount of"\
                                 "lines"
    echo "  -r REMOVE, --remove REMOVE"
    echo "                        remove a certain string from each line"\
                                 "(for details"
    echo "                        see section 6 inside the documentation"\
                                 "file)"
    echo "  -s, --slow            slow down the process (decreases CPU"\
                                 "usage)"
    echo "  --tail TAIL           only return the given number of last lines"\
                                 "of the"
    echo "                        input file"
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
            echo -e "${cl_lr}error:${cl_n} $error_msg."
        fi
        exit 1
    else
        exit 0
    fi
}

# EOF
