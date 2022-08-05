#!/usr/bin/env bash

function to_csv() {
    cat "$1.json" | jq -sr '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' > "$1.csv.tmp"
    mv "$1.csv.tmp" "$1.csv"
}

export -f to_csv
