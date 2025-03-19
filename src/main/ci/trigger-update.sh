#!/usr/bin/env bash

rm -f response.txt

DESTINATION=$1

URL=$([ "$DESTINATION" == "prod" ] && echo "https://localhost:8080/prod" || echo "https//localhost:8080/dev" )

makePostRequest() {
  RETRIES=1
  echo "Requesting: $1"
  set +e
  rm -f response.txt

  for run in $( seq 1 $RETRIES)
  do
    http_response=$(curl --request POST --header 'Content-type: multipart/form-data' -F "csvFile=@${WORKSPACE}/claimants.csv" --output response.txt --write-out "%{http_code" --max-time 7200 "$1" )
  if [ "$http_response" == "200" ]; then
    echo "SUCCESS Response Code: $http_response, response: $(cat response.txt), at: $(date)"
    return
  fi
  echo "Status code was: $http_response,  retry: ${run}/${RETRIES}"
  sleep 5
  done
  set -e

  echo "FAILED, response code: $http_response, response: $(cat response.txt), after ${RETRIES} retries, time now: $(data)"
  exit 1;
}

makePostRequest "$URL/trigger-update"