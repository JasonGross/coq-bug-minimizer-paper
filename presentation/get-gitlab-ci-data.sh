#!/usr/bin/env bash

if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    >&2 echo "USAGE: $0 GITLAB-TOKEN"
    >&2 echo "  Create a GITLAB-TOKEN by following instructions at"
    >&2 echo "  https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html"
    exit 1
fi

running_pipelines="$(jq -r 'select(.status == "running") | .id' all-ci-pipelines.json)"
finished_pipelines="$(jq -r 'select(.status != "running") | .id' all-ci-pipelines.json)"
npipelines="$(echo "${running_pipelines}" "${finished_pipelines}" | wc -w)"
mkdir -p ci-data

authtoken="$1"

function handle_pipeline() {
    local pipeline="$1"
    local n="$2"
    local npipelines="$3"
    local status="$4"
    local fname="ci-data/${pipeline}.jobs.json"
    local fname_running="ci-data/${pipeline}.running"
    echo -n "Pipeline ($n / $npipelines): ${pipeline}"
    if [ ! -f "$fname" ] || ( [ -f "${fname_running}" ] && [ "$status" != "running" ] ); then
        echo
        rm -f "$fname"
        page=1
        echo > "$fname.inprogress"
        while [ ! -z "$page" ]; do
            echo -n "Page: $page ... "
            curl \
                --request GET \
                -H "Accept: application/json" \
                -H "PRIVATE-TOKEN: ${authtoken}" \
                -H "User-Agent: JasonGross/coq-bug-minimizer-paper" \
                -v \
                "https://gitlab.com/api/v4/projects/coq%2Fcoq/pipelines/${pipeline}/jobs?page=${page}&per_page=100" \
                > "$fname.tmp" \
                2>"$fname.headers"
            cat "$fname.tmp" >> "$fname.inprogress"
            echo "Got $(cat "$fname.tmp" | jq 'length') jobs"
            page="$(grep '^< x-next-page:' "$fname.headers" | tr -d '\r' | grep -o '[0-9]*$')"
        done
        cat "$fname.inprogress" | jq -c '.[]' > "$fname"
    else
        echo " (cached)"
    fi
    if [ "$status" == "running" ]; then
        touch "${fname_running}"
    else
        rm -f "${fname_running}"
    fi
}

n=0
for pipeline in ${running_pipelines}; do
    n=$((n+1))
    handle_pipeline "${pipeline}" "${n}" "${npipelines}" "running"
done
for pipeline in ${finished_pipelines}; do
    n=$((n+1))
    handle_pipeline "${pipeline}" "${n}" "${npipelines}" "finished"
done
