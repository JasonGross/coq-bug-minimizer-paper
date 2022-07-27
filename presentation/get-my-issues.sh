#!/usr/bin/env bash

if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    >&2 echo "USAGE: $0 GITHUB-TOKEN"
    exit 1
fi

mkdir -p my-issues
ISSUES="$(jq 'select(.user == "JasonGross") | .number' issues.json)"
for n in ${ISSUES}; do
    fname="my-issues/${n}.comments.page.1"
    body_fname="${fname}.body"
    if [ ! -f "${fname}" ]; then
        echo "Getting Issue #${n}"
        curl \
             -H "Accept: application/vnd.github+json" \
             -H "Authorization: token $1" \
             -H "User-Agent: JasonGross/coq-bug-minimizer-paper" \
             "https://api.github.com/repos/coq/coq/issues/${n}/comments?per_page=100" > "${fname}.tmp" \
            && mv "${fname}.tmp" "${fname}"
    else
        echo "Skipping Issue #${n}"
    fi
    if [ ! -f "${body_fname}" ]; then
        cat "${fname}" | jq -r '.[] | .body' > "${body_fname}.tmp" \
            && mv "${body_fname}.tmp" "${body_fname}"
    fi
done

exit 0
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
