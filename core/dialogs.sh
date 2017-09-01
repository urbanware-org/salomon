#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Interactive dialog core script
# Copyright (C) 2017 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# Website: http://www.urbanware.org
# GitHub: https://github.com/urbanware-org/salomon
# ============================================================================

dialog_action() {
    dialog --no-shadow --title "Processing mode" --yes-label "Analyze" \
           --no-label "Monitor" --default-button no \
           --yesno "What do you want to do with the input file?" 8 60
}

dialog_color_file() {
    predef_input_dialog "Color configuration file" \
        "Do you want to use a color file?\n\nEnter the path of the color config file or leave blank to disable highlighting:" 11 60
}

dialog_filter() {
    predef_input_dialog "Filter pattern" \
        "Do you want to use a filter?\n\nYou can either enter the path to a filter config file or a filter pattern (without leading and trailing quotation marks).\n\nFor details about the filter syntax, see section 4.1 inside the documentation.\n\nEnter the desired information or leave blank to skip:" 17 60
}




diadlog_filter() {
    predef_input_dialog "Filter" \
        "Do you want to use a filter?\n\nFor details about the filter syntax, see section 4.1 inside the documentation.\n\nEnter the filter pattern (without leading and trailing quotation marks) or leave blank to skip:" 14 60
}

diaddlog_filter() {
    predef_input_dialog "Filter" \
        "Do you want to use a filter?\n\nFor details about the filter syntax, see section 4.1 inside the documentation.\n\nEnter the filter pattern (without leading and trailing quotation marks) or leave blank to skip:" 14 60
}




dialog_highlight() {
    if [ -z "$filter_pattern" ]; then
        user_input=$(dialog --no-shadow --no-cancel --title "Highlight mode" \
                            --menu "Do you want to highlight the output?" \
                            10 60 20 \
                            "1" "Do not highlight" \
                            "2" "Highlight whole lines (filled)" \
                            "3" "Highlight whole lines (cut-off)" \
                            3>&1 1>&2 2>&3 3>&-)
    else
        user_input=$(dialog --no-shadow --no-cancel --title "Highlight mode" \
                            --menu "Do you want to highlight the output?" \
                            12 60 20 \
                            "1" "Do not highlight" \
                            "2" "Highlight whole lines (filled, filter independent)" \
                            "3" "Highlight whole lines (cut-off, filter independent)" \
                            "4" "Highlight filter matches" \
                            "5" "Highlight and uppercase filter matches"\
                            3>&1 1>&2 2>&3 3>&-)
    fi
}

dialog_input_file() {
    predef_input_dialog "Input file" \
        "Please enter the path of the file you want to process:" 8 60
}

predef_notice_dialog() {
    dialog --no-shadow --title "SaLoMon interactive mode notice" \
           --colors --ok-label "Proceed" \
           --msgbox "Notice that the interactive mode is \Z1not\Z0 a complete alternative to the command-line arguments.\n\nFor details see section 2.5 inside the documentation.\n\nYou can \Z1cancel\Z0 interactive mode at any time either by holding \Z4Ctrl\Z0+\Z4C\Z0 or pressing those keys multiple times." 11 60 # FIXME Add the information to the documentation
}

predef_error_dialog() {
    dialog_text="$1"

    dialog --no-shadow --title "Error" --colors --ok-label "Exit" \
           --msgbox "\Z1${dialog_text}." 8 60
}

predef_input_dialog() {
    dialog_title="$1"
    dialog_text="$2"
    dialog_height=$3
    dialog_width=$4

    if [ -z $dialog_height ]; then
        diailog_height=8
    fi
    if [ -z $dialog_width ]; then
        dialog_width=60
    fi

    user_input=$(dialog --no-shadow --no-cancel --title "$dialog_title" \
                        --inputbox "$dialog_text" \
                        $dialog_height $dialog_width \
                        3>&1 1>&2 2>&3 3>&-)
}

# EOF

