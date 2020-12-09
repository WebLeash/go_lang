#!/bin/bash

url_encode() {
    # needed because our repository (container names) contain chars in that need encodeing
    # according to harbor doc..
    # >> The name of the repository. If it contains slash, encode it with URL encoding. e.g. a/b -> a%252Fb
    local _length="${#1}"
    for (( _offset = 0 ; _offset < _length ; _offset++ )); do
        _print_offset="${1:_offset:1}"
        case "${_print_offset}" in
            [a-zA-Z0-9.~_-]) printf "${_print_offset}" ;;
            ' ') printf + ;;
            *) printf '%%%X' "'${_print_offset}" ;;
        esac
    done
}

# Scan harbor for a container and get the results..
string=$(date +"%m%d%y%T")
request_id="${string}${2}${3}${4}${5}"
host=$1
project=$2
repository=$(url_encode $3)
version=$4
MAX_COUNT=$5
FREQ=$6
username=$7
password=$8

id_token=""

echo "request_id => '${request_id}'"
echo "host => '${host}'"
echo "project => '${project}'"
echo "repository => '${repository}'"
echo "version => '${version}'"

output() {
    # gets len of string and prints out same no. of "="
    str=$1
    echo $str && eval $(echo printf '"=%0.s"' {1..${#str}}) && printf '\n'
}

get_token()
{
    # ask for a token append a status code at end of the response eg { buffer}200
    resp=$(curl -s -w "%{http_code}" \
        --header "application/x-www-form-urlencoded" \
        --data-urlencode "client_id=61ffa794-b674-4278-9bf1-2016d9d738f1" \
        --data-urlencode "response_type=id_token" \
        --data-urlencode "grant_type=password" \
        --data-urlencode "scope=openid" \
        --data-urlencode "username=$username" \
        --data-urlencode "password=$password" \
        "https://login.microsoftonline.com/fdb0e18a-61f3-49e2-891f-ce2def987b59/oauth2/v2.0/token")


    # get last 3 bytes of response which has status added via -w
    if [ "${resp: -3}" != 200 ]; then
        echo "unable to get a token";
        exit 1
    fi
    # we know the last 3 chars *must be 200*
    id_token=$(echo ${resp%???} | ./jq -r ".id_token")
}


run_scan()
{
    endpoint="https://$host/api/v2.0/projects/$project/repositories/$repository/artifacts/$version/scan"
    echo "Running scan for API $endpoint"
    resp=$(curl -s -w "%{http_code}" -X POST "$endpoint" -H "accept: application/json" -H "authorization: Bearer $id_token" -H "X-Request-Id: $request_id")

    # get last 3 bytes of response which has status added via -w
    if [ "${resp: -3}" != 202 ]; then
        echo "unable to run scan against $endpoint";
        echo ${resp%???}
        exit 1
    fi
}

get_overview()
{
    curl -s -G "https://$host/api/v2.0/projects/$project/repositories/$repository/artifacts/$version" \
    --data-urlencode "with_scan_overview=true" \
    --data-urlencode "with_immutable_status=false" \
    --header "accept: text/plain" \
    --header "application/application/json" \
    --header "X-Request-Id: $request_id" | ./jq '.scan_overview."application/vnd.scanner.adapter.vuln.report.harbor+json; version=1.0"'
}

get_vunerablities()
{
    curl -s -X GET "https://$host/api/v2.0/projects/$project/repositories/$repository/artifacts/$version/additions/vulnerabilities" \
        -H "accept: application/json" \
        -H "authorization: Bearer $id_token" \
        -H "X-Request-Id: $request_id"
}

get_result()
{
    report_id=$1
    curl -s -X GET "https://$host/api/v2.0/projects/$project/repositories/$repository/artifacts/$version/scan/$report_id/log" \
        -H "accept: text/plain" \
        -H "authorization: Bearer $id_token" \
        -H "X-Request-Id: $request_id"
}

get_complete_percent()
{
    echo "$1" | ./jq -r ".complete_percent"
}

get_scan_status()
{
    echo "$1" | ./jq -r ".scan_status"
}


#### MAIN()
output "Starting Scan [$(date +"Date: %m-%d-%y Time: %T")]"
get_token
run_scan

overview=$(get_overview)
echo "Getting Overview of Scan"
echo $overview | ./jq

## effectively block on complete percent not status as can complete with failed .. and the logic gets messy
complete_percent=$(get_complete_percent "$overview")
scan_status=$(get_scan_status "$overview")

while [ "$complete_percent" != 100 ]
do
    COUNT=$((COUNT+1))

    overview=$(get_overview)
    complete_percent=$(get_complete_percent "$overview")
    scan_status=$(get_scan_status "$overview")

    printf "Scan in progress ${scan_status} [$COUNT]\n"
    sleep ${FREQ} # n = frequency
    if [ ${COUNT} -gt ${MAX_COUNT} ]; then
        echo "Exceeded scan count, sorry ending scan, try altering POLL_MAX_WAITTIME_SECS [$MAX_COUNT]"
        exit 1
    fi
done

overview=$(get_overview)
scan_status=$(get_scan_status "$overview")
echo "Getting Scan Status & Overview"

if [ "$scan_status" != "Success" ]
then
   echo "Scan has completed but not successfully - just dump the overview"
   echo get_overview | ./jq
   exit 1
fi

output "Scan has completed successfully -- getting report" 1
severity=$(echo $overview | ./jq -r ".severity")

if [ "$severity" == "None" ]; then
    output "No Vulnerabilites Found"
else
    output "Severity Level Vulnerability [$severity]"
    report_id=$(echo $overview | ./jq -r ".report_id")
    get_result $report_id
fi


# only get the vunerability array here as the buffer is huge - much more efficient to only pull the vulnerabilities array down
output "Vunerabiltiy Summary"
vulnerabilities=$(get_vunerablities | ./jq -r '."application/vnd.scanner.adapter.vuln.report.harbor+json; version=1.0".vulnerabilities[]')
echo $vulnerabilities | ./jq -r ".severity" | sort | uniq -c

# now produce a summary file we can consume in jenkins easily
echo $vulnerabilities | ./jq -s 'group_by(.severity) | map( { Severity: .[0].severity, Count: length } )' > summary.json

exit 0