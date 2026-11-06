#!/usr/bin/env bash

shopt -s nullglob
overall=0

for number in 1 2 3 4; do
    input="Testcase${number}"
    output="Testcase${number}Diff"
    valid=1
    different=0

    if [[ ! -d "$input" ]]; then
        valid=0
    fi

    for first in "$input"/*.1.txt; do
        second="${first%.1.txt}.2.txt"
        name="${first##*/}"
        result="$output/${name%.1.txt}Diff.txt"

        diff -q -- "$first" "$second" > /dev/null
        status=$?

        if (( status == 1 )); then
            different=$((different + 1))

            if [[ ! -f "$result" ]]; then
                valid=0
            elif ! cmp -s \
                <(diff -u -- "$first" "$second" | tail -n +3) \
                <(tail -n +3 -- "$result"); then
                valid=0
            fi
        elif (( status == 0 )); then
            if [[ -e "$result" || -L "$result" ]]; then
                valid=0
            fi
        else
            valid=0
        fi
    done

    if (( different > 0 )); then
        if [[ ! -d "$output" ]]; then
            valid=0
        else
            results=("$output"/*)

            if (( ${#results[@]} != different )); then
                valid=0
            fi
        fi
    elif [[ -e "$output" || -L "$output" ]]; then
        valid=0
    fi

    if (( valid == 1 )); then
        printf 'Testcase%s: PASS\n' "$number"
    else
        printf 'Testcase%s: FAIL\n' "$number"
        overall=1
    fi
done

exit "$overall"