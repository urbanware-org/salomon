#!/usr/bin/env bash

#
# Salomon - Simple log file monitor and analyzer
# Binary compiler script
# Copyright (c) 2025 by Ralf Kilian
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
echo '#!/bin/bash'          >  salomon_merge.sh
cat core/global.sh          >> salomon_merge.sh
cat core/colors.sh          >> salomon_merge.sh
cat core/common.sh          >> salomon_merge.sh
cat core/analyze.sh         >> salomon_merge.sh
cat core/monitor.sh         >> salomon_merge.sh
cat core/interactive.sh     >> salomon_merge.sh
cat core/dialogs.sh         >> salomon_merge.sh
cat core/shell.sh           >> salomon_merge.sh
cat core/output.sh          >> salomon_merge.sh

echo "  - Appending main script..."
cat salomon.sh              >> salomon_merge.sh

echo "  - Preparing code..."
cat salomon_merge.sh | grep -v "source \${script_dir}/core" \
                     | grep -v "\${script_dir}/core" \
                     | grep -v "compatib" \
                     > salomon_prep.sh

echo "  - Compiling..."
shc -f salomon_prep.sh -o salomon
if [ $? -eq 0 ]; then
    chmod +x salomon
    echo -e "${cl_lg}Finished.${cl_n}"
else
    echo -e "${cl_lr}error:${cl_n} Compiling failed with return value $?"
fi
rm -f salomon_*

echo -e "Notice that ${cl_yl}compiling only served as a test${cl_n}." \
        "See ${cl_lc}README.md${cl_n} for details."
