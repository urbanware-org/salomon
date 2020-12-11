#!/usr/bin/env bash

#
# Salomon - Simple log file monitor and analyzer
# Install and uninstall script
# Copyright (C) 2020 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

script_dir=$(dirname $(readlink -f $0))
. ${script_dir}/core/shell.sh   # Use POSIX standard instead of 'source' here
shell_precheck

script_file=$(basename "$0")
source ${script_dir}/core/common.sh
source ${script_dir}/core/global.sh
set_global_variables

script_mode=""
temp_file="/tmp/salomon_install_$$.tmp"
target_dir="/opt/salomon"

clean_install=0
git_clone=".git snippets wiki README.md"
keep_directory=0
yesno="${cl_yl}Y${cl_n}/${cl_yl}N${cl_n}"
proceed="Do you wish to proceed"

available="everyone"
is_root=0
dirmod=775
filemod=664
execmod=$dirmod

set_permissions() {
    if [ $is_root -eq 1 ]; then
        chown -R root:root $target_dir
        if [ "$available" = "rootonly" ]; then
            dirmod=770
            filemod=660
            execmod=$dirmod
        fi
    fi
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
    usage "Missing argument (to install or uninstall)"
fi

if [ "$1" = "--install" ] || [ "$1" = "-i" ]; then
    script_mode="install"
    script_action="${cl_lg}${script_mode}${cl_n}"
elif [ "$1" = "--uninstall" ] || [ "$1" = "-u" ]; then
    script_mode="uninstall"
    script_action="${cl_lr}${script_mode}${cl_n}"
elif [ "$1" = "-?" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
else
    usage "Invalid argument" "$1"
fi

if [ "$(whoami)" = "root" ]; then
    is_root=1
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
else
    if [ ! -f "$script_dir/salomon" ]; then
        run_message="Please run this script"
        usage "$run_message from the directory where Salomon is installed"
    fi
fi

if [ $is_root -eq 0 ]; then
    if [ "$script_mode" = "install" ]; then
        target_dir="$HOME/salomon"
        echo    "You are not running this script as superuser. Due to this," \
                "a system-wide"
        echo    "installation cannot be performed. Instead, Salomon will be" \
                "installed into"
        echo -e "your home directory '${cl_yl}$HOME${cl_n}'."
        echo
    fi
fi
target="${cl_yl}${target_dir}${cl_n}"

confirm "This will $script_action Salomon. $proceed ($yesno)? \c"
if [ $choice -eq 0 ]; then
    echo
    echo -e "${cl_lr}Canceled${cl_n} on user request."
    echo
    exit
fi
echo

if [ "$script_mode" = "install" ]; then
    echo -e "The current target directory is '$target'."
    echo
    echo -e "You can also include the version number in the installation" \
            "path name (with"
    echo -e "this version the path name would be" \
            "'${target}${cl_yl}-$version${cl_n}' then)."
    confirm "Do you want to include the version in the path ($yesno)? \c"
    if [ $choice -eq 1 ]; then
        target_dir="${target_dir}-$version"
        target="${cl_yl}${target_dir}${cl_n}"
    fi
    echo
fi

if [ $script_mode = "install" ]; then
    if [ -d "$target_dir" ]; then
        if [ ! "$script_dir" = "$target_dir" ]; then
            echo -e "The target directory '$target' already exists."
            echo
            echo -e "You can perform a clean installation which will delete" \
                    "the directory and"
            echo -e "reinstall the original files. Notice that all" \
                    "user-defined configuration"
            echo -e "as well as color and filter files will also be deleted" \
                    "then."
            confirm "Do you want to perform a clean installation ($yesno)? \c"
            clean_install=$choice
            echo
        else
            # Performing a clean installation when running this script from
            # the target directory would also delete the original files, so a
            # clean installation is not possible here
            if [ -d "$target_dir" ]; then
                echo "You are running the this script from the installation" \
                     "directory. Due to this,"
                echo "a clean installation (removing and reinstalling the" \
                     "files) is not possible."
                echo
            fi
        fi
    fi

    if [ $is_root -eq 1 ]; then
        if [ "$script_mode" = "install" ]; then
            echo -e "You can make Salomon available either for all users on" \
                    "this machine or only"
            echo -e "for root. \c"
            confirm \
              "Do you want to make it available for all users ($yesno)? \c"
            if [ $choice -eq 0 ]; then
                available="rootonly"
            fi
            echo
        fi
    fi

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
        echo -e "${cl_lb}(already exists)${cl_n}"
    else
        mkdir -p $target_dir &>/dev/null
        echo
    fi

    echo "Copying data to installation directory..."
    rsync -av $script_dir/* $target_dir/ &>/dev/null

    # Remove all items which are not part of the official releases
    for dir in $git_clone; do
        rm -fR $target_dir/$git_clone &>/dev/null
    done

    if [ $is_root -eq 1 ]; then
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
    fi
else  # uninstall
    target_dir=$script_dir
    target="${cl_yl}${target_dir}${cl_n}"
    echo -e "Removing the installation directory '$target' will also" \
            "delete all"
    echo -e "all user-defined configuration as well as color and filter" \
            "files."
    confirm "Do you want to remove it ($yesno)? \c"
    if [ $choice -eq 0 ]; then
        keep_directory=1
    fi
    echo

    if [ $is_root -eq 1 ]; then
        echo -e "Removing symbolic link for main script... \c"
        if [ -f ${symlink_sh}/salomon ]; then
            rm -f ${symlink_sh}/salomon &>/dev/null
            echo
        else
            echo -e "${cl_lb}(does not exist)${cl_n}"
        fi
    fi

    echo -e "Removing installation directory '${target}'... \c"
    if [ $keep_directory -eq 1 ]; then
        echo -e "${cl_lb}(kept on user request)${cl_n}"
    else
        if [ -d $target_dir ]; then
            rm -fR $target_dir &>/dev/null
            echo
        else
            echo -e "${cl_lb}(does not exist)${cl_n}"
        fi
    fi
fi

echo
echo -e "Salomon has been ${script_mode}ed."
if [ $is_root -eq 1 ]; then
    if [ $script_mode = "install" ]; then
        echo -e "You can now directly run the '${cl_yl}salomon${cl_n}'" \
                "command in order to use it."
    fi
fi
if [ $script_mode = "install" ]; then
    cd $target_dir
    ln -s salomon.sh salomon &>/dev/null
    echo
    echo -e "In order to uninstall, run" \
            "'${cl_yl}$target_dir/install.sh -u${cl_n}'."
fi
echo

# EOF
