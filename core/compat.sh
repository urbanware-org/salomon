#
# Salomon - Simple log file monitor and analyzer
# Compatibility check core script
# Copyright (C) 2021 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

compatibility_check() {
    script_file=$(basename "$0")
    script_temp="$(dirname $(mktemp -u --tmpdir))/salomon_compat.sh"
    source ${script_dir}/core/common.sh
    source ${script_dir}/core/global.sh
    set_global_variables

    failure="${cl_lr}FAILURE${cl_n}"
    missing="${cl_yl}MISSING${cl_n}"
    success="${cl_lg}SUCCESS${cl_n}"

    check_basename="$failure"
    check_bash_major="$failure"
    check_declare="$failure"
    check_dialog="$missing"
    check_dirname="$failure"
    check_grep="$failure"
    check_kernel="$failure"
    check_less="$missing"
    check_paste="$failure"
    check_printf="$failure"
    check_readlink="$failure"
    check_rsync="$missing"
    check_sed="$failure"
    check_tail="$failure"
    check_tput="$failure"
    check_trap="$failure"
    check_wget="$missing"
    check_whiptail="$missing"
    check_echo="$success"
    check_function="$failure"
    check_failed=0
    check_missing=0
    check_overall="$failure"
    line="................"

    kernel_name=$(uname -s | tr '[:upper:]' '[:lower:]')
    if [[ $kernel_name =~ linux ]]; then
        check_kernel="$success"
    else
        check_failed=1
    fi

    bash_major=$(sed -e "s/\..*//g" <<< $BASH_VERSION)
    if [ $bash_major -ge 4 ]; then
        check_bash_major="$success"
    else
        check_failed=1
    fi

    command -v basename &>/dev/null
    if [ $? -eq 0 ]; then
        check_basename="$success"
    else
        check_failed=1
    fi

    command -v declare &>/dev/null
    if [ $? -eq 0 ]; then
        check_declare="$success"
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

    command -v trap &>/dev/null
    if [ $? -eq 0 ]; then
        check_trap="$success"
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

    echo "#!${BASH}" > $script_temp
    echo "foobar() {" >> $script_temp
    echo "    echo \"foobar\"" >> $script_temp
    echo "}" >> $script_temp
    chmod +x $script_temp
    $script_temp &>/dev/null
    if [ $? -eq 0 ]; then
        check_function="$success"
    else
        check_failed=1
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

# EOF
