#!/usr/bin/env bash

#
# Salomon - Simple log file monitor and analyzer
# Install and uninstall script
# Copyright (c) 2023 by Ralf Kilian
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
if [ $is_bsd -eq 1 ]; then
    temp_dir="$(dirname $(mktemp -u))/salomon"
else  # Linux
    temp_dir="$(dirname $(mktemp -u --tmpdir))/salomon"
fi

temp_file="$temp_dir/salomon_install_$$.tmp"
target_dir="/opt/salomon"
migrate_dir="/opt/salomon-bsd"

allow_write=0
already_uninstalled=1
clean_install=0
blk="${cl_lb}■${cl_n}"
exclude_config=""
keep_directory=0
migrate=0
target="${cl_yl}${target_dir}${cl_n}"
dowant="Do you want to"
dowish="Do you wish to"
yesno="${cl_yl}Y${cl_dy}es${cl_n}/${cl_yl}N${cl_dy}o${cl_n}"
yesnocancel="${yesno}${cl_m}/${cl_yl}C${cl_dy}ancel${cl_n}"

available=""
user="root"
group="root"
dirmod=775
filemod=664
execmod=$dirmod

if [ $is_bsd -eq 1 ]; then
    group="wheel"
fi

if [ -d "/usr/share/icons/hicolor" ]; then
    icon_path="/usr/share/icons/hicolor"
elif [ -d "/usr/local/share/icons/hicolor" ]; then
    icon_path="/usr/local/share/icons/hicolor"
fi
icon_path_scalable="$icon_path/scalable/apps"
icon_path_xpm="/usr/share/pixmaps"

cancel_install() {
    echo
    echo -e "${cl_lr}Canceled${cl_n} on user request."
    echo
    exit
}

set_permissions() {
    chown -R ${user}:${group} $target_dir
    if [ "$available" = "rootonly" ]; then
        if [ $is_bsd -eq 1 ]; then
            dirmod=700
            filemod=600
        else
            dirmod=770
            filemod=660
        fi
    else
        if [ $is_bsd -eq 1 ]; then
            dirmod=755
            filemod=644
        else
            dirmod=775
            filemod=664
        fi
    fi
    execmod=$dirmod

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
    done < "$temp_file"
    rm -f $temp_file

    if [ $allow_write -eq 1 ]; then
        chmod 777 $target_dir/colors
        chmod 777 $target_dir/filters
        chmod 666 $target_dir/colors/*
        chmod 666 $target_dir/filters/*
    fi

    if [ $(ls $temp_dir | wc -l) -eq 0 ]; then
        rm -fR $temp_dir
    fi
}

usage() {
    error_msg=$1
    given_arg=$2

    echo -e "usage: install.sh [-i] [-u]"
    echo
    echo -e "  -i, --install         install, reinstall (clean install) or" \
            "update Salomon"
    echo -e "  -u, --uninstall       uninstall Salomon"
    echo -e "  -?, -h, --help        print this help message and exit"
    echo
    echo -e "Notice that installing and uninstalling Salomon requires" \
            "${cl_yl}superuser privileges${cl_n}."
    echo
    echo -e "Further information and usage examples can be found inside the" \
            "documentation"
    echo -e "file for this script."
    if [ -n "$error_msg" ]; then
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
    if [ -d "/opt/salomon" ]; then
        script_action="${cl_lg}${script_mode}${cl_n} or ${cl_lg}update${cl_n}"
    else
        script_action="${cl_lg}${script_mode}${cl_n}"
    fi
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
    echo -e "$error Superuser privileges are required in order to" \
            "${script_mode} Salomon."
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
confirm "This will $script_action Salomon. $dowish proceed ($yesno)? \c"
if [ $choice -eq 0 ]; then
    cancel_install
fi
echo

if [ "$script_mode" = "install" ]; then
    echo -e "${cl_dc}Availability and permissions${cl_n}"
    echo
    echo -e "  ${blk} You can make Salomon available either for all users" \
            "on this machine or"
    echo -e "    only for root."
    echo
    echo -e "    Notice that if you choose the latter, you even must be" \
            "root in order to"
    echo -e "    run Salomon and it will not be available for other users" \
            "at all."
    echo
    confirm "    $dowant make it available for all users ($yesnocancel)? \c"
    if [ $choice -eq 2 ]; then
        cancel_install
    elif [ $choice -eq 0 ]; then
        available="rootonly"
        as_root="as root "
    else
        available="everyone"
        as_root=""
    fi
    echo
    if [ "$available" = "everyone" ]; then
        echo -e "  ${blk} By default, the Salomon installation directory is" \
                "writable only by root,"
        echo -e "    but you can give all users the permission to add, edit" \
                "and remove files"
        echo -e "    inside the color and filter sub-directories."
        echo
        echo -e "    However, granting such write permissions is" \
                "${cl_lr}not recommended${cl_n} unless there"
        echo -e "    is a specific reason to do so."
        echo
        confirm "    $dowant grant those permissions ($yesnocancel)? \c"
        if [ $choice -eq 2 ]; then
            cancel_install
        elif [ $choice -eq 1 ]; then
            allow_write=1
        fi
        echo
    fi
fi

if [ "$script_mode" = "install" ]; then
    if [ -d "$target_dir" ]; then
        echo -e "${cl_dc}Target directory${cl_n}"
        echo
        if [ ! "$script_dir" = "$target_dir" ]; then
            echo -e "  ${blk} The target directory '$target' already exists."
            echo
            echo -e "    You can ${cl_yl}either${cl_n} only ${cl_lg}install" \
                    "${cl_n}the program relevant files and keep all"
            echo -e "    configs and settings ${cl_yl}or${cl_n} perform a" \
                    "clean installation which will ${cl_lr}delete${cl_n}"
            echo -e "    the directory and ${cl_lg}reinstall${cl_n} the" \
                    "original files. Notice that latter will"
            echo -e "    also ${cl_lr}delete${cl_n} all user-defined" \
                    "configs and settings."
            echo
            echo -e "    If you want to ${cl_lg}update${cl_n} the installed" \
                    "version, choose ${cl_yl}N${cl_dy}o${cl_n} here."
            echo
            echo -e "    Nevertheless, it is recommended to backup the" \
                    "user-defined configs and"
            echo -e "    settings first."
            echo
            confirm \
              "    $dowant perform a clean installation ($yesnocancel)? \c"
            if [ $choice -eq 2 ]; then
                cancel_install
            else
                clean_install=$choice
            fi
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
                sleep 3
            fi
        fi
    fi

    if [ -n "$icon_path" ]; then
        echo -e "${cl_dc}Shared icons${cl_n}"
        echo
        echo -e "  ${blk} In case you want to create desktop shortcuts for" \
                "Salomon, it provides"
        echo -e "    its icon in multiple common sizes as well as in a" \
                "scalable image format."
        echo
        confirm "    $dowant install the icon files ($yesnocancel)? \c"
        if [ $choice -eq 2 ]; then
            cancel_install
        else
            install_icons=$choice
        fi
        echo
    fi

    if [ -d "$migrate_dir" ]; then
        echo -e "${cl_dc}Migration of BSD port configuration files${cl_n}"
        echo
        echo -e "  ${blk} The installation directory of Salomon-BSD" \
                "('${cl_yl}/opt/salomon-bsd${cl_n}')" \
                    "was found"
        echo -e "    on this system. You can migrate the config" \
                    "files (if existing) from"
        echo -e "    Salomon-BSD to Salomon."
        echo
        echo -e "    Before that, you should read section 6 inside the" \
                "documentation of this"
        echo -e "    script."
        echo
        echo -e "    The migration can also be performed later at another" \
                "time, so you do not"
        echo -e "    have to decide if it should be done now."
        echo
        confirm "    $dowant migrate the config files ($yesnocancel)? \c"
        if [ $choice -eq 2 ]; then
            cancel_install
        elif [ $choice -eq 1 ]; then
            migrate=1
        fi
        echo
    fi

    confirm \
      "Ready to ${script_action} Salomon. $dowish proceed ($yesno)? \c"
    if [ $choice -eq 0 ]; then
        echo
        echo -e "${cl_lr}Canceled${cl_n} on user request."
        echo
        exit
    fi
    echo

    echo -e "  → Installation directory is '${target}'."
    if [ $clean_install -eq 1 ]; then
        if [ "$(pwd)" = "$target_dir" ]; then
            echo "  → Removing previous data from installation directory..."
            rm -fR $target_dir/*
        else
            echo "  → Removing previous installation directory..."
            rm -fR $target_dir
        fi
    fi

    if [ ! -d $target_dir ]; then
        echo -e "  → Creating installation directory..."
        mkdir -p $target_dir &>/dev/null
    fi

    echo "  → Copying data to installation directory..."
    if [ -f "$target_dir/salomon.cfg" ]; then
        exclude_config="--exclude=salomon.cfg"
    fi

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

    if [ $migrate -eq 1 ]; then
        echo "  → Migrating config files from Salomon-BSD installation" \
             "directory..."
        rsync -a $migrate_dir/*.cfg $target_dir/ &>/dev/null
        rsync -a $migrate_dir/colors/* $target_dir/colors &>/dev/null
        rsync -a $migrate_dir/filters/*.cfg $target_dir/filters &>/dev/null
    fi

    if [ $install_icons -eq 1 ]; then
        echo "  → Copying icon files to shared directory..."
        for i in 16 24 32 48 64 96 128 256; do
            if [ ! -e "$script_dir/icons/png/salomon_${i}x${i}.png" ]; then
                continue
            fi

            if [ -d "$icon_path/${i}x${i}" ]; then
                rm -f $icon_path/${i}x${i}/apps/salomon.png
                rm -f $icon_path/${i}x${i}/apps/salomon-gray-border.png

                cp $script_dir/icons/png/salomon_${i}x${i}.png \
                   $icon_path/${i}x${i}/apps/salomon.png
                cp $script_dir/icons/png/salomon-gray-border_${i}x${i}.png \
                   $icon_path/${i}x${i}/apps/salomon-gray-border.png
            fi

            # This fixes a glitch from earlier versions where the icons were
            # copied into the improper directory
            rm -f $icon_path/${i}x${i}/salomon.png
        done

        if [ -d $icon_path_scalable ]; then
            rm -f $icon_path_scalable/salomon.svg \
                    $icon_path_scalable/salomon-gray-border.svg

            cp $script_dir/icons/svg/salomon.svg $icon_path_scalable/
            cp $script_dir/icons/svg/salomon-gray-border.svg \
                $icon_path_scalable/
        fi

        if [ -d $icon_path_xpm ]; then
            rm -f $icon_path_xpm/salomon.xpm \
                    $icon_path_xpm/salomon-gray-border.xpm

            cp $script_dir/icons/xpm/salomon.xpm $icon_path_xpm/
            cp $script_dir/icons/xpm/salomon-gray-border.xpm \
                $icon_path_xpm/
        fi

        command -v gtk-update-icon-cache &>/dev/null
        if [ $? -eq 0 ]; then
            gtk-update-icon-cache -q $icon_path
        fi
    fi

    echo -e "  → Setting permissions for installation directory... \c"
    if [ $available = "rootonly" ]; then
        echo -e "${cl_lb}(root only)${cl_n}"
    else
        if [ $allow_write -eq 0 ]; then
            echo -e "${cl_lb}(everyone, read-only)${cl_n}"
        else
            echo -e "${cl_lb}(everyone, allow write)${cl_n}"
        fi
    fi
    set_permissions

    if [ $clean_install -eq 1 ] || [ $migrate -eq 1 ]; then
        if [ -f ${symlink_sh}/salomon ]; then
            # This must also be done when migrating from Salomon-BSD to
            # Salomon, as the symbolic link points to '/opt/salomon-bsd'
            # instead of '/opt/salomon'.
            echo "  → Removing existing symbolic link for main script..."
            rm -f ${symlink_sh}/salomon &>/dev/null
        fi
    fi

    echo -e "  → Creating symbolic link for main script... \c"
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
        echo -e "  ${blk} The Salomon icon files and the symbolic link will" \
                "automatically be"
        echo -e "    deleted, but not the installation directory."
        echo
        echo -e "    You can ${cl_yl}either${cl_n} keep the installation" \
                "directory with all configs and"
        echo -e "    settings ${cl_yl}or${cl_n} completely remove it which" \
                "will also ${cl_lr}delete${cl_n} all files"
        echo -e "    including configs and settings."
        echo
        confirm "    $dowant remove it ($yesno)? \c"
        if [ $choice -eq 0 ]; then
            keep_directory=1
        fi
        echo
        confirm \
          "Ready to ${script_action} Salomon. $dowish proceed ($yesno)? \c"
        if [ $choice -eq 0 ]; then
            echo
            echo -e "${cl_lr}Canceled${cl_n} on user request."
            echo
            exit
        fi
        echo
    fi
    echo -e "  → Removing symbolic link for main script... \c"
    if [ -f ${symlink_sh}/salomon ]; then
        rm -f ${symlink_sh}/salomon &>/dev/null
        already_uninstalled=0
        echo
    else
        echo -e "${cl_lb}(does not exist)${cl_n}"
    fi

    echo -e "  → Removing icon files from shared directory... \c"
    icons_png="salomon\.png|salomon-gray-border\.png"
    icons_svg="salomon\.svg|salomon-gray-border\.svg"
    icons_installed=$(find $icon_path | grep -E "$icons_png|$icons_svg")
    if [ -n "$icons_installed" ]; then
        for i in $icons_installed; do
            rm -f $i
        done

        rm -f $icon_path_xpm/salomon.xpm
        rm -f $icon_path_xpm/salomon-gray-border.xpm

        already_uninstalled=0

        command -v gtk-update-icon-cache &>/dev/null
        if [ $? -eq 0 ]; then
            gtk-update-icon-cache -q $icon_path
        fi
        echo
    else
        echo -e "${cl_lb}(do not exist)${cl_n}"
    fi

    echo -e "  → Removing installation directory '${target}'... \c"
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

if [ "$script_mode" = "uninstall" ] && [ $already_uninstalled -eq 1 ]; then
    echo "Nothing to do, as Salomon was already uninstalled or not" \
         "installed before."
    echo
    exit
fi

if [ "$script_mode" = "install" ]; then
    echo -e "Salomon $(salomon --version) has been ${script_mode}ed."
    echo -e "You can now directly run the '${cl_yl}salomon${cl_n}' command" \
            "${as_root}in order to use it."
else
    echo -e "Salomon has been ${script_mode}ed."
fi
echo
