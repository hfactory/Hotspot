#!/bin/bash

# XXX Hack until we have proper importation of geoJSON datasets.
dataset="ParisData Wifi Hotspots"
dataset_url="http://parisdata.opendatasoft.com/explore/dataset/liste_des_sites_des_hotspots_paris_wifi/download/?format=json&timezone=Europe/Berlin"

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

# Feed the dataset description.
echo "{ \"name\": \"${dataset}\", \"url\": \"${dataset_url}\" }" > __feed_tmp
"$REST_SH" POST /Hotspot/dataset __feed_tmp

# Feed the data points.
cat "$datafile" | while read e; do
    echo $e > __feed_tmp
    "$REST_SH" POST /Hotspot/hotspot __feed_tmp
done
rm __feed_tmp
