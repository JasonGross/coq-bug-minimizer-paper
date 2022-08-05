#!/usr/bin/env bash

. ./to_csv_jq.sh

minimization_pairs="$(jq -sc 'map(select(.runtime != null))' minimization_pairs.json)"

jq -cr "${minimization_pairs}"' as $mpairs
   | . as $self
   | $mpairs[]
   | . as $mpair
   | $mpair.commit as $sha
   | ($sha | length) as $shalen
   | ($mpair.target | length) as $targetlen
   | select($self.ref == "pr-" + $mpair.number
                      and ($self.parent_id1[:$shalen] == $sha or $self.parent_id2[:$shalen] == $sha)
                      and $self.name[-$targetlen:] == $mpair.target)
   | $mpair + $self' ci-timing-data-for-minimization-pairs.json > ci-timing-data-with-minimization-pairs.json.tmp
mv ci-timing-data-with-minimization-pairs.json.tmp ci-timing-data-with-minimization-pairs.json

to_csv ci-timing-data-with-minimization-pairs
