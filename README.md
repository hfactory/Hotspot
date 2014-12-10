Hotspot
========

This project should be used inside the [HFactory Studio VM](http://hfactory.io/download.html#studio).

Place the project in the workspace folder and import it with Eclipse.

To have the app running:
- Start HBase
- Start the HFactory server
- Create the tables through the administration page of the server
- Start the Hotspot application
- Use feed.sh from the Hotspot folder to feed the Paris Hotspot data:
```
./feed.sh
```

You can specify another data file and a different host and port with the following command line:
```
./feed.sh json_file http://host:port
```

See the [documentation of the HFactory Studio](http://hfactory.io/doc.html) for more information.

And you are ready to go.

For displaying the results this project uses [OpenLayers](http://www.openlayers.org/) and [OpenStreetMap](http://www.openstreetmap.org/)

parisHotspot.json was converted from [Open Data Paris data](http://opendata.paris.fr/) and are under the following [license](http://opendata2.paris.fr/opendata/document?id=78&id_attribute=48)
