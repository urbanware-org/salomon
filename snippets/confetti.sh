confetti() {
    highlight=$2
    highlight_random=0
    line_input="$1"
    line_output=""

    if [ -z "$highlight" ]; then
        highlight_random=1
    fi

    for char in $(sed -e "s/\(.\)/\1\n/g" <<< "$line_input"); do
        color_confetti=$(shuf -i 1-256 -n 1)
        if [ $highlight_random -eq 1 ]; then
            color_highlight=$(shuf -i 0-1 -n 1)
            if [ $color_highlight -eq 1 ]; then
                color_char="\e[48;5;${color_confetti}m${char}${cl_n}"
            else
                color_char="\e[38;5;${color_confetti}m${char}${cl_n}"
            fi
        else
            if [ $highlight -eq 1 ]; then
                color_char="\e[48;5;${color_confetti}m${char}${cl_n}"
            else
                color_char="\e[38;5;${color_confetti}m${char}${cl_n}"
            fi
        fi
        line_output="${line_output}${color_char}"
    done

    echo -e "$line_output"
}
