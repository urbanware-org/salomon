#!/bin/bash

salomon_script_dir=$(dirname $(readlink -f $0) | sed -e "s/testrun//g")
salomon_script="$salomon_script_dir/salomon.sh"
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
$salomon_script $salomon_args -f "2014" -hm
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
$salomon_script $salomon_args -f "2014" -hm --no-info
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
$salomon_script $salomon_args -f "2014" -ha
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
$salomon_script $salomon_args -f "2014" -ha --cut-off
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
$salomon_script $salomon_args -f "config file" -hm -ic
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
$salomon_script $salomon_args -f "config file" -hu -ic
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
$salomon_script $salomon_args -f "config;file;success;foo" -hm -ic
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
$salomon_script $salomon_args -e "process"
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
$salomon_script $salomon_args -r "2014-04-02 "
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
$salomon_script $salomon_args -h 4
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
$salomon_script $salomon_args -t 4
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
$salomon_script -i $salomon_sample_log --analyze --pause 4
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

clear
echo "==" >> $salomon_sample_log_temp
echo "==  Please press Ctrl+C now once to  cancel  this test (required)." \
     >> $salomon_sample_log_temp
echo "==" >> $salomon_sample_log_temp
$salomon_script --monitor -i $salomon_sample_log_temp \
                -f "2014; cancel ;=" \
                -c $salomon_sample_colors -hu -ic --prompt -t 14
if [ $? -ne 2 ]; then salomon_status=$(( salomon_status + 1 )); fi

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
exit $salomon_status
