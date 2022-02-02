#
# Salomon - Simple log file monitor and analyzer
# Bash pre-check core script
# Copyright (c) 2021 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

shell_precheck() {
    command -v bash >/dev/null 2>&1
    if [ "$?" != "0" ]; then
        cat <<- end

Salomon cannot be run.

The reason is that the required Bash shell does not seem to be installed. For
Salomon, the Bash shell is a mandatory dependency and so it will not work
without it.

No matter which shell you are using, the Bash shell (version 4 or higher) must
be installed in order to use Salomon as it takes advantage of certain features
provided by the Bash shell.

end
        exit 1
    elif [ ! -n "$BASH" ]; then
        cat <<- end

Salomon cannot be run.

All scripts must be executed using the required Bash shell and this one has
determined that it was executed with a different one (maybe explicitly) which
is not supported. Please run the compatibility check script ('compat.sh') for
details.

end
        exit 1
    else
        bash_version=$(sed -e "s/-.*//g" <<< $BASH_VERSION)
        bash_major=$(sed -e "s/\..*//g" <<< $bash_version)
        if [ $bash_major -lt 4 ]; then
            cat <<- end

Salomon cannot be run.

The reason is that it requires at least version 4 of the Bash shell. The
currently installed version is $bash_version which is not supported. Please
run the compatibility check script ('compat.sh') for details.

end
            exit 1
        fi
    fi
}

shell_precheck_compat() {
    command -v bash >/dev/null 2>&1
    if [ "$?" != "0" ]; then
        cat <<- end

Salomon cannot be run.

The reason is that the required Bash shell does not seem to be installed. For
Salomon, the Bash shell is a mandatory dependency and so it will not work
without it.

No matter which shell you are using, the Bash shell (version 4 or higher) must
be installed in order to use Salomon as it takes advantage of certain features
provided by the Bash shell.

end
        exit 1
    elif [ ! -n "$BASH" ]; then
        cat <<- end

Salomon cannot be run.

All scripts must be executed using the required Bash shell and this one has
determined that it was executed with a different one (maybe explicitly) which
is not supported. Please run the compatibility check script ('compat.sh') for
details.

end
        exit 1
    fi
}

# EOF
