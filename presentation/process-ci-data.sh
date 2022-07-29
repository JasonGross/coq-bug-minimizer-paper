#!/usr/bin/env bash

function to_csv() {
    cat $1.json | jq -sr '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' > $1.csv
}

to_csv all-ci-pipelines

ls ci-data/*.jobs.json | sort -h | tac | xargs jq -cr 'select(.duration != null)
   | (if .pipeline.iid == null then .pipeline.id else null end) as $id
   | (if .ref[:3] == "pr-" then .ref else (.ref + "@" + .pipeline.sha) end) as $ref
   | (if .name[:7] == "plugin:" then .name[7:] else if .name[:8] == "library:" then .name[8:] else null end end) as $short_name
   | (if $short_name[:3] == "ci-" then $short_name[3:] else $short_name end) as $short_name
   | (if $short_name == null then null else ($short_name | gsub("-"; "_")) end) as $short_name
   | {iid:.pipeline.iid,id:.pipeline.id,ref:$ref,name,duration,status,created_at,short_name:$short_name}' | jq -scr 'sort_by(.created_at) | reverse | .[]' > ci-data.json.tmp
mv ci-data.json.tmp ci-data.json

to_csv ci-data

./subset-ci-data.sh
./split-ci-data.sh
