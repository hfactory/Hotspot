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
  server="http://localhost:30100"
fi

"$REST_SH" $server

function cleanup {
  rm __feed_tmp[12] >/dev/null 2>&1
}

trap cleanup EXIT

#Split the file in dataset and points
awk -v RS="" -v FS="__DATASET_END__" '{ print $1 > "__feed_tmp1"; print $2 > "__feed_tmp2" }' $datafile
# Feed the dataset description.
"$REST_SH" POST /Hotspot/Dataset __feed_tmp1

# Feed the data points.
"$REST_SH" POST /Hotspot/Hotspot __feed_tmp2

