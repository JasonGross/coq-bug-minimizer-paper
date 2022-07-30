#!/usr/bin/env bash

. ./to_csv_jq.sh

jq -cr '(.[0].short_name | gsub("_"; "-")) as $name
   | select(length > 100)
   | (map(select(.status == "success") | {duration,created_at})) as $s
   | (map(select(.status == "failed") | {duration,created_at})) as $f
   | {name:$name,success:$s,failed:$f}' ci-data-grouped.json > ci-data-grouped-compressed.json

jq -cr '(.success | map(select(.created_at > "2022"))) as $s
   | (.failed | map(select(.created_at > "2022"))) as $f
   | select($s + $f | length > 100)
   | {name,success:$s,failed:$f}' ci-data-grouped-compressed.json > ci-data-grouped-compressed-2022.json

function make_percentile() {
    # array loc descr
    echo "| ($1 | ((length-1) * $2) as \$i | (\$i - (\$i|floor)) as \$w | .[\$i|floor]*\$w + .[\$i|ceil]*(1-\$w)) as $3"
}

function make_stats_dict() {
    name="$1"
    shift
    echo -n "| ($name + {"
    for i in "$@"; do
        echo "${i}:\$${i}"
    done | paste -sd, | tr -d '\n'
    echo "}) as $name"
}

function make_stats() {
    echo "(.$1 | map(.duration)) as \$new_$1
        | (\$new_$1 | add/length) as \$ave_$2
        | (\$new_$1 | sort) as \$sorted_$2
        | \$sorted_$2[0] as \$min_$2
        | \$sorted_$2[-1] as \$max_$2
        | {ave_$2:\$ave_$2,min_$2:\$min_$2,max_$2:\$max_$2} as \$stats_$2"
    for pile in 2.15 8.87 91.13 97.85; do
        descr="percentile$(echo "$pile" | awk '{print int($1+0.5)}')_$2"
        make_percentile "\$sorted_$2" "$pile/100" "\$$descr"
        make_stats_dict "\$stats_$2" "$descr"
    done
    for sz in 4 10; do
        for i in $(seq 1 $((sz-1))); do
            descr="q${i}_of_${sz}_$2"
            make_percentile "\$sorted_$2" "${i} / ${sz}" "\$$descr"
            make_stats_dict "\$stats_$2" "$descr"
        done
        echo "| (\$q$((sz-1))_of_${sz}_$2 - \$q1_of_${sz}_$2) as \$iq${sz}r_$2"
        make_stats_dict "\$stats_$2" "iq${sz}r_$2"
        echo "| (\$sorted_$2 | map(select(\$q1_of_${sz}_$2 - 1.5 * \$iq${sz}r_$2 <= . and . <= \$q$((sz-1))_of_${sz}_$2 + 1.5 * \$iq${sz}r_$2))) as \$non_outliers_$2"
        echo "| \$non_outliers_$2[0] as \$lower_whisker_${sz}_$2"
        echo "| \$non_outliers_$2[-1] as \$upper_whisker_${sz}_$2"
        make_stats_dict "\$stats_$2" "lower_whisker_${sz}_$2" "upper_whisker_${sz}_$2"
    done
}

for suffix in "" "-2022"; do
    jq -cr "$(make_stats "success" "s")
        | $(make_stats "failed" "f")
        | "'{name} + $stats_s + $stats_f' "ci-data-grouped-compressed${suffix}.json" > "ci-data-stats${suffix}.json"
    to_csv "ci-data-stats${suffix}"
    jq -scr 'sort_by(.ave_s)
       | (.[:10] + .[-10:] | map(.name)) as $interesting
       | .[]
       | .name as $name
       | select((["bbv", "bedrock2", "color", "fiat-crypto-legacy", "gappa", "itauto", "rewriter", "verdi-raft", "vst"]+$interesting | index($name)) != null)' "ci-data-stats${suffix}.json" > "ci-data-stats${suffix}-selected.json"
    to_csv "ci-data-stats${suffix}-selected"
done

jq -cr '(.[0].short_name | gsub("_"; "-")) as $name
   | select(length > 100)
   | (map(.duration) | select(length > 0) | add/length) as $duration
   | (map(select(.status == "success") | .duration) | select(length > 0) | add/length) as $sduration
   | (map(select(.status == "failed") | .duration) | select(length > 0) | add/length) as $fduration
   | {name:$name,ave_duration:$duration,ave_success_duration:$sduration,ave_failed_duration:$fduration}' ci-data-grouped.json > ci-jobs-by-ave-duration.json

jq -cr '(.[0].short_name | gsub("_"; "-")) as $name
   | select((map(select(.created_at > "2022")) | length) > 100)
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
