#!/usr/bin/env bash

if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    >&2 echo "USAGE: $0 GITHUB-TOKEN"
    exit 1
fi

page=1
echo > all-issues.json.inprogress
while [ "$page" != 0 ]; do
    echo "Page: $page"
    curl \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: token $1" \
        -H "User-Agent: JasonGross/coq-bug-minimizer-paper" \
        "https://api.github.com/repos/coq/coq/issues?per_page=100&page=$page&state=all" > all-issues.json.tmp
    cat all-issues.json.tmp >> all-issues.json.inprogress
    if [ "$(cat all-issues.json.tmp | jq 'length')" != 0 ]; then
        echo "Got Issues: $(cat all-issues.json.tmp | jq '.[].number' | tr '\n' ',')"
        page=$(( page + 1 ))
    else
        page=0
    fi
done
cat all-issues.json.inprogress | jq '.[]' | jq -s > all-issues.json
