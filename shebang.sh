# ============================================================================
# SaLoMon - Simple log file monitor and analyzer
# Shebang adjustment script
# Copyright (C) 2019 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/salomon
# GitLab: https://gitlab.com/urbanware-org/salomon
# ============================================================================

# Pre-check if the Bash shell is installed and if this script has been
# executed using it
command -v bash >/dev/null 2>&1
if [ "$?" != "0" ]; then
    echo "error: The Bash shell does not seem to be installed, run the"\
                "compatibility"
    echo "       script ('compat.sh') for details."
    exit 1
elif [ ! -n "$BASH" ]; then
    echo "error: This script must be executed using the Bash shell, run the"
    echo "       compatibility script ('compat.sh') for details."
    exit 1
fi

script_dir=$(dirname $(readlink -f $0))
temp_file_list="$(dirname $(mktemp -u))/salomon_file_list.tmp"
temp_file_shebang="$(dirname $(mktemp -u))/salomon_shebang.tmp"

echo "Adjusting shebang to '#!$BASH'."
find $script_dir -type f | grep "\.sh$" > $temp_file_list
while read line; do
    sed -e "s#\#\!\/.*#\#\!$BASH#g" < $line > $temp_file_shebang
    cat $temp_file_shebang > $line
done < $temp_file_list

rm -f $temp_file_list
rm -f $temp_file_shebang

# EOF
