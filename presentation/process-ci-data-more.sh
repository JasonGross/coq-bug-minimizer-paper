#!/usr/bin/env bash

for n in "-100" "-500" "-2022" ""; do
    cat ci-data$n.json | jq 'select(.short_name != null)
    | . as $orig
    | {ci:.short_name,duration,status}' | jq -cs 'group_by(.ci)
    | map(([.[] | select(.status == "success") | .duration]) as $s
    | ([.[] | select(.status == "failed") | .duration]) as $f
    | (if ($s | length) > 0 then ($s | add/length) else null end) as $ms
    | (if ($f | length) > 0 then ($f | add/length) else null end) as $mf
    | {ci:.[0].ci,success:$s,failed:$f,mean_success:$ms,mean_failure:$mf})
    | sort_by(.mean_success) | .[]' > ci-durations-sorted$n.json.tmp
    mv ci-durations-sorted$n.json.tmp ci-durations-sorted$n.json
done
