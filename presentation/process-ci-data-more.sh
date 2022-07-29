#!/usr/bin/env bash

for n in "-100" "-500" ""; do
    cat ci-data$n.json | jq '(if .name[:7] == "plugin:" then .name[7:] else if .name[:8] == "library:" then .name[8:] else null end end) as $name
    | (if $name[:3] == "ci-" then $name[3:] else $name end) as $name
    | select($name != null)
    | ($name | gsub("-"; "_")) as $name
    | . as $orig
    | {ci:$name,duration,status}' | jq -cs 'group_by(.ci)
    | map(([.[] | select(.status == "success") | .duration]) as $s
    | ([.[] | select(.status == "failed") | .duration]) as $f
    | (if ($s | length) > 0 then ($s | add/length) else null end) as $ms
    | (if ($f | length) > 0 then ($f | add/length) else null end) as $mf
    | {ci:.[0].ci,success:$s,failed:$f,mean_success:$ms,mean_failure:$mf})
    | sort_by(.mean_success) | .[]' > ci-durations-sorted$n.json.tmp
    mv ci-durations-sorted$n.json.tmp ci-durations-sorted$n.json
done
