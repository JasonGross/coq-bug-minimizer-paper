#!/usr/bin/env bash

jq -cr '(.[0].short_name | gsub("_"; "-")) as $name
   | (map(.duration) | select(length > 0) | add/length) as $duration
   | (map(select(.status == "success") | .duration) | select(length > 0) | add/length) as $sduration
   | (map(select(.status == "failed") | .duration) | select(length > 0) | add/length) as $fduration
   | {name:$name,ave_duration:$duration,ave_success_duration:$sduration,ave_failed_duration:$fduration}' ci-data-grouped.json > ci-jobs-by-ave-duration.json

jq -cr '(.[0].short_name | gsub("_"; "-")) as $name
   | (map(select(.created_at > "2022") | .duration) | select(length > 0) | add/length) as $duration
   | (map(select(.created_at > "2022") | select(.status == "success") | .duration) | select(length > 0) | add/length) as $sduration
   | (map(select(.created_at > "2022") | select(.status == "failed") | .duration) | select(length > 0) | add/length) as $fduration
   | {name:$name,ave_duration:$duration,ave_success_duration:$sduration,ave_failed_duration:$fduration}' ci-data-grouped.json > ci-jobs-by-ave-duration-2022.json

mkdir -p ci-timing-by-job

while read -r line; do
    name="$(echo "$line" | jq -r '.[0].short_name | gsub("_"; "-")')"
    echo "$line" | jq -cr '.[]' > "ci-timing-by-job/$name.json"
    jq -cr 'select(.created_at > "2022")' "ci-timing-by-job/$name.json" > "ci-timing-by-job/$name-2022.json"
    for suffix in "-2022" ""; do
        for status in success failed; do
            jq -cr 'select(.status == "'"${status}"'") | .duration' "ci-timing-by-job/${name}${suffix}.json" | jq -crs 'sort | .[]' > "ci-timing-by-job/${name}${suffix}-${status}.txt"
        done
    done
done <ci-data-grouped.json
