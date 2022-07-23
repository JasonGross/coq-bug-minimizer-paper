#!/usr/bin/env python3
import csv, dateutil.parser

with open('issues.csv', newline='', encoding='utf-8') as csvfile:
    reader = csv.DictReader(csvfile)
    data = [dict(row) for row in reader]

users = sorted(set(row['User'] for row in data))
user_counts = {user:len([row for row in data if row['User'] == user]) for user in users}
#max_users = len(users)
max_users = 255
min_issues = sorted(user_counts.values())[-(max_users+1)] + 1
print(f'Minimum Issues to Appear: {min_issues}')
active_users = sorted(set(user for user in users if user_counts[user] >= min_issues), key=user_counts.get, reverse=True)
outdata = {}
OTHER_USER = '(Other)'
for row in data:
    year = dateutil.parser.isoparse(row['ISO Creation Date']).year
    user = row['User']
    if user not in active_users: user = OTHER_USER
    if year not in outdata.keys(): outdata[year] = {'year':year}
    outdata[year][user] = outdata[year].get(user, 0) + 1

with open('issues-by-year.csv', mode='w', newline='', encoding='utf-8') as csvfile:
    writer = csv.DictWriter(csvfile, ['year'] + list(active_users) + [OTHER_USER])
    writer.writeheader()
    for year in sorted(outdata.keys()):
        writer.writerow(outdata[year])
