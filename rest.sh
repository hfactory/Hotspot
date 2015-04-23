#!/bin/bash

self=$(basename $0)

function error {
    echo $* >&2
}

function error_exit {
    error $*
    exit 1
}

function missing_args {
    error_exit "Missing arguments"
}

function usage {
    echo "Very simple tool for sending REST requests"
    echo
    echo "Usage:"
    echo "    $self <host>              Sets the host to be used in the requests sent."
    echo "    $self GET <path>          Send a GET request."
    echo "    $self POST <path> <file>  Send a POST request with the specified contents."
    echo "    $self DELETE <path>       Send a DELETE request."
    echo
    echo "The URL of a request with path <path> is <host><path>, with no added slash"
    echo "in-between. It is advised to not end the <host> with a slash and start every"
    echo "path with one."
    echo
    echo "All requests have 'Accept' and 'Content-Type' headers set to 'application/json'"
    echo "and all require that the host be set."
    echo
    echo "Note:"
    echo "  - The configured host is stored in file .rest_host in the working directory."
    echo "  - The header and body of the last response are stored in .rest_response_header.txt" 
    echo "    and .rest_response_body.txt, respectively."
}

HOST_FILE=".rest_host"
RESPONSE_HEADER_FILE=".rest_response_header.txt"
RESPONSE_BODY_FILE=".rest_response_body.txt"

case "$1" in
    -h|--help)
        usage
        exit 0
        ;;
    GET)
        method=GET
        [ -z "$2" ] && missing_args
        path=$2
        ;;
    PUT)
        method=PUT
        error_exit "Not implemented"
        ;;
    POST)
        method=POST
        [ -z "$2" ] && missing_args
        path=$2
        datafile=$3
        opts="--data @$datafile"
        ;;
    DELETE)
        method=DELETE
        [ -z "$2" ] && missing_args
        path=$2
        ;;

    http://*)
        echo Host: $1
        echo $1 > $HOST_FILE
        exit 0
        ;;
    "")
        if [ -f $HOST_FILE ]; then
           echo -n "Host: "
           cat $HOST_FILE
        else
           echo "No host configured"
        fi
        exit 0
        ;;
    *)
        error_exit "Invalid commandline"
esac

host=$(cat $HOST_FILE)

if [ -z "$host" ]; then
    error_exit "Host not defined"
fi

if [ -n "$REST_DEBUG" ]; then
    echo "host: $host"
    echo "method: $method"
    echo "path: $path"
    echo "datafile: $datafile"
fi

curl -4 --silent --show-error \
     --dump-header $RESPONSE_HEADER_FILE \
     -X $method \
     -H 'Accept: application/json' \
     -H 'Accept: text/plain' \
     -H 'Accept: text/html' \
     -H 'Content-Type: application/json' \
     $opts \
     $host$path > $RESPONSE_BODY_FILE \
 && cat $RESPONSE_HEADER_FILE $RESPONSE_BODY_FILE

r=$?

# Ensures the output ends with a newline.
echo

[ -n $r ] && exit $r

