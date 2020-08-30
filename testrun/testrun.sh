#!/usr/bin/env bash

#
# Salomon - Simple log file monitor and analyzer
# Simple testrun script
# Copyright (C) 2020 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
#

salomon_script_dir=$(dirname $(readlink -f $0) | sed -e "s/testrun//g")
salomon_script="$salomon_script_dir/salomon.sh"
salomon_testrun_log="/tmp/salomon_testrun_$$.log"
salomon_sample_log="$salomon_script_dir/samples/foobar.log"
salomon_sample_colors="$salomon_script_dir/colors/log_colors.cfg"
salomon_sample_log="$salomon_script_dir/samples/foobar.log"
salomon_sample_log_temp="/tmp/salomon_foobar.log"
salomon_args="-i $salomon_sample_log -c $salomon_sample_colors --analyze"
salomon_status=0
cp -f $salomon_sample_log $salomon_sample_log_temp

echo
echo "Starting automated tests. Please wait."
echo
sleep 1

clear
echo "Step  1 of 13"
$salomon_script $salomon_args -f "2014" -hm | tee $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
echo "Step  2 of 13"
echo
$salomon_script $salomon_args -f "2014" -hm --no-info \
    | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
echo "Step  3 of 13"
$salomon_script $salomon_args -f "2014" -ha | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
echo "Step  4 of 13"
$salomon_script $salomon_args -f "2014" -ha --cut-off \
    | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
echo "Step  5 of 13"
$salomon_script $salomon_args -f "config file" -hm -ic \
    | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
echo "Step  6 of 13"
$salomon_script $salomon_args -f "config file" -hu -ic \
    | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
echo "Step  7 of 13"
$salomon_script $salomon_args -f "config;file;success;foo" -hm -ic \
    | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
echo "Step  8 of 13"
$salomon_script $salomon_args -e "process" | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
echo "Step  9 of 13"
$salomon_script $salomon_args -r "2014-04-02 " | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
echo "Step 10 of 13"
$salomon_script $salomon_args -h 4 | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
echo "Step 11 of 13"
$salomon_script $salomon_args -t 4 | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
echo "Step 12 of 13"
$salomon_script -i $salomon_sample_log --analyze --pause 4 \
    | tee -a $salomon_testrun_log
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
echo "Step 13 of 13"
echo "==" >> $salomon_sample_log_temp
echo "==  Please press Ctrl+C now once to  cancel  this test (required)." \
     >> $salomon_sample_log_temp
echo "==" >> $salomon_sample_log_temp
$salomon_script --monitor -i $salomon_sample_log_temp \
                -f "2014; cancel ;=" \
                -c $salomon_sample_colors -hu -ic --prompt -t 14 \
                | tee -a $salomon_testrun_log
if [ $? -ne 130 ]; then salomon_status=$(( salomon_status + 1 )); fi

echo >> $salomon_testrun_log
rm -f $salomon_sample_log_temp
clear
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
echo -e "For details see the file \e[96m$salomon_testrun_log\e[0m."
echo
exit $salomon_status

# EOF
