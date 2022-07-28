#!/usr/bin/env bash

if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    >&2 echo "USAGE: $0 GITLAB-TOKEN"
    >&2 echo "  Create a GITLAB-TOKEN by following instructions at"
    >&2 echo "  https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html"
    exit 1
fi

page=1
echo > all-ci-pipelines.json.inprogress
while [ "$page" != 0 ]; do
    echo "Page: $page"
    curl \
        --request GET \
        -H "Accept: application/json" \
        -H "PRIVATE-TOKEN: $1" \
        -H "User-Agent: JasonGross/coq-bug-minimizer-paper" \
        "https://gitlab.com/api/v4/projects/coq%2Fcoq/pipelines?page=${page}&per_page=100" > all-ci-pipelines.json.tmp
    cat all-ci-pipelines.json.tmp >> all-ci-pipelines.json.inprogress
    if [ "$(cat all-ci-pipelines.json.tmp | jq 'length')" != 0 ]; then
        echo "Got pipelines $(cat all-ci-pipelines.json.tmp | jq -r '.[].iid' | paste -sd, -) for prs $(cat all-ci-pipelines.json.tmp | jq -r '[.[].ref] | unique | .[]' | paste -sd, -)"
        page=$(( page + 1 ))
    else
        page=0
    fi
done
cat all-ci-pipelines.json.inprogress | jq '.[]' | jq -c > all-ci-pipelines.json
