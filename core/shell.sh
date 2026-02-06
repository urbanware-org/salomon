#!/usr/bin/env bash

#
# Salomon - Simple log file monitor and analyzer
# Bash pre-check core script
# Copyright (c) 2026 by Ralf Kilian
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
