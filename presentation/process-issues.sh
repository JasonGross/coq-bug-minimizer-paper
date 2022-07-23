#!/usr/bin/env bash

RAW_ISSUES="$(cat all-issues.json | jq '.[] | select( .pull_request == null ) | .user as $user | {number,created_at,"user":$user.login,body}' | jq -s -c)"
NON_COQBOT_ISSUES="$(echo "${RAW_ISSUES}" | jq '.[] | select( .user != "coqbot" ) | {number,created_at,user}' | jq -s -c)"
COQBOT_ISSUES="$(echo "${RAW_ISSUES}" | jq '.[] | select( .user == "coqbot" ) | ( .body | gsub("\r\n"; "\n") | sub("Note: the issue was created automatically with bugzilla2github tool\n\nOriginal bug ID: .*\nFrom: "; "") | gsub("\n.*"; "") | sub("^@"; "") | sub("&lt;"; "") | sub("&gt;"; "") ) as $real_user | {number,created_at,"user":$real_user}' | jq -s -c)"
echo '"Issue Number","ISO Creation Date","Creation Date",User' > issues.csv
# .number|tonumber
{ echo "${NON_COQBOT_ISSUES}"; echo "${COQBOT_ISSUES}"; } | jq '.[]' | jq -s | jq -c 'sort_by(.created_at) | .[]' > issues.json
cat issues.json | jq -r '( .created_at | sub("T"; " ") | sub("Z"; "") ) as $adjusted_created_at | [.number, .created_at, $adjusted_created_at, .user] | @csv' >> issues.csv
