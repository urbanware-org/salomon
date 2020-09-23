#
# Salomon - Simple log file monitor and analyzer
# Bash pre-check core script
# Copyright (C) 2020 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

shell_precheck() {
    command -v bash >/dev/null 2>&1
    if [ "$?" != "0" ]; then
        echo "error: The Bash shell does not seem to be installed, run the" \
                    "compatibility"
        echo "       script ('compat.sh') for details."
        exit 1
    elif [ ! -n "$BASH" ]; then
        echo "error: This script must be executed using the Bash shell, run" \
             "the"
        echo "       compatibility script ('compat.sh') for details."
        exit 1
    else
        bash_major=$(sed -e "s/\..*//g" <<< $BASH_VERSION)
        if [ $bash_major -lt 4 ]; then
            echo "error: This script requires at least version 4 of the " \
                        "Bash shell, run the"
            echo "       compatibility script ('compat.sh') for details."
            exit 1
        fi
    fi
}

shell_precheck_compat() {
    separator="***************************************"
    command -v bash >/dev/null 2>&1
    if [ "$?" != "0" ]; then
        echo
        echo "${separator}${separator}"
        echo "* This script has determined that the Bash shell (which is" \
             "required) does    *"
        echo "* not seem to be installed.                                  " \
             "               *"
        echo "*                                                            " \
             "               *"
        echo "* The Salomon project was developed on (and for) the Bash" \
             "shell, which is    *"
        echo "* the default shell on many Unix-like systems (or at least on" \
            "many Linux     *"
        echo "* distributions).                                            " \
             "               *"
        echo "*                                                            " \
             "               *"
        echo "* No matter which shell you are using, the Bash shell must be" \
             "installed in   *"
        echo "* order to use Salomon. As a matter of fact, the Salomon" \
             "project takes       *"
        echo "* advantage of certain features provided by the Bash shell." \
             "                 *"
        echo "${separator}${separator}"
        echo
        exit 1
    elif [ ! -n "$BASH" ]; then
        echo
        echo "${separator}${separator}"
        echo "* This script has determined that it has not been executed" \
             "using the Bash    *"
        echo "* shell, but (maybe explicitly) with another one which is not" \
             "supported.     *"
        echo "*                                                            " \
             "               *"
        echo "* The Salomon project was developed on (and for) the Bash" \
             "shell, which is    *"
        echo "* the default shell on many Unix-like systems (or at least on" \
            "many Linux     *"
        echo "* distributions).                                            " \
             "               *"
        echo "*                                                            " \
             "               *"
        echo "* No matter which shell you are using, the Bash shell" \
             "(version 4 or higher)  *"
        echo "* must be installed in order to use Salomon, as the project" \
             "takes advantage  *"
        echo "* of certain features provided by the Bash shell." \
             "                           *"
        echo "${separator}${separator}"
        echo
        exit 1
    fi
}

# EOF
