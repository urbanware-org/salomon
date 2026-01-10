#
# Salomon - Simple log file monitor and analyzer
# Compatibility check script
# Copyright (c) 2025 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

script_dir="$(dirname "$(readlink -f "$0")")"
. "${script_dir}/core/shell.sh"  # use POSIX standard instead of 'source' here
shell_precheck

if [[ "$script_dir" = *[[:space:]]* ]]; then
    echo -e \
        "\e[91merror:\e[0m" \
        "Salomon and its components cannot be run from a path that" \
        "contains spaces."
    exit 10
fi

init_compat=1
shell_precheck_compat

source ${script_dir}/core/common.sh
source ${script_dir}/core/compat.sh
source ${script_dir}/core/global.sh
compatibility_check

echo
echo -e "${cl_lc}Salomon compatibility check script${cl_n}"
echo
echo -e "Checking Bash shell (version 4.3 or higher required) .$line" \
        "${check_bash_version}"
echo
echo -e "Checking 'basename' command ..........................$line" \
        "${check_basename}"
echo -e "Checking 'dirname' command ...........................$line" \
        "${check_dirname}"
echo -e "Checking 'grep' command ..............................$line" \
        "${check_grep}"
echo -e "Checking 'paste' command .............................$line" \
        "${check_printf}"
echo -e "Checking 'printf' command ............................$line" \
        "${check_printf}"
echo -e "Checking 'readlink' command ..........................$line" \
        "${check_readlink}"
echo -e "Checking 'sed' command ...............................$line" \
        "${check_sed}"
echo -e "Checking 'tail' command ..............................$line" \
        "${check_tail}"
echo -e "Checking 'tput' command (part of 'ncurses') ..........$line" \
        "${check_tput}"
echo
echo -e "Checking optional 'dialog' command ...................$line" \
        "${check_dialog}"
echo -e "Checking optional 'less' command .....................$line" \
        "${check_less}"
echo -e "Checking optional 'rsync' command ....................$line" \
        "${check_rsync}"
echo -e "Checking optional 'wget' command .....................$line" \
        "${check_wget}"
echo -e "Checking optional 'whiptail' command .................$line" \
        "${check_whiptail}"
echo
echo -e "Overall status .......................................$line" \
        "${check_overall}"
echo

exit $return_code
