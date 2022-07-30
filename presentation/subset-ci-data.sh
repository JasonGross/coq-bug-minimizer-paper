#!/usr/bin/env bash

. ./to_csv_jq.sh

jq -cr 'select(.created_at > "2022")' ci-data.json > ci-data-2022.json
to_csv ci-data-2022
head -10000 ci-data.json > ci-data-10000.json
to_csv ci-data-10000
head -1000 ci-data-10000.json > ci-data-1000.json
to_csv ci-data-1000
head -500 ci-data-1000.json > ci-data-500.json
to_csv ci-data-500
head -100 ci-data-500.json > ci-data-100.json
to_csv ci-data-100
