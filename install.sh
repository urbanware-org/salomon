#!/usr/bin/env bash

#
# Salomon - Simple log file monitor and analyzer
# Install and uninstall script
# Copyright (C) 2021 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

script_dir=$(dirname $(readlink -f $0))
. ${script_dir}/core/shell.sh   # Use POSIX standard instead of 'source' here
shell_precheck

source ${script_dir}/core/compat.sh
compatibility_precheck

script_file=$(basename "$0")
source ${script_dir}/core/common.sh
source ${script_dir}/core/global.sh
set_global_variables

script_mode=""
temp_dir="$(dirname $(mktemp -u --tmpdir))/salomon"
temp_file="$temp_dir/salomon_install_$$.tmp"
target_dir="/opt/salomon"

already_uninstalled=1
clean_install=0
exclude_config=""
keep_directory=0
target="${cl_yl}${target_dir}${cl_n}"
yesno="${cl_yl}Y${cl_n}/${cl_yl}N${cl_n}"

available="everyone"
dirmod=775
filemod=664
execmod=$dirmod

if [ -d "/usr/share/icons/hicolor" ]; then
    icon_path="/usr/share/icons/hicolor"
elif [ -d "/usr/local/share/icons/hicolor" ]; then
    icon_path="/usr/local/share/icons/hicolor"
fi
icon_path_scalable="$icon_path/scalable/apps"

set_permissions() {
    chown -R root:root $target_dir
    if [ "$available" = "rootonly" ]; then
        dirmod=770
        filemod=660
        execmod=$dirmod
    fi
    mkdir -p $temp_dir
    find $target_dir > $temp_file
    while read line; do
        if [ -f "$line" ]; then
            grep "\.sh$" <<< $line &>/dev/null
            if [ $? -eq 0 ]; then
                chmod $execmod $line
            else
                chmod $filemod $line
            fi
        elif [ -d "$line" ]; then
            chmod $dirmod $line
        fi
    done < $temp_file
    rm -f $temp_file
}

usage() {
    error_msg=$1
    given_arg=$2

    echo "usage: salomon.sh [-i] [-u]"
    echo
    echo "  -i, --install         install Salomon (requires superuser" \
         "privileges)"
    echo "  -u, --uninstall       uninstall Salomon (requires superuser" \
         "privileges)"
    echo "  -?, -h, --help        print this help message and exit"
    echo
    echo "Further information and usage examples can be found inside the" \
         "documentation"
    echo "file for this script."
    if [ ! -z "$error_msg" ]; then
        echo
        if [ -z "$given_arg" ]; then
            echo -e "${cl_lr}error:${cl_n} $error_msg."
        else
            echo -e "${cl_lr}error:${cl_n} $error_msg" \
                    "'${cl_yl}${given_arg}${cl_n}'."
        fi
        exit 1
    else
        exit 0
    fi
}

if [ $# -gt 1 ]; then
    usage "Too many arguments"
elif [ $# -lt 1 ]; then
    usage "Missing argument (to either install or uninstall)"
fi

if [ "$1" = "--install" ] || [ "$1" = "-i" ]; then
    script_mode="install"
    script_action="${cl_lg}${script_mode}${cl_n}"
    check_command rsync rsync
elif [ "$1" = "--uninstall" ] || [ "$1" = "-u" ]; then
    script_mode="uninstall"
    script_action="${cl_lr}${script_mode}${cl_n}"
elif [ "$1" = "-?" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
else
    usage "Invalid argument" "$1"
fi

if [ "$(whoami)" != "root" ]; then
    error="${cl_lr}error:${cl_n}"
    echo -e "$error Superuser privileges are required."
    exit 1
fi

grep "\/usr\/local\/bin" <<< $PATH &>/dev/null
if [ $? -eq 0 ]; then
    symlink_sh="/usr/local/bin"
else
    symlink_sh="/usr/bin"
fi

echo
echo -e "${cl_lc}Salomon install/uninstall script${cl_n}"
echo
if [ "$script_mode" = "install" ]; then
    echo -e "Installing Salomon is ${cl_yl}optional${cl_n} and not" \
            "mandatory in order to use it. Further"
    echo    "information can be found inside the documentation file for" \
            "this script."
    echo
fi
echo -e "This will $script_action Salomon. \c"
confirm "Do you wish to proceed ($yesno)? \c"
if [ $choice -eq 0 ]; then
    echo
    echo -e "${cl_lr}Canceled${cl_n} on user request."
    echo
    exit
fi
echo

if [ "$script_mode" = "install" ]; then
    echo -e "${cl_dc}Availability and permissions${cl_n}"
    echo
    echo -e "    You can make Salomon available either for all users on" \
            "this machine"
    echo -e "    or only for root."
    echo
    confirm "    Do you want to make it available for all users ($yesno)? \c"
    if [ $choice -eq 0 ]; then
        available="rootonly"
    fi
    echo
fi

if [ $script_mode = "install" ]; then
    if [ -d "$target_dir" ]; then
        echo -e "${cl_dc}Target directory${cl_n}"
        echo
        if [ ! "$script_dir" = "$target_dir" ]; then
            echo -e "    The target directory '$target' already exists. You" \
                    "can perform a"
            echo -e "    clean installation which will delete the directory" \
                    "and reinstall the"
            echo -e "    original files."
            echo
            echo -e "    Notice that this will also delete all user-defined" \
                    "configs and settings."
            echo
            confirm \
              "    Do you want to perform a clean installation ($yesno)? \c"
            clean_install=$choice
            echo
        else
            # Performing a clean installation when running this script from
            # the target directory would also delete the original files, so a
            # clean installation is not possible here
            if [ -d "$target_dir" ]; then
                echo -e "    You are running the this script from the" \
                        "installation directory. Due to"
                echo -e "    this, a clean installation (removing and" \
                        "reinstalling the files) is not"
                echo -e "    possible. This is not a problem, rather normal" \
                        "behavior."
                echo
            fi
        fi
    fi

    if [ ! -z "$icon_path" ]; then
        echo -e "${cl_dc}Shared icons${cl_n}"
        echo
        echo -e "    In case you want to create desktop shortcuts for" \
                "Salomon, it provides"
        echo -e "    its icon in multiple common sizes as well as in a" \
                "scalable image format."
        echo
        confirm "    Do you want to install the icon files ($yesno)? \c"
        install_icons=$choice
        echo
    fi

    echo -e "Ready to ${script_action} Salomon. \c"
    confirm "Do you wish to proceed ($yesno)? \c"
    if [ $choice -eq 0 ]; then
        echo
        echo -e "${cl_lr}Canceled${cl_n} on user request."
        echo
        exit
    fi
    echo

    echo -e "Installation directory is '${target}'."
    if [ $clean_install -eq 1 ]; then
        if [ "$(pwd)" = "$target_dir" ]; then
            echo "Removing previous data from installation directory..."
            rm -fR $target_dir/*
        else
            echo "Removing previous installation directory..."
            rm -fR $target_dir
        fi
    fi

    echo -e "Creating installation directory... \c"
    if [ -d $target_dir ]; then
        # The directory is not really created here. The code is for the output
        # message, only (just to keep the messages of the steps in order). The
        # actual code to create the directory is executed before the files are
        # copied into it.
        echo -e "${cl_lb}(already exists)${cl_n}"
    fi

    echo "Copying data to installation directory..."
    if [ -f "$target_dir/salomon.cfg" ]; then
        exclude_config="--exclude=salomon.cfg"
    fi

    mkdir -p $target_dir &>/dev/null
    rsync -a $script_dir/* $target_dir/ $exclude_config \
          --exclude="colors" \
          --exclude="filters" &>/dev/null

    mkdir -p $target_dir/colors &>/dev/null
    rsync -a $script_dir/colors/* $target_dir/colors/ \
          --ignore-existing &>/dev/null

    mkdir -p $target_dir/colors &>/dev/null
    rsync -a $script_dir/filters/* $target_dir/filters/  \
          --ignore-existing &>/dev/null

    # Remove all items which are not part of the official releases
    for dir in $git_clone; do
        rm -fR $target_dir/$dir &>/dev/null
    done
    for markdown in $(find $target_dir | grep "\.md$"); do
        rm -f $markdown
    done

    if [ $install_icons -eq 1 ]; then
        echo "Copying icon files to shared directory..."
        for i in 16 24 32 48 64 96 128 256; do
            if [ ! -e "$script_dir/icons/png/salomon_${i}x${i}.png" ]; then
                continue
            fi

            if [ -d "$icon_path/${i}x${i}" ]; then
                rm -f $icon_path/${i}x${i}/apps/salomon.png
                cp $script_dir/icons/png/salomon_${i}x${i}.png \
                   $icon_path/${i}x${i}/apps/salomon.png
            fi

            # This fixes a glitch from earlier versions where the icons were
            # copied into the improper directory
            rm -f $icon_path/${i}x${i}/salomon.png

            if [ -d $icon_path_scalable ]; then
                rm -f $icon_path_scalable/salomon.svg
                cp $script_dir/icons/svg/salomon.svg $icon_path_scalable/
            fi
        done
    fi

    echo -e "Setting permissions for installation directory... \c"
    if [ $available = "rootonly" ]; then
        echo -e "${cl_lb}(root only)${cl_n}"
    else
        echo -e "${cl_lb}(everyone)${cl_n}"
    fi
    set_permissions

    if [ $clean_install -eq 1 ]; then
        if [ -f ${symlink_sh}/salomon ]; then
            echo "Removing existing symbolic link for main script..."
            rm -f ${symlink_sh}/salomon &>/dev/null
        fi
    fi

    echo -e "Creating symbolic link for main script... \c"
    if [ -f ${symlink_sh}/salomon ]; then
        echo -e "${cl_lb}(already exists)${cl_n}"
    else
        ln -s ${target_dir}/salomon.sh ${symlink_sh}/salomon &>/dev/null
        echo
    fi
else  # uninstall
    if [ -d $target_dir ]; then
        echo -e "${cl_dc}Installation directory${cl_n}"
        echo
        echo -e "    Removing the installation directory '$target' will" \
                "also delete all"
        echo -e "    user-defined configs and settings."
        echo
        echo -e "    If you keep the installation directory, only the" \
                "symbolic link and the"
        echo -e "    icons will be removed."
        echo
        confirm "    Do you want to remove it ($yesno)? \c"
        if [ $choice -eq 0 ]; then
            keep_directory=1
        fi
        echo
    fi

    echo -e "Ready to ${script_action} Salomon."
    echo
    echo -e "Removing symbolic link for main script... \c"
    if [ -f ${symlink_sh}/salomon ]; then
        rm -f ${symlink_sh}/salomon &>/dev/null
        already_uninstalled=0
        echo
    else
        echo -e "${cl_lb}(does not exist)${cl_n}"
    fi

    echo -e "Removing icon files from shared directory... \c"
    icons_installed=$(find $icon_path | egrep "salomon\.png|salomon\.svg")
    if [ ! -z "$icons_installed" ]; then
        for i in $icons_installed; do
            rm -f $i
        done
        already_uninstalled=0
        echo
    else
        echo -e "${cl_lb}(do not exist)${cl_n}"
    fi

    echo -e "Removing installation directory '${target}'... \c"
    if [ $keep_directory -eq 1 ]; then
        echo -e "${cl_lb}(kept on user request)${cl_n}"
    else
        if [ -d $target_dir ]; then
            rm -fR $target_dir &>/dev/null
            already_uninstalled=0
            echo
        else
            echo -e "${cl_lb}(does not exist)${cl_n}"
        fi
    fi
fi
echo

if [ $script_mode = "uninstall" ] && [ $already_uninstalled -eq 1 ]; then
    echo "Nothing to do, as Salomon was already uninstalled or not" \
         "installed before."
    echo
    exit
fi

echo -e "Salomon has been ${script_mode}ed."
if [ $script_mode = "install" ]; then
    echo -e "You can now directly run the '${cl_yl}salomon${cl_n}' command" \
            "in order to use it."
fi
echo

# EOF
