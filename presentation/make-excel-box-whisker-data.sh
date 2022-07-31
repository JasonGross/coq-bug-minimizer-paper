#!/usr/bin/env bash

. ./to_csv_jq.sh

for selected in "" "-selected"; do
    for suffix in "" "-2022"; do
        cat "ci-data-stats${suffix}${selected}.json" | jq -cr '["",.q1_of_4_f-.percentile2_f,.percentile9_f,.q1_of_4_f,.q2_of_4_f-.q1_of_4_f,.q3_of_4_f-.q2_of_4_f,.percentile91_f,.percentile98_f-.q3_of_4_f,.ave_f,"","","","","","","",""],[.name,"","","","","","","","",.q1_of_4_s-.percentile2_s,.percentile9_s,.q1_of_4_s,.q2_of_4_s-.q1_of_4_s,.q3_of_4_s-.q2_of_4_s,.percentile91_s,.percentile98_s-.q3_of_4_s,.ave_s],["","","","","","","","","","","","","","","","",""]' | jq -crs '["ci","whisker 2.15% (failed)","8.87% (failed)","lower quartile (failed)","delta median (failed)","delta upper quartile (failed)","91.13% (failed)","whisker 97.85% (failed)","mean (failed)","whisker 2.15% (success)","8.87% (success)","lower quartile (success)","delta median (success)","delta upper quartile (success)","91.13% (success)","whisker 97.85% (success)","mean (success)"],.[] | @csv' > "ci-data-stats${suffix}${selected}-boxplot.csv"
    done
done
