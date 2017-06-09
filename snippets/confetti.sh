confetti() {
    highlight=$2
    line_input="$1"
    line_output=""

    for char in $(echo "$line_input" | sed -e "s/\(.\)/\1\n/g"); do
        color_confetti=$(shuf -i 1-256 -n 1)
        if [ $highlight -eq 1 ]; then
            color_char="\e[48;5;${color_confetti}m${char}\e[0m"
        else
            color_char="\e[38;5;${color_confetti}m${char}\e[0m"
        fi
        temp="${line_output}${color_char}"
        line_output="$temp"
    done

    echo -e "$line_output"
}
