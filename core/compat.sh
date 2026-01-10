#
# Salomon - Simple log file monitor and analyzer
# Compatibility check core script
# Copyright (c) 2025 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

source ${script_dir}/core/common.sh
source ${script_dir}/core/global.sh
set_global_variables

compatibility_check() {
    if [ $is_bsd -eq 1 ]; then
        script_temp="$(dirname $(mktemp -u))/salomon_compat.sh"
    else
        script_temp="$(dirname $(mktemp -u --tmpdir))/salomon_compat.sh"
    fi

    failure="${cl_lr}FAILURE${cl_n}"
    missing="${cl_yl}MISSING${cl_n}"
    success="${cl_lg}SUCCESS${cl_n}"

    check_basename="$failure"
    check_bash_version="$failure"
    check_dialog="$missing"
    check_dirname="$failure"
    check_grep="$failure"
    check_less="$missing"
    check_paste="$failure"
    check_printf="$failure"
    check_readlink="$failure"
    check_rsync="$missing"
    check_sed="$failure"
    check_tail="$failure"
    check_tput="$failure"
    check_wget="$missing"
    check_whiptail="$missing"
    check_failed=0
    check_missing=0
    check_overall="$failure"
    line="................"

    bash_major=${BASH_VERSINFO[0]}
    bash_minor=${BASH_VERSINFO[1]}  # relevant for major version 4, only

    if (( bash_major >= 5 )); then
        check_bash_version="$success"
    elif (( bash_major < 4 )); then
        check_failed=1
    elif (( bash_major == 4 && bash_minor >= 3 )); then
        check_bash_version="$success"
    else
        check_failed=1
    fi

    command -v basename &>/dev/null
    if [ $? -eq 0 ]; then
        check_basename="$success"
    else
        check_failed=1
    fi

    command -v dialog &>/dev/null
    if [ $? -eq 0 ]; then
        check_dialog="$success"
    else
        check_missing=1
    fi

    command -v dirname &>/dev/null
    if [ $? -eq 0 ]; then
        check_dirname="$success"
    else
        check_failed=1
    fi

    command -v grep &>/dev/null
    if [ $? -eq 0 ]; then
        check_grep="$success"
    else
        check_failed=1
    fi

    command -v less &>/dev/null
    if [ $? -eq 0 ]; then
        check_less="$success"
    else
        check_missing=1
    fi

    command -v paste &>/dev/null
    if [ $? -eq 0 ]; then
        check_paste="$success"
    else
        check_failed=1
    fi

    command -v printf &>/dev/null
    if [ $? -eq 0 ]; then
        check_printf="$success"
    else
        check_failed=1
    fi

    command -v readlink &>/dev/null
    if [ $? -eq 0 ]; then
        check_readlink="$success"
    else
        check_failed=1
    fi

    command -v rsync &>/dev/null
    if [ $? -eq 0 ]; then
        check_rsync="$success"
    else
        check_missing=1
    fi

    command -v sed &>/dev/null
    if [ $? -eq 0 ]; then
        check_sed="$success"
    else
        check_failed=1
    fi

    command -v tail &>/dev/null
    if [ $? -eq 0 ]; then
        check_tail="$success"
    else
        check_failed=1
    fi

    command -v tput &>/dev/null
    if [ $? -eq 0 ]; then
        check_tput="$success"
    else
        check_failed=1
    fi

    command -v wget &>/dev/null
    if [ $? -eq 0 ]; then
        check_wget="$success"
    else
        check_missing=1
    fi

    command -v whiptail &>/dev/null
    if [ $? -eq 0 ]; then
        check_whiptail="$success"
    else
        check_missing=1
    fi

    if [ $check_failed -eq 0 ]; then
        check_overall="$success"
        if [ $check_missing -eq 0 ]; then
            return_code=0
        else
            return_code=3
        fi
    else
        check_overall="$failure"
        return_code=2
    fi

    rm -f $script_temp
}

compatibility_precheck() {
    compatibility_check
    if [ $return_code -ne 0 ] && [ $return_code -ne 3 ]; then
        cat <<- end

Salomon cannot be started because at least one of its required dependencies is
missing. Please run the compatibility check script ('compat.sh') for details.

end
        exit 1
    fi
}
