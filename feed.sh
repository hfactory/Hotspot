#!/bin/bash

datafile=$1
if [ "$datafile" = "-" ]; then
  datafile=""
elif [ ! -f "$datafile" ]; then
  echo "Error: No data file specified" >&2
  exit 1
fi

cat $datafile | while read e; do
    echo $e > __feed_tmp
    rest.sh POST /Hotspot/hotspot __feed_tmp
done
rm __feed_tmp
