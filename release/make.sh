#!/usr/bin/env bash

#
# Salomon - Simple log file monitor and analyzer
# Release builder script
# Copyright (C) 2021 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

source ../core/global.sh
set_global_variables

script_dir=$(dirname $(readlink -f $0))
salomon_dir=$(sed -e "s/\/release$//g" <<< $script_dir)
salomon_version="salomon-$version"
temp_dir="/tmp/salomon"

echo "Preparing release data..."
rm -f $salomon_version.tar.gz
rm -fR $temp_dir
mkdir -p $temp_dir
rsync -a $salomon_dir $temp_dir

echo "Removing non-relevant directories..."
for dir in $git_clone; do
    rm -fR $temp_dir/salomon/$dir &>/dev/null
done

echo "Removing non-relevant files..."
for markdown in $(find $temp_dir | grep "\.md$"); do
    rm -f $markdown
done

echo "Creating Salomon $version release archive..."
mv $temp_dir/salomon $temp_dir/$salomon_version
tar czf $salomon_version.tar.gz -C $temp_dir .

echo "Finished (created '$salomon_version.tar.gz')."
rm -fR $temp_dir

# EOF
