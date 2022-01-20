#!bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 milestone_title"
    exit 1
fi

MILESTONE_TITLE=$1

MILESTONE_ID=$(curl -s "https://api.github.com/repos/spring-projects/spring-boot/milestones?state=all&sort=due_on&direction=desc" \
  | jq -r -c --arg milestone "${MILESTONE_TITLE}" '.[] | select(.title == $milestone) | .number')

if [ -z "${MILESTONE_ID}" ]; then 
  echo "Milestone ${MILESTONE_TITLE} not found"
  exit 1
fi

curl -s "https://api.github.com/repos/spring-projects/spring-boot/issues?per_page=100&milestone=${MILESTONE_ID}&state=closed&labels=type:%20dependency-upgrade" \
  | jq -r -c 'sort_by(.title) | .[] | {title: .title, url: .html_url}'

