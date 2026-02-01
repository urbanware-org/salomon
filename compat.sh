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

bash_installed=0
command -v bash >/dev/null 2>&1
if [ "$?" = "0" ]; then
    bash_installed=1
fi

if [ $bash_installed -eq 0 ]; then
    cat <<- end

Salomon cannot be run.

The Bash shell does not seem to be installed. For Salomon, the Bash shell is a
mandatory dependency and so it will not work without it.

No matter which shell you are using, the Bash shell (version 4.3 or higher)
must be installed in order to use Salomon as it takes advantage of certain
features provided by the Bash shell.

end
    exit 1
else
    if [ -z "$BASH" ]; then
        cat <<- end

The compatibility check script must be run explicitly using the Bash shell.
Please start it with the following command:

    bash compat.sh

end
        exit 4
    fi
fi

source "${script_dir}/core/shell.sh"
shell_precheck

if [[ "$script_dir" = *[[:space:]]* ]]; then
    echo -e \
        "\e[91merror:\e[0m" \
        "Salomon and its components cannot be run from a path that" \
        "contains spaces."
    exit 10
fi

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
