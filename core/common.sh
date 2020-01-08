#!/bin/bash

# ============================================================================
# Salomon - Simple log file monitor and analyzer
# Common core script
# Copyright (C) 2020 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
# ============================================================================

cancel_process() {
    echo
    if [ $header -eq 1 ]; then
        print_line "*" 1
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
            read -n1 -r < /dev/tty
        else
            print_line "*"
        fi
    else
        if [ $prompt -eq 1 ]; then
            trap - 2 20
            print_line "${cl_ly}Press any key to exit."
            read -n1 -r < /dev/tty
        fi
    fi
    echo -e "\r\c"

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
    required_pkg=$2

    command -v $check_command &>/dev/null
    if [ $? -ne 0 ]; then
        usage "This script requires the '$required_pkg' package to work"
    fi
}

check_config() {
    check_config_value "$boxdrawing_chars"        integer 1
    boxdrawing_chars=$config_value
    check_config_value "$delay"                   integer 200
    delay=$config_value
    check_config_value "$dialog_program"          string  "auto" \
      "auto dialog whiptail"
    dialog_program=$config_value
    check_config_value "$dialog_shadow"           integer 1
    dialog_shadow=$config_value
    check_config_value "$dialog_show_color"       integer 1
    dialog_show_color=$config_value
    check_config_value "$dialog_show_delay"       integer 1
    dialog_show_delay=$config_value
    check_config_value "$dialog_show_exclude"     integer 1
    dialog_show_exclude=$config_value
    check_config_value "$dialog_show_export"      integer 1
    dialog_show_export=$config_value
    check_config_value "$dialog_show_filter"      integer 1
    dialog_show_filter=$config_value
    check_config_value "$dialog_show_head_lines"  integer 1
    dialog_show_head_lines=$config_value
    check_config_value "$dialog_show_highlight"   integer 1
    dialog_show_highlight=$config_value
    check_config_value "$dialog_show_noinfo"      integer 1
    dialog_show_noinfo=$config_value
    check_config_value "$dialog_show_ignorecase"  integer 1
    dialog_show_ignorecase=$config_value
    check_config_value "$dialog_show_pause"       integer 1
    dialog_show_pause=$config_value
    check_config_value "$dialog_show_prompt"      integer 1
    dialog_show_prompt=$config_value
    check_config_value "$dialog_show_remove"      integer 1
    dialog_show_remove=$config_value
    check_config_value "$dialog_show_slowdown"    integer 1
    dialog_show_slowdown=$config_value
    check_config_value "$dialog_show_tail_lines"  integer 1
    dialog_show_tail_lines=$config_value
    check_config_value "$dialog_show_wait"        integer 1
    dialog_show_wait=$config_value
    check_config_value "$dialog_show_welcome"     integer 1
    dialog_show_welcome=$config_value
    check_config_value "$line_width"              string  "auto" "auto fixed"
    line_width=$config_value
    check_config_value "$separator_line"          integer 1
    separator_line=$config_value
    check_config_value "$highlight_forecolor"     string  "terminal" \
      "terminal black white"
    highlight_forecolor=$config_value
    check_config_value "$usage_color"             integer 1
    usage_color=$config_value
}

check_config_value() {
    config_option="$1"
    config_expect="$2"
    config_default="$3"
    config_values="$4"
    config_value=""

    if [ -z "$config_option" ]; then
        config_value="$config_default"
    else
        if [ "$config_expect" = "integer" ]; then
            re='^[0-9]+$'
            if [[ ! "$config_option" =~ $re ]]; then
                config_value="$config_default"
            else
                config_value="$config_option"
            fi
        else
            for value in $config_values; do
                config_value="$config_default"
                if [ "$config_option" = "$value" ]; then
                    config_value="$config_option"
                    break
                fi
            done
        fi
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

    command -v wget &>/dev/null
    if [ $? -ne 0 ]; then
        usage "Retrieving update information requires 'wget' (not installed)"
    fi
    
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
        echo "This version of Salomon is up-to-date."
    else
        echo "There is a newer version of Salomon available."
        echo
        echo "For details see: $link_latest"
    fi
    echo

    exit
}

concat_arg() {
    arg_a="$1"
    concat="$arg_list $1"
    arg_list=$concat
}

confirm() {
    msg="$1"
    while true; do
        echo -e "$msg"
        read choice
        egrep "^yes$|^y$|^no$|^n$" -i <<< $choice &>/dev/null
        if [ $? -eq 0 ]; then
            egrep "^yes$|^y$" -i <<< $choice &>/dev/null
            if [ $? -eq 0 ]; then
                choice=1
                break
            else
                choice=0
                break
            fi
        fi
    done
}

debug_notification() {
    echo
    print_line "*" 1
    print_line "${cl_yl}This version of Salomon has been modified for debug "\
               "purposes."
    print_line
    print_line "${cl_n}The '${cl_lc}debug${cl_n}' sub-directory contains "\
               "script files which will be loaded when"
    print_line "${cl_n}proceeding. This means that functions and variables "\
               "defined in the core"
    print_line "${cl_n}modules will be overwritten by those debug scripts"\
               "which may cause unusual"
    print_line "${cl_n}or faulty behavior."
    print_line
    print_line "${cl_n}You can disable this notification by adding the "\
               "'${cl_lc}--debug${cl_n}' argument."
    print_line "*"
    echo
    yesno="${cl_yl}Y${cl_n}/${cl_yl}N${cl_n}"
    confirm "Do you wish to proceed ($yesno)? \c"
    if [ $choice -ne 1 ]; then
        echo
        echo -e "${cl_lr}Canceled${cl_n} on user request."
        echo
        exit
    fi
    echo
}

deprecated_argument() {
    arg_g="$1"
    arg_i="$2"

    dep="The argument '${cl_lc}${arg_g}${cl_n}' is ${cl_yl}deprecated${cl_n}."
    ins="You may use '${cl_lc}${arg_i}${cl_n}' instead."

    echo -e "${cl_lb}notice:${cl_n} $dep $ins"
    sleep 3
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

print_arg_list() {
    if [ $boxdrawing_chars -eq 1 ]; then
        ln="═"
    else
        ln="="
    fi

    arg_temp="/tmp/salomon_args_$$.txt"
    echo "$arg_list" > $arg_temp

    clear
    message="${cl_ly}[${cl_lc}Command-line arguments${cl_ly}]${cl_dy}"
    echo -e "${cl_dy}$ln$ln${message}\c"

    if [ "$line_width" = "auto" ]; then
        term_cols=$(( $(tput cols) - 26 ))
    else
        term_cols=52
    fi

    for number in $(seq 1 $term_cols); do
        echo -e "$ln\c"
    done

    echo -e "\e[0m\n"
    echo -e "With the given information, the command line would look like"\
            "this (without"
    echo -e "'${cl_lc}--dialog${cl_n}' or '${cl_lc}--interactive${cl_n}'"\
            "argument):"
    echo
    echo -e "    ${cl_yl}$arg_list${cl_n}"
    echo
    echo "In case you are on text-based user interface and cannot select and"\
         "copy the"
    echo "above command, it has also been written into the following"\
         "temporary file:"
    echo
    echo -e "    ${cl_yl}$arg_temp${cl_n}"
    echo
    pause_output
}

read_config_file() {
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
        ly=$cl_ly
        yl=$cl_yl
    else
        no=$cl_n
        lb=$cl_n
        lc=$cl_n
        lg=$cl_n
        lr=$cl_n
        ly=$cl_n
        yl=$cl_n
    fi

    usage="${lc}usage: ${no}$script_file"
    echo -e "$usage -a {analyze,monitor} -i INPUT_FILE [-c COLOR_FILE]
                  [--cut-off] [-d DELAY] [--dialogs] [-e EXCLUDE]
                  [--export-file EXPORT_FILE] [-f FILTER] [--head HEAD]
                  [--highlight-all] [--highlight-matches] [--highlight-upper]
                  [--ignore-case] [--no-info] [-p] [--pause PAUSE] [-r REMOVE]
                  [-s] [--tail TAIL] [--version] [-w WAIT]
${lg}
Monitor and analyze log and plain text files with various filter and
highlighting features.
${no}
${lr}required arguments:${no}
  -a {analyze,monitor}, --action {analyze,monitor}
                        action (processing mode) to perform with the given
                        input file(s) (this can also be given via '--analyze'
                        or '--monitor' instead)
  -i INPUT_FILE, --input-file INPUT_FILE
                        input file to analyze or monitor (can be given
                        multiple times)

${lb}optional arguments:${no}
  -c COLOR_FILE, --color-file COLOR_FILE
                        color config file for colorizing lines which contain
                        certain terms
  --cut-off             remove the trailing whitespaces used to fill the line
                        when using '--highlight-all'
  -d DELAY, --delay DELAY
                        delay for the '--slow' argument below (milliseconds,
                        number between 100 and 900, default is $delay)
  --dialogs             use interactive dialogs (for details see section 2.6
                        inside the documentation)
  -e EXCLUDE, --exclude EXCLUDE
                        exclude lines which a certain string (for details see
                        section 5 inside the documentation file)
  --export-file EXPORT_FILE
                        simultaneously export the output into a file (for
                        details see section 9 inside the documentation file)
  -f FILTER, --filter FILTER
                        print the lines that contain the given filter pattern,
                        only (for details see section 4 inside the
                        documentation file)
  --force-dark          force using dark text colors
  --force-light         force using light text colors
  -h HEAD, --head HEAD  only return the given number of first lines of the
                        input file
  -ha, --highlight-all  highlight the whole lines by inverting their color (no
                        filter required)
  -hm, --highlight-matches
                        highlight the filter matches by inverting their colors
  -hu, --highlight-upper
                        same as '--highlight-matches' and with to uppercase
                        converted letters
  -ic, --ignore-case    ignore the case of the given filter pattern
  --interactive         same as '--dialogs'
  --merge               merge all input files to a single sorted one (useful
                        for files containing lines starting with timestamps)
  --no-info             do not display the information header and footer
  -p, --prompt          prompt before exit
  --pause PAUSE         pause output after a certain amount of lines
  -r REMOVE, --remove REMOVE
                        remove a certain string from each line (for details
                        see section 6 inside the documentation file)
  -s, --slow            slow down the process (decreases CPU usage)
  -t TAIL, --tail TAIL  only return the given number of last lines of the
                        input file
  -w WAIT, --wait WAIT  seconds to wait after printing a colorized line

${ly}general arguments:${no}
  --color-table         print the 256-color table to see which colors are
                        supported (can be displayed) by the terminal emulator
                        currently used and exit
  --version             print the version number and exit
  --version-update      check for a newer version and exit
  -?, --help            print this help message and exit
${yl}
Further information and usage examples can be found inside the documentation
file for this script.${no}"
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

warn() {
    message=$1
    indent=$2

    if [ $indent -eq 0 ]; then
        echo -e "${cl_yl}warning:${cl_n} ${message}."
        sleep 1
    else
        echo -e "${cl_dy}==> ${cl_yl}warning:${cl_n} ${message}."
    fi
}

# EOF
