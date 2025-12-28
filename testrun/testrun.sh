#!/usr/bin/env bash

#
# Salomon - Simple log file monitor and analyzer
# Simple testrun script
# Copyright (c) 2025 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

space() {
    for i in {1..3}; do
        echo >> $salomon_testrun_log
    done
}

step_output() {
    if [ $1 -lt 10 ]; then
        step=" $1"
    else
        step="$1"
    fi
    echo "Step $step of $2"
    echo "Step $step of $2" >> $salomon_testrun_log
}

if [ "$1" = "--debug" ]; then
    debug=1
else
    debug=0
fi

salomon_script_dir=$(dirname $(readlink -f $0) | sed -e "s/testrun//g")
salomon_script="$salomon_script_dir/salomon.sh"

source $salomon_script_dir/core/global.sh
set_global_variables

if [ $is_bsd -eq 1 ]; then
    temp_dir="$(dirname $(mktemp -u))"
else
    temp_dir="$(dirname $(mktemp -u --tmpdir))"
fi

salomon_testrun_log="$temp_dir/salomon_testrun_$$.log"
salomon_sample_log="$salomon_script_dir/samples/foobar.log"
salomon_sample_colors="$salomon_script_dir/colors/log_colors.cfg"
salomon_sample_log="$salomon_script_dir/samples/foobar.log"
salomon_sample_log_temp="$temp_dir/salomon_foobar.log"
salomon_args="-i $salomon_sample_log -c $salomon_sample_colors --analyze"
salomon_status=0
cp -f $salomon_sample_log $salomon_sample_log_temp

echo
echo "Starting automated tests. Please wait."
echo
sleep 1

if [ $debug -ne 1 ]; then clear; fi
step_output 1 13
echo "$salomon_args -f \"2014\" -hm" \
     >> $salomon_testrun_log
$salomon_script $salomon_args -f "2014" -hm | tee $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi
space

if [ $debug -ne 1 ]; then clear; fi
step_output 2 13
echo "salomon.sh $salomon_args -f \"2014\" -hm --no-info" \
     >> $salomon_testrun_log
echo >> $salomon_testrun_log
echo
$salomon_script $salomon_args -f "2014" -hm --no-info \
    | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi
echo >> $salomon_testrun_log
space

if [ $debug -ne 1 ]; then clear; fi
step_output 3 13
echo "salomon.sh $salomon_args -f \"2014\" -ha" \
     >> $salomon_testrun_log
$salomon_script $salomon_args -f "2014" -ha | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi
space

if [ $debug -ne 1 ]; then clear; fi
step_output 4 13
echo "salomon.sh $salomon_args -f \"2014\" -ha --cut-off" \
     >> $salomon_testrun_log
$salomon_script $salomon_args -f "2014" -ha --cut-off \
    | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi
space

if [ $debug -ne 1 ]; then clear; fi
step_output 5 13
echo "salomon.sh $salomon_args -f \"config file\" -hm -ic" \
     >> $salomon_testrun_log
$salomon_script $salomon_args -f "config file" -hm -ic \
    | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi
space

if [ $debug -ne 1 ]; then clear; fi
step_output 6 13
echo "salomon.sh $salomon_args -f \"config file\" -hu -ic" \
     >> $salomon_testrun_log
$salomon_script $salomon_args -f "config file" -hu -ic \
    | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi
space

if [ $debug -ne 1 ]; then clear; fi
step_output 7 13
echo "salomon.sh $salomon_args -f \"config;file;success;foo\" -hm -ic" \
     >> $salomon_testrun_log
$salomon_script $salomon_args -f "config;file;success;foo" -hm -ic \
    | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi
space

if [ $debug -ne 1 ]; then clear; fi
step_output 8 13
echo "salomon.sh $salomon_args -e \"process\"" \
     >> $salomon_testrun_log
$salomon_script $salomon_args -e "process" | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi
space

if [ $debug -ne 1 ]; then clear; fi
step_output 9 13
echo "salomon.sh $salomon_args -r \"2024-04-02\"" \
     >> $salomon_testrun_log
$salomon_script $salomon_args -r "2014-04-02 " | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi
space

if [ $debug -ne 1 ]; then clear; fi
step_output 10 13
echo "salomon.sh $salomon_args -h 4" \
     >> $salomon_testrun_log
$salomon_script $salomon_args -h 4 | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi
space

if [ $debug -ne 1 ]; then clear; fi
step_output 11 13
echo "salomon.sh $salomon_args -t 4" \
     >> $salomon_testrun_log
$salomon_script $salomon_args -t 4 | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi
space

if [ $debug -ne 1 ]; then clear; fi
step_output 12 13
echo "salomon.sh $salomon_args --analyze --pause 4" \
     >> $salomon_testrun_log
$salomon_script -i $salomon_sample_log --analyze --pause 4 \
    | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi
space

if [ $debug -ne 1 ]; then clear; fi
step_output 13 13
echo "==" >> $salomon_sample_log_temp
echo "==  Please press Ctrl+C now once to  cancel  this test (required)." \
     >> $salomon_sample_log_temp
echo "==" >> $salomon_sample_log_temp
echo "salomon.sh --monitor -i $salomon_sample_log_temp " \
                "-f \"2014; cancel ;=\ " \
                "-c $salomon_sample_colors -hu -ic --prompt -t 14" \
     >> $salomon_testrun_log
$salomon_script --monitor -i $salomon_sample_log_temp \
                -f "2014; cancel ;=" \
                -c $salomon_sample_colors -hu -ic --prompt -t 14 \
                | tee -a $salomon_testrun_log
if [ $? -ne 130 ]; then salomon_status=$(( salomon_status + 1 )); fi
space

echo >> $salomon_testrun_log
echo
rm -f $salomon_sample_log_temp
if [ $debug -ne 1 ]; then clear; fi
echo -e "\e[93m\c"
echo ' _____         _                           _        _             '
echo '|_   _|__  ___| |_ _ __ _   _ _ __     ___| |_ __ _| |_ _   _ ___ '
echo \
 '  | |/ _ \/ __| __| '\''__| | | | '\''_ \   / __| __/ _'\'' | __| | | / __|'
echo '  | |  __/\__ \ |_| |  | |_| | | | |  \__ \ || (_| | |_| |_| \__ \'
echo '  |_|\___||___/\__|_|   \__,_|_| |_|  |___/\__\__,_|\__|\__,_|___/'
echo -e "\e[0m"
echo "  Testrun finished."
if [ $salomon_status -eq 0 ]; then
    echo -e "  Overall status: \e[92mSuccessfully passed\e[0m"
else
    echo -e "  Overall status: \e[91mFailed\e[0m (at least one test)"
fi
echo
echo -e "\e[0mFor details see the file \e[96m$salomon_testrun_log\e[0m."
echo
exit $salomon_status
