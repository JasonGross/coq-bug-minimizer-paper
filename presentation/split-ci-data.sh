#!/usr/bin/env bash

jq -scr 'map(select(.short_name != null)) | group_by(.short_name) | .[]' ci-data.json > ci-data-grouped.json.tmp
mv ci-data-grouped.json.tmp ci-data-grouped.json

./split-grouped-ci-data.sh
