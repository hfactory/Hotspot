Hotspot
========

This project should be compiled with sbt or a sbt compatible IDE

To have the app running:
- Create the assembly with `sbt assembly`.
- Use `./local-install.sh` with your app folder to install the jar.
- Create the `Hotspot.conf` file in the conf folder of your app use the example at the root of the project.
- Copy the file in your apps folder (`/var/hfactory/apps` in the Azure HFactory Tools Sandbox). Use hfactory-env.sh putApp if you use the docker-machine script.
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

And you are ready to go.

For displaying the results this project uses [OpenLayers](http://www.openlayers.org/) and [OpenStreetMap](http://www.openstreetmap.org/)

parisHotspot.json was converted from [Open Data Paris data](http://opendata.paris.fr/) and are under the following [license](http://opendata2.paris.fr/opendata/document?id=78&id_attribute=48)

shopHannover.json was converted from [Open Street Map](http://www.openstreetmap.org) and queried through [Overpass turbo](http://overpass-turbo.eu/s/8eS). The data is made available under [ODbL](http://opendatacommons.org/licenses/odbl/).

parisHotspot.json was converted from [Open Street Map](http://www.openstreetmap.org) and queried through [Overpass turbo](http://overpass-turbo.eu/s/8ff). The data is made available under [ODbL](http://opendatacommons.org/licenses/odbl/).
