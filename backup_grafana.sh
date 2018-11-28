#!/bin/bash
## Written by: Mischa Gresser
## Last modified: 11/28/18
## Requires jq to work. Also requires the creation of a backup directory and a grafana URL and auth token with read access to work.

## Find todays date and set it as date variable.
now=$(date +"%m_%d_%Y")
GRAFANA_URL="foo.bar"
AUTH_TOKEN="foo"
BACKUP_LOCATION="/var/lib/foo"

## Uses Backup user API key to get a list of dashboards.
## Takes this list and passes it to jq to parse out the values in the uri key
## Takes the result and sets it as the dashboards variable
dashboards=$(curl -s -H "Authorization: Bearer $AUTH_TOKEN" https://$GRAFANA_URL/api/search | jq -r 'keys[] as $k | "\(.[$k] | .uri)"')

## For each dashboard uses Backup user API to get the JSON for that URI
## Takes the results and passes it to jq to parse out the dashboard key contents
## Writes those contents to a date based .json file with the dashboard name
for dashboard in $dashboards; do curl -s -H "Authorization: Bearer $AUTH_TOKEN" https://$GRAFNA_URL/api/dashboards/$dashboard | jq .dashboard > $BACKUP_LOCATION/$dashboard-$now.json; done

## Finds and deletes backups older than 30 days.
find $BACKUP_LOCATION -mtime +30 -type f -delete
