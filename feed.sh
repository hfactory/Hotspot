#!/bin/bash

defaultfile="parisHotspot.json"
datafile=$1
server=$2
REST_SH="./rest.sh"

if [ ! -f "$REST_SH" ]; then
  REST_SH=rest.sh
fi

if [ "$datafile" = "-" ]; then
  datafile=""
elif [ ! -f "$datafile" ]; then
  if [ -f "$defaultfile" ]; then
    datafile="$defaultfile"
  else
    echo "Error: No data file specified" >&2
    exit 1
  fi
fi

if [ -z "$server" ]; then
  server="http://localhost:18090"
fi

"$REST_SH" $server

cat "$datafile" | while read e; do
    echo $e > __feed_tmp
    "$REST_SH" POST /Hotspot/hotspot __feed_tmp
done
rm __feed_tmp
