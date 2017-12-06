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
    if [ -z "$1" ] || [ "$1" = "monitor" ]; then
        def_button="--defaultno"
    else
        def_button=""
    fi

    dlg_text=$(echo "What do you want to do with the input file(s)?")
    dialog $dlg_shadow --title "Processing mode" --yes-label "Analyze" \
                       --no-label "Monitor" $def_button \
                       --yesno "$dlg_text" 8 60
}

dialog_color_file() {
    if [ $dialog_show_color -ne 1 ]; then
        user_input="$1"
        return
    fi

    dlg_text=$(echo "Do you want to use a color file?\n\nEnter the path of"\
                    "the color config file or leave blank to disable"\
                    "highlighting:")
    predef_input_dialog "Color configuration file" "$dlg_text" 11 60 "$1"
}

dialog_delay() {
    if [ $dialog_show_delay -ne 1 ]; then
        user_input="$1"
        return
    fi

    dlg_text=$(echo "Enter the amount of milliseconds to wait between each"\
                    "output line:")
    predef_input_dialog "Slow down delay" "$dlg_text" 9 60 "$1"
}

dialog_exclude_pattern() {
    if [ $dialog_show_exclude -ne 1 ]; then
        user_input="$1"
        return
    fi

    dlg_text=$(echo "Do you want to use an exclude pattern?\n\nFor details"\
                    "about the exclude pattern syntax, see\nsection 5 inside"\
                    "the documentation.\n\nEnter the desired information or"\
                    "leave blank to skip:")
    predef_input_dialog "Exclude pattern" "$dlg_text" 13 60 "$1"
}

dialog_filter_pattern() {
    if [ $dialog_show_filter -ne 1 ]; then
        user_input="$1"
        return
    fi

    dlg_text=$(echo "Do you want to use a filter?\n\nYou can either enter"\
                    "the path to a filter config file or a filter pattern"\
                    "(without leading and trailing quotation marks).\n\nFor"\
                    "details about the filter syntax, see section 4.1 inside"\
                    "the documentation.\n\nEnter the desired information or"\
                    "leave blank to skip:")
    predef_input_dialog "Filter pattern" "$dlg_text" 17 60 "$1"
}

dialog_highlight() {
    def_item="1"

    if [ -z "$filter_pattern" ]; then
        if [ $highlight_all -eq 1 ]; then
            if [ $highlight_cut_off -eq 1 ]; then
                def_item="3"
            else
                def_item="2"
            fi
        fi

        if [ $dialog_show_highlight -ne 1 ]; then
            user_input="$def_item"
            return
        fi

        highlight_all=0
        highlight_cut_off=0
        highlight_matches=0
        highlight_upper=0

        user_input=$(dialog $dlg_shadow --no-cancel --default-item $def_item \
                            --title "Highlight mode" \
                            --menu "Do you want to highlight the output?" \
                                    10 60 20 \
                                    "1" "Do not highlight" \
                                    "2" "Highlight whole lines (filled)" \
                                    "3" "Highlight whole lines (cut-off)" \
                            3>&1 1>&2 2>&3 3>&-)
    else
        if [ $highlight_all -eq 1 ]; then
            if [ $highlight_cut_off -eq 1 ]; then
                def_item="3"
            else
                def_item="2"
            fi
        elif [ $highlight_matches -eq 1 ]; then
            def_item="4"
        elif [ $highlight_upper -eq 1 ]; then
            def_item="5"
        fi

        if [ $dialog_show_highlight -ne 1 ]; then
            user_input="$def_item"
            return
        fi

        highlight_all=0
        highlight_cut_off=0
        highlight_matches=0
        highlight_upper=0

        hlw="Highlight all lines"
        hlf="Highlight filter matches"
        user_input=$(dialog $dlg_shadow --no-cancel --default-item $def_item \
                            --title "Highlight mode" \
                            --menu "Do you want to highlight the output?" \
                                12 60 20 \
                                "1" "Do not highlight" \
                                "2" "$hlw (filled, filter independent)" \
                                "3" "$hlw (cut-off, filter independent)" \
                                "4" "$hlf" \
                                "5" "$hlf and convert to uppercase"\
                            3>&1 1>&2 2>&3 3>&-)
    fi
}

dialog_ignore_case() {
    if [ $dialog_show_ignorecase -ne 1 ]; then
        if [ "$1" = "-i" ]; then
            return 0
        else
            return 1
        fi
    fi

    if [ "$1" != "-i" ]; then
        def_button="--defaultno"
    else
        def_button=""
    fi

    dlg_text="Do you wish ignore the case of the given filter pattern?"
    dialog $dlg_shadow --title "Ignore case" --yes-label "Yes" \
                       --no-label "No" $def_button --yesno "$dlg_text" 8 60
}

dialog_input_file() {
    dlg_text=$(echo "Please enter the path of the file(s) which you want to"\
                    "process.\n\nMultiple paths must be separated with"\
                    "spaces.\n\nPaths that contain spaces themselves must"\
                    "either be enclosed with (single or double) quotes or"\
                    "given with escaped whitespaces.\n\nFor details see"\
                    "section 2.5 inside the documentation.")
    predef_input_dialog "Input file" "$dlg_text" 17 60 "$1"
}

dialog_prompt_on_exit() {
    if [ $dialog_show_prompt -ne 1 ]; then
        if [ $1 -eq 1 ]; then
            return 0
        else
            return 1
        fi
    fi

    if [ $1 -eq 1 ]; then
        def_button=""
    else
        def_button="--defaultno"
    fi

    dlg_text=$(echo "Do you wish to prompt before exiting?\n\nThis is useful"\
                    "when running SaLoMon in a terminal window which closes"\
                    "on exit.")
    dialog $dlg_shadow --title "Prompt on exit" --yes-label "Yes" \
                       --no-label "No" $def_button --yesno "$dlg_text" 8 60
}

dialog_remove_pattern() {
    if [ $dialog_show_remove -ne 1 ]; then
        user_input="$1"
        return
    fi

    dlg_text=$(echo "Do you want to use an remove pattern?\n\nFor details"\
                    "about the remove pattern syntax, see\nsection 6 inside"\
                    "the documentation.\n\nEnter the desired information or"\
                    "leave blank to skip:")
    predef_input_dialog "Remove pattern" "$dlg_text" 13 60 "$1"
}

dialog_slow_down() {
    if [ $dialog_show_slowdown -ne 1 ]; then
        if [ $1 -eq 1 ]; then
            return 0
        else
            return 1
        fi
    fi

    if [ $1 -eq 1 ]; then
        def_button=""
    else
        def_button="--defaultno"
    fi

    dlg_text=$(echo "Do you want to slow down the output of the lines?"\
                    "\n\nThis will decrease the CPU usage depending on the"\
                    "amount of output data. Usually, this is not required.")
    dialog $dlg_shadow --title "Slow down output" --yes-label "Yes" \
                       --no-label "No" $def_button --yesno "$dlg_text" 8 60
}

dialog_startup_notice() {
    if [ $dialog_shadow -ne 1 ]; then
        dlg_shadow="--no-shadow"
    else
        dlg_shadow=""
    fi

    dlg_text=$(echo "Notice that the interactive mode is \Z1not\Z0 (yet) a"\
                    "complete alternative to the command-line arguments."\
                    "\n\nFor details see section 2.6 inside the"\
                    "documentation.\n\nYou can \Z1cancel\Z0 interactive mode"\
                    "at any time either by holding \Z4Ctrl\Z0+\Z4C\Z0 or"\
                    "pressing those keys multiple times.")
    dialog $dlg_shadow --title "SaLoMon interactive mode notice" \
                       --colors --yes-label "Proceed" --no-label "Exit" \
                       --yesno "$dlg_text" 11 60

    if [ $? -ne 0 ]; then
        clear
        exit
    fi
}

dialog_wait_on_match() {
    if [ $dialog_show_wait -ne 1 ]; then
        user_input="$1"
        return
    fi

    dlg_text=$(echo "Do you want to wait after printing a colorized line?"\
                    "\n\nIf yes, enter the amount of seconds, otherwise"\
                    "leave blank to skip:")
    predef_input_dialog "Wait on match" "$dlg_text" 11 60 "$1"
}

predef_error_dialog() {
    dialog_text="$1"

    if [ $dialog_shadow -ne 1 ]; then
        dlg_shadow="$dlg_shadow"
    else
        dlg_shadow=""
    fi

    dialog $dlg_shadow --title "Error" --colors --ok-label "Exit" \
                       --msgbox "\Z1${dialog_text}." 8 60
}

predef_input_dialog() {
    dialog_title="$1"
    dialog_text="$2"
    dialog_height=$3
    dialog_width=$4
    dialog_init="$5"

    if [ -z $dialog_height ]; then
        diailog_height=8
    fi
    if [ -z $dialog_width ]; then
        dialog_width=60
    fi

    if [ $dialog_shadow -ne 1 ]; then
        dlg_shadow="$dlg_shadow"
    else
        dlg_shadow=""
    fi

    user_input=$(dialog $dlg_shadow --title "$dialog_title" \
                                    --cancel-label "Cancel" \
                                    --inputbox "$dialog_text" \
                                        $dialog_height $dialog_width \
                                        "$dialog_init" \
                        3>&1 1>&2 2>&3 3>&-)

    if [ $? -ne 0 ]; then
        clear
        exit
    fi
}

# EOF

