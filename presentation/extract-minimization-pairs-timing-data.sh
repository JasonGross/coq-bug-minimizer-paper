#!/usr/bin/env bash

cat ../notebook/presentation/minimization_pairs.csv | python -c 'import csv, json, sys; print(json.dumps([dict(r) for r in csv.DictReader(sys.stdin)]))' | jq -cr '.[]
     | (if .runtime != "" then .runtime | tonumber else null end) as $runtime
     | {number,target,commit,runtime:$runtime,date_start:(.date_start + "Z" | gsub(" "; "T"))}' > minimization_pairs.json.tmp
mv minimization_pairs.json.tmp minimization_pairs.json

commits="$(jq -scr 'map(select(.runtime != null) | .commit) | unique' minimization_pairs.json)"
refs="$(jq -scr 'map(select(.runtime != null) | "pr-" + .number) | unique' minimization_pairs.json)"

# and ($commits | index($sha[:$shalen])) != null
jq -cr ".
   | ${refs}"' as $refs
   | '"${commits}"' as $commits
   | ($commits | map(length) | unique[0]) as $shalen
   | .ref as $ref
   | .parent_id2 as $sha
   | select(($refs | index($ref)) != null)' ci-data.json > ci-timing-data-for-minimization-pairs.json.tmp
mv ci-timing-data-for-minimization-pairs.json.tmp ci-timing-data-for-minimization-pairs.json

./make-bug-minimizer-time-reduction.sh
