#!/usr/bin/env bash

for n in "-100" "-500" "-2022" ""; do

{ echo '"CI job","failed job","successful job"';
  jq -cr '(if .success != null then .success else [] end) as $s | (if .failed != null then .failed else [] end) as $f | .ci as $ci | [$f,$s] | transpose | .[] | [$ci,.[]] | @csv' ci-durations-sorted$n.json;
} > ci-durations-sorted$n.csv

{ echo '"CI job","failed job","successful job"';
  jq -crs '(.[:10] + .[-10:] | map(.ci)) as $interesting
     | .[]
     | (if .success != null then .success else [] end | [.[] / 60 / 60 / 24]) as $s
     | (if .failed != null then .failed else [] end | [.[] / 60 / 60 / 24]) as $f
     | .ci as $ci
     | [$f,$s]
     | transpose
     | .[]
     | select((["bbv", "bedrock2", "color", "fiat_crypto_legacy", "gappa", "itauto", "rewriter", "verdi_raft", "vst"]+$interesting | index($ci)) != null)
     | [$ci,.[]]
     | @csv' ci-durations-sorted$n.json;
} > ci-durations-sorted$n-selected-1.csv
done
