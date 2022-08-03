#!/usr/bin/env bash

# git grep -A5 coq-bug-finder | sed 's,test-suite/bugs/,,g' | tr '\n' '|' | sed 's/\\|[^-]*-//g' | tr '|' '\n' | sort -h | grep coq-bug-finder

kind="$1"
if [ "$kind" == '--no-header' ]; then
    kind=""
else
    echo 'initial_size,final_size,total_line_reduction'
fi

while IFS="" read -r line; do
    reduction="$(echo "$line" | grep -o '[0-9]\+ lines to [0-9]\+' | grep -v '^0 lines to')"
    if [ ! -z "${reduction}" ]; then
        init_size="$(echo "$reduction" | grep -o '[0-9]\+' | head -1)"
        final_size="$(echo "$reduction" | grep -o '[0-9]\+' | tail -1)"
        expr="$(echo "$reduction" | sed 's/\([0-9]\+\) lines to \([0-9]\+\)/(\1 - \2)/g' | paste -sd+)"
        printf '%d,%d,%d,%s\n' "${init_size}" "${final_size}" "$((${expr}))" "${kind}"
    fi
done
