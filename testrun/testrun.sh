#!/bin/bash

salomon_script_dir=$(dirname $(readlink -f $0) | sed -e "s/testrun//g")
salomon_script="$salomon_script_dir/salomon.sh"
salomon_sample_log="$salomon_script_dir/samples/foobar.log"
salomon_sample_colors="$salomon_script_dir/colors/log_colors.cfg"
salomon_sample_log="$salomon_script_dir/samples/foobar.log"
salomon_args="-i $salomon_sample_log -c $salomon_sample_colors --analyze"
salomon_status=0

echo
echo "Starting automated tests. Please wait."
echo
sleep 3

$salomon_script --color-table
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

$salomon_script $salomon_args -f "2014" -hm --no-info
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

$salomon_script $salomon_args -f "2014" -ha
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

$salomon_script $salomon_args -f "2014" -ha --cut-off
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

$salomon_script $salomon_args -f "config file" -hm -ic
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

$salomon_script $salomon_args -f "config file" -hu -ic
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

$salomon_script $salomon_args -e "config file"
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

$salomon_script $salomon_args -r "2014-04-02"
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

$salomon_script $salomon_args -h 4
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

$salomon_script $salomon_args -t 4
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

$salomon_script $salomon_args --slow --delay 10
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

echo
echo "Starting interactive test for monitoring ('--monitor')."
echo
echo "After the log lines have been printed, cancel the process using" \
     "Ctrl+C and"
echo "confirm the exit prompt."
echo
echo "Press the Return key to proceed."
read

$salomon_script --monitor -i $salomon_sample_log -c $salomon_sample_colors \
                -f "2014" -hu -ic --prompt -t 12
if [ $? -ne 2 ]; then salomon_status=$(( salomon_status + 1 )); fi

echo
echo "Starting interactive test for paused output ('--pause')."
echo
echo "After printing 4 lines there will be a pause which must be skipped" \
     "manually."
echo
echo "Press the Return key to proceed."
read

$salomon_script -i $salomon_sample_log --analyze --pause 4
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

echo
echo "Starting interactive test for interactive dialogs ('--interactive')."
echo
echo "For this test, simply confirm each of the dialogs."
echo
echo "Press the Return key to proceed."
read

$salomon_script $salomon_args -f "2014" -r "-02" -hu -ic \
                              --interactive
if [ $? -ne 0 ]; then salomon_status=$(( salomon_status + 1 )); fi

echo
echo ' _____         _                           _        _             '
echo '|_   _|__  ___| |_ _ __ _   _ _ __     ___| |_ __ _| |_ _   _ ___ '
echo '  | |/ _ \/ __| __| ´__| | | | ´_ \   / __| __/ _` | __| | | / __|'
echo '  | |  __/\__ \ |_| |  | |_| | | | |  \__ \ || (_| | |_| |_| \__ \'
echo '  |_|\___||___/\__|_|   \__,_|_| |_|  |___/\__\__,_|\__|\__,_|___/'
echo
echo "Testrun finished."
if [ $salomon_status -eq 0 ]; then
    echo "Overall status: Successfully passed"
else
    echo "Overall status: Failed (at least one test)"
fi
echo
