#!/bin/bash

# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Interactive dialog core script
# Copyright (C) 2018 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
# ============================================================================

dialog_action() {
    if [ -z "$1" ] || [ "$1" = "monitor" ]; then
        def_button="--defaultno"
    else
        def_button=""
    fi

    dlg_text="What do you want to do with the input file(s)?"

    if [ $dialog_program = "dialog" ]; then
        dialog $dlg_shadow --title "Processing mode" --yes-label "Analyze" \
                           --no-label "Monitor" $def_button \
                           --yesno "$dlg_text" 8 60
    else
        whiptail --title "Processing mode" --yes-button "Analyze" \
                 --no-button "Monitor" $def_button \
                 --yesno "$dlg_text" 7 60
    fi
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

dialog_export_file() {
    if [ $dialog_show_export -ne 1 ]; then
        user_input="$1"
        return
    fi

    dlg_text=$(echo "Do you want to simultaneously export the output lines"\
                    "into a file?\n\nFor details see section 9 inside the"\
                    "documentation.\n\nEnter the desired output file path or"\
                    "leave blank to skip:")

    predef_input_dialog "Export output to file" "$dlg_text" 14 60 "$1"
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

dialog_head_lines() {
    if [ $dialog_show_head_lines -ne 1 ]; then
        user_input="$1"
        return
    fi

    dlg_text=$(echo "Do you only want to display a certain amount of first"\
                    "lines of the given input file?\n\nEnter the desired"\
                    "amount or leave blank to skip:")
    predef_input_dialog "Number of first lines" "$dlg_text" 11 60 "$1"
}

dialog_highlight() {
    def_item="1"
    dlg_text="Do you want to highlight the output?"

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

        if [ $dialog_program = "dialog" ]; then
            user_input=$(dialog $dlg_shadow --no-cancel \
                                --default-item $def_item \
                                --title "Highlight mode" \
                                --menu "$dlg_text" \
                                    10 60 20 \
                                    "1" "Do not highlight" \
                                    "2" "Highlight whole lines (filled)" \
                                    "3" "Highlight whole lines (cut-off)" \
                                3>&1 1>&2 2>&3 3>&-)
        else
            user_input=$(whiptail --nocancel --default-item $def_item \
                                  --title "Highlight mode" \
                                  --menu "$dlg_text" \
                                    13 60 3 \
                                    "1" "Do not highlight" \
                                    "2" "Highlight whole lines (filled)" \
                                    "3" "Highlight whole lines (cut-off)" \
                                  3>&1 1>&2 2>&3 3>&-)

        fi
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

        if [ $dialog_program = "dialog" ]; then
            user_input=$(dialog $dlg_shadow --no-cancel \
                                --default-item $def_item \
                                --title "Highlight mode" \
                                --menu "$dlg_text" \
                                    12 60 20 \
                                    "1" "Do not highlight" \
                                    "2" "$hlw (filled, filter independent)" \
                                    "3" "$hlw (cut-off, filter independent)" \
                                    "4" "$hlf" \
                                    "5" "$hlf and convert to uppercase"\
                                3>&1 1>&2 2>&3 3>&-)
        else
            user_input=$(whiptail --nocancel --default-item $def_item \
                                  --title "Highlight mode" \
                                  --menu "$dlg_text" \
                                    13 60 5 \
                                    "1" "Do not highlight" \
                                    "2" "$hlw (filled, filter independent)" \
                                    "3" "$hlw (cut-off, filter independent)" \
                                    "4" "$hlf" \
                                    "5" "$hlf and convert to uppercase"\
                                  3>&1 1>&2 2>&3 3>&-)
        fi
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

    if [ $dialog_program = "dialog" ]; then
        dialog $dlg_shadow --title "Ignore case" --yes-label "Yes" \
                           --no-label "No" $def_button --yesno "$dlg_text" \
                           8 60
    else
        whiptail --title "Ignore case" --yes-button "Yes" --no-button "No" \
                 $def_button --yesno "$dlg_text" 7 60
    fi
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

dialog_no_info() {
    if [ $dialog_show_noinfo -ne 1 ]; then
        if [ $1 -eq 1 ]; then
            return 0
        else
            return 1
        fi
    fi

    if [ $1 -eq 0 ]; then
        def_button="--defaultno"
    else
        def_button=""
    fi

    dlg_text="Do you want to display an information header and footer?"

    if [ $dialog_program = "dialog" ]; then
        dialog $dlg_shadow --title "Information header and footer" \
                           --yes-label "Yes" --no-label "No" $def_button \
                           --yesno "$dlg_text" 8 60
    else
        whiptail --title "Information header and footer" --yes-button "Yes" \
                 --no-button "No" $def_button --yesno "$dlg_text" 7 60
    fi
}

dialog_pause_output() {
    if [ $dialog_show_pause -ne 1 ]; then
        user_input="$1"
        return
    fi

    dlg_text=$(echo "Do you only want to pause the output after a certain"\
                    "number of output lines?\n\nEnter the desired amount"\
                    "of lines, enter 'auto' to pause based on the terminal"\
                    "height or leave blank to skip:")
    predef_input_dialog "Pause output" "$dlg_text" 12 60 "$1"
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

    if [ $dialog_program = "dialog" ]; then
        dialog $dlg_shadow --title "Prompt on exit" --yes-label "Yes" \
                           --no-label "No" $def_button --yesno "$dlg_text" 8 60
    else
        whiptail  --title "Prompt on exit" --yes-button "Yes" \
                  --no-button "No" $def_button --yesno "$dlg_text" 7 60
    fi
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

    if [ $dialog_program = "dialog" ]; then
        dialog $dlg_shadow --title "Slow down output" --yes-label "Yes" \
                           --no-label "No" $def_button --yesno "$dlg_text" \
                           8 60
    else
        whiptail --title "Slow down output" --yes-button "Yes" \
                 --no-button "No" $def_button --yesno "$dlg_text" 7 60
    fi
}

dialog_tail_lines() {
    if [ $dialog_show_tail_lines -ne 1 ]; then
        user_input="$1"
        return
    fi

    if [ $follow -eq 1 ]; then
        dlt="also"
    else
        dlt="only"
    fi

    dlg_text=$(echo "Do you $dlt want to display a certain amount of last"\
                    "lines of the given input file?\n\nEnter the desired"\
                    "amount or leave blank to skip:")
    predef_input_dialog "Number of last lines" "$dlg_text" 11 60 "$1"
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

dialog_welcome() {
    if [ $dialog_show_welcome -ne 1 ]; then
        return
    fi

    dlg_text=$(echo "Welcome to the interactive dialogs!\n\nFor details"\
                    "about this feature see section 2.6 inside the"\
                    "documentation.\n\n")

    if [ $dialog_program = "dialog" ]; then
        dlg_notice=$(echo "You can \Z1cancel\Z0 this interactive"\
                          "mode at any time either by holding"\
                          "\Z4Ctrl\Z0+\Z4C\Z0 or pressing those keys"\
                          "multiple times. Some dialogs also contain an"\
                          "\Z4Exit\Z0 button to do so.")
        dialog $dlg_shadow --title "SaLoMon interactive dialogs notice" \
                           --colors --yes-label "Proceed" --no-label "Exit" \
                           --yesno "${dlg_text}${dlg_notice}" 12 60
    else
        dlg_text=$(sed -e "s/\\\Z[0-9]//g" <<< "$dlg_text")
        dlg_notice=$(echo "You can cancel this interactive mode using"\
                          "the 'Exit' buttons on this and many of the"\
                          "following dialogs.")
        whiptail --title "SaLoMon interactive dialogs notice" \
                 --yes-button "Proceed" --no-button "Exit" \
                 --yesno "${dlg_text}${dlg_notice}" 13 60
    fi

    if [ $? -ne 0 ]; then
        clear
        exit
    fi
}

init_dialogs() {
    if [ $dialog_shadow -ne 1 ]; then
        dlg_shadow="--no-shadow"
    else
        dlg_shadow=""
    fi

    dialog_welcome
}

predef_error_dialog() {
    dialog_text="$1"

    if [ $dialog_shadow -ne 1 ]; then
        dlg_shadow="$dlg_shadow"
    else
        dlg_shadow=""
    fi

    if [ $dialog_program = "dialog" ]; then
        dialog $dlg_shadow --title "Error" --colors --ok-label "Exit" \
                           --msgbox "\Z1${dialog_text}." 8 60
    else
        whiptail --title "Error" --ok-button "Exit" \
                 --msgbox "${dialog_text}." 8 60
    fi
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

    if [ $dialog_program = "dialog" ]; then
        user_input=$(dialog $dlg_shadow --title "$dialog_title" \
                                        --ok-label "Proceed" \
                                        --cancel-label "Exit" \
                                        --inputbox "$dialog_text" \
                                            $dialog_height $dialog_width \
                                            "$dialog_init" \
                            3>&1 1>&2 2>&3 3>&-)
    else
        user_input=$(whiptail --title  "$dialog_title" --ok-button "Proceed" \
                              --cancel-button "Exit" \
                              --inputbox "$dialog_text" \
                              $dialog_height $dialog_width \
                              "$dialog_init" 3>&1 1>&2 2>&3 3>&-)
    fi

    if [ $? -ne 0 ]; then
        clear
        exit
    fi
}

# EOF
