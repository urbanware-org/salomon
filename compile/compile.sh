#!/usr/bin/env bash

#
# Salomon - Simple log file monitor and analyzer
# Binary compiler script
# Copyright (c) 2024 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

if [ -f "../core/global.sh" ]; then
    source ../core/global.sh
else
    source core/global.sh
fi
set_global_variables

if [ ! -x "$(command -v shc)" ]; then
    echo -e "${cl_lr}error:${cl_n} Generic shell script compiler 'shc'" \
            "cannot be found"
    exit 1
elif [ ! -f "salomon.sh" ]; then
    echo -e "${cl_lr}error:${cl_n} File 'salomon.sh' does not exist in the" \
            "current directory"
    exit 1
fi

echo -e "${cl_lc}Salomon $version binary compiler${cl_n}"

echo "  - Merging core modules..."
echo '#!/bin/bash' > salobin.sh
cat core/global.sh      | grep -v "^#" \
                        | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/colors.sh      | grep -v "^#" \
                        | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/common.sh      | grep -v "^#" \
                        | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/analyze.sh     | grep -v "^#" \
                        | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/monitor.sh     | grep -v "^#" \
                        | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/interactive.sh | grep -v "^#" \
                        | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/dialogs.sh     | grep -v "^#" \
                        | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/compat.sh      | grep -v "^#" \
                        | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/shell.sh       | grep -v "^#" \
                        | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/output.sh      | grep -v "^#" \
                        | grep -v "source \${script_dir}/core" >> salobin.sh

echo "  - Appending main script..."
cat salomon.sh          | grep -v "^#" | grep -v "\${script_dir}/core" \
                        | grep -v "compatib" >> salobin.sh

echo "  - Compiling..."
shc -f salobin.sh -o salomon
if [ $? -eq 0 ]; then
    chmod +x salomon
    echo -e "${cl_lg}Finished.${cl_n}"
else
    echo -e "${cl_lr}error:${cl_n} Compiling failed with return value $?"
fi
rm -f salobin*

