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

#Split the file in dataset and points
awk -v RS="__DATASET_END__" '{ print $0 > "__feed_tmp" NR }' $datafile
# Feed the dataset description.
"$REST_SH" POST /Hotspot/dataset __feed_tmp1

# Feed the data points.
"$REST_SH" POST /Hotspot/hotspot __feed_tmp2
rm __feed_tmp[12]
