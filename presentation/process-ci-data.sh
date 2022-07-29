#!/usr/bin/env bash

function to_csv() {
    cat $1.json | jq -sr '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' > $1.csv
}

to_csv all-ci-pipelines

ls ci-data/*.jobs.json | sort -h | tac | xargs jq -cr 'select(.duration != null) | (if .pipeline.iid == null then .pipeline.id else null end) as $id | (if .ref[:3] == "pr-" then .ref else (.ref + "@" + .pipeline.sha) end) as $ref | {iid:.pipeline.iid,id:.pipeline.id,ref:$ref,name,duration,status,created_at}' | jq -scr 'sort_by(.created_at) | reverse | .[]' > ci-data.json

to_csv ci-data

head -10000 ci-data.json > ci-data-10000.json
to_csv ci-data-10000
head -1000 ci-data-10000.json > ci-data-1000.json
to_csv ci-data-1000
head -500 ci-data-1000.json > ci-data-500.json
to_csv ci-data-500
head -100 ci-data-500.json > ci-data-100.json
to_csv ci-data-100
