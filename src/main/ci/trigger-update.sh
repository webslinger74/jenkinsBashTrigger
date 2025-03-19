#!/usr/bin/env bash

rm -f response.txt
echo " THE WORKSPACE IN IS ${WORKSPACE}" 
DESTINATION=$1

URL=$([ "$DESTINATION" == "prod" ] && echo "simplewebapp-myapp-1:8081/upload" || echo "simplewebapp-myapp-1:8081/upload" )
echo "${URL}"

makePostRequest() {

  RETRIES=1
  echo "Requesting: $1"
  set +e
  rm -f response.txt

  for run in $( seq 1 $RETRIES)
  do
    cat "${WORKSPACE}/claimants.csv"
    response1=$(curl simplewebapp-myapp-1:8081/upload --max-time 17200)
    echo "${response1}"
    http_response=$(curl --request POST --header 'Content-type: multipart/form-data' -F "csvFile=@${WORKSPACE}/claimants.csv" --output response.txt --write-out "%{http_code}" --max-time 17200 "$1" )
  if [ "$http_response" == "200" ]; then
    echo "SUCCESS Response Code: $http_response, response: $(cat response.txt), at: $(date)"
    return
  fi
  echo "Status code was: ${http_response},  retry: ${run}/${RETRIES}"
  sleep 5
  done
  set -e

  echo "FAILED, response code: $http_response, response: $(cat response.txt), after ${RETRIES} retries, time now: $(date)"
  exit 1;
}

makePostRequest "$URL"
