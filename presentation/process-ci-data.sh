#!/usr/bin/env bash

function to_csv() {
    cat $1.json | jq -sr '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' > $1.csv
}
to_csv all-ci-pipelines

ls ci-data/*.jobs.json | sort -h | tac | xargs cat | jq -cr '(if .pipeline.iid == null then .pipeline.id else .pipeline.iid end) as $id | (if .ref[:3] == "pr-" then .ref else (.ref + "@" + .pipeline.sha) end) as $ref | {id:$id,ref:$ref,name,duration,status}' > ci-data.json

to_csv ci-data
