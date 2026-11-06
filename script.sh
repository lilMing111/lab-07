#!/usr/bin/env bash

shopt -s nullglob

for number in 1 2 3 4; do
    input="Testcase${number}"
    output="Testcase${number}Diff"

    if [[ ! -d "$input" ]]; then
        printf 'Missing directory: %s\n' "$input" >&2
        exit 1
    fi

    rm -rf -- "$output" || exit 1

    for first in "$input"/*.1.txt; do
        second="${first%.1.txt}.2.txt"
        name="${first##*/}"
        result="$output/${name%.1.txt}Diff.txt"

        diff -q -- "$first" "$second" > /dev/null
        status=$?

        if (( status == 1 )); then
            mkdir -p -- "$output" || exit 1
            diff -u -- "$first" "$second" > "$result"
            status=$?

            if (( status != 1 )); then
                printf 'Unable to generate diff: %s\n' "$result" >&2
                exit 1
            fi
        elif (( status != 0 )); then
            exit 1
        fi
    done
done

exit 0