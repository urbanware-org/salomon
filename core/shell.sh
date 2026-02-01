#
# Salomon - Simple log file monitor and analyzer
# Bash pre-check core script
# Copyright (c) 2025 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

shell_precheck() {
    bash_version=$(sed -e "s/-.*//g" <<< $BASH_VERSION)
    bash_major=$(sed -e "s/\..*//g" <<< $bash_version)
    if [ $bash_major -lt 4 ]; then
        cat <<- end

Salomon cannot be run.

The reason for this is that it requires at least version 4.3 of the Bash shell
and the currently installed version is $bash_version which is not supported.

You may run the compatibility check script ('compat.sh') for details.

end
            exit 1
    fi
}

shell_precheck_compat() {
    command -v bash >/dev/null 2>&1
    if [ "$?" != "0" ]; then
        cat <<- end

Salomon cannot be run.

The reason for this is that the Bash shell does not seem to be installed. For
Salomon, the Bash shell is a mandatory dependency and so it will not work
without it.

No matter which shell you are using, the Bash shell (version 4 or higher) must
be installed in order to use Salomon as it takes advantage of certain features
provided by the Bash shell.

end
        exit 1
    elif [ ! -n "$BASH" ]; then
        if [ "$init_compat" = "1" ]; then
            cat <<- end

Salomon cannot be run.

The reason for this is that all of its components require the Bash shell in
order to run and this script has determined that it was (maybe explicitly)
executed with a different one which is not supported.

You may run 'echo \$0' (without any quotes) to get further information which
shell you are currently using.

end
        else
            cat <<- end

Salomon cannot be run.

The reason is that all of its components require the Bash shell in order to
run and this script has determined that it was (maybe explicitly) executed
with a different one which is not supported.

You may run the compatibility check script ('compat.sh') for details.

end
        fi
        exit 1
    fi
}
