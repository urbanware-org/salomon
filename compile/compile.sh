#!/bin/bash

if [ ! -x "$(command -v shc)" ]; then
    echo "error: Generic shell script compiler 'shc' cannot be found"
    exit 1
elif [ ! -f "salomon.sh" ]; then
    echo "error: File 'salomon.sh' does not exist in the current directory"
    exit 1
fi

echo "Merging core modules..."
echo '#!/bin/bash' > salobin.sh
cat core/global.sh      | grep -v "^#" | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/colors.sh      | grep -v "^#" | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/common.sh      | grep -v "^#" | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/analyze.sh     | grep -v "^#" | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/monitor.sh     | grep -v "^#" | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/interactive.sh | grep -v "^#" | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/dialogs.sh     | grep -v "^#" | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/compat.sh      | grep -v "^#" | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/shell.sh       | grep -v "^#" | grep -v "source \${script_dir}/core" >> salobin.sh
cat core/output.sh      | grep -v "^#" | grep -v "source \${script_dir}/core" >> salobin.sh

echo "Appending main script..."
cat salomon.sh          | grep -v "^#" | grep -v "\${script_dir}/core" \
                        | grep -v "compatib" >> salobin.sh

echo "Compiling..."
shc -f salobin.sh -o salomon
if [ $? -eq 0 ]; then
    chmod +x salomon
    echo "Done."
else
    echo "error: Compiling failed with return value $?"
fi
rm -f salobin*

