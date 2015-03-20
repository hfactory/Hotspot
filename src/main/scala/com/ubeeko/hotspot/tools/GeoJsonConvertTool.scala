package com.ubeeko.hotspot.tools

import net.liftweb.json._
import scala.util.{Success, Try, Failure}

sealed abstract class GeoJsonException extends Exception

class GeoJsonUnknownFormatException(val format: String) extends GeoJsonException {
  override def getMessage = s"Unknown format: '$format'"
}

class GeoJsonInvalidDatasetException(val reason: String) extends GeoJsonException {
  override def getMessage = s"Invalid dataset: $reason"
}

class GeoJsonInvalidDataPointException(val dataPoint: JObject) extends GeoJsonException {
  override def getMessage = s"Invalid data point: $dataPoint"
}

class GeoJsonInvalidFieldException(val fieldName: String) extends GeoJsonException {
  override def getMessage = s"Field '$fieldName' has invalid value"
}

class GeoJsonMissingFieldException(val fieldName: String) extends GeoJsonException {
  override def getMessage = s"Missing field: '$fieldName'"
}

case class DataPoint(name: String, address: String, town: Option[String], latitude: Double, longitude: Double)

trait GeoJsonConverter {
  /** Returns the dataset.
    *
    * @param rootJson  The root JSON node.
    * @return The dataset, where each datapoint is a JObject.
    */
  def getDataset(rootJson: JValue): Try[List[JObject]]

  /** Makes a Scala data point from an input JSON data point. */
  def makeDataPoint(dataPoint: JObject): Try[DataPoint]
}

object GeoJsonConverter {
  def getStringFieldOpt(fields: List[JField], name: String): Try[Option[String]] =
    fields.find(_.name == name) map (_.value) match {
      case Some(JString(s)) => Success(Some(s))
      case Some(_)          => Failure(new GeoJsonInvalidFieldException(name))
      case None             => Success(None)
    }

  def getStringField(fields: List[JField], name: String): Try[String] =
    fields.find(_.name == name) map (_.value) match {
      case Some(JString(s)) => Success(s)
      case Some(_)          => Failure(new GeoJsonInvalidFieldException(name))
      case None             => Failure(new GeoJsonMissingFieldException(name))
    }

  def getLatLongField(fields: List[JField], name: String): Try[(Double, Double)] =
    fields.find(_.name == name) map (_.value) match {
      case Some(JArray(JDouble(lat) :: JDouble(long) :: Nil)) => Success((lat, long))
      case Some(_) => Failure(new GeoJsonInvalidFieldException(name))
      case None    => Failure(new GeoJsonMissingFieldException(name))
    }
}

class OpenStreetMapConverter extends GeoJsonConverter {
  import GeoJsonConverter._

  def getDataset(json: JValue): Try[List[JObject]] =
    tryFind(json, "features") match {
      case Success(JArray(dataPoints)) =>
        val r = dataPoints map {
          case o: JObject  => Some(o)
          case _           => None
        }
        if (r forall (_.isDefined))
          Success(r.flatten)
        else
          Failure(new GeoJsonInvalidDatasetException("Not all data points are objects"))

      case Success(_) =>
        Failure(new GeoJsonInvalidDatasetException("Not an array"))

      case Failure(e) =>
        Failure(e)
    }

  def makeDataPoint(dataPoint: JObject): Try[DataPoint] =
    tryFind(dataPoint, "properties") match {
      case Success(JObject(fields)) =>
        for (siteName    <- getStringField(fields, "name");
             shop        <- getStringFieldOpt(fields, "shop");
             street      <- getStringFieldOpt(fields, "addr:street");
             houseNumber <- getStringFieldOpt(fields, "addr:housenumber");
             town        <- getStringFieldOpt(fields, "addr:city");
             geometry    <- tryFind(dataPoint, "geometry");
             geoFields   <- Try { geometry.asInstanceOf[JObject].obj };
             (long, lat) <- getLatLongField(geoFields, "coordinates"))
        yield {
          val address = shop.map(_ + " ").getOrElse("") + s"$street $houseNumber"
          DataPoint(siteName, address, town, lat, long)
        }
      case _ =>
        Failure(new GeoJsonInvalidDataPointException(dataPoint))
    }

  private def tryFind(json: JValue, name: String): Try[JValue] = {
    (json \ name) match {
      case JNothing => Failure(new GeoJsonMissingFieldException(name))
      case v        => Success(v)
    }
  }
}

class ParisOpenDataConverter extends GeoJsonConverter {
  import GeoJsonConverter._

  def getDataset(json: JValue): Try[List[JObject]] =
    tryFind(json, "features") match {
      case Success(JArray(dataPoints)) =>
        val r = dataPoints map {
          case o: JObject  => Some(o)
          case _           => None
        }
        if (r forall (_.isDefined))
          Success(r.flatten)
        else
          Failure(new GeoJsonInvalidDatasetException("Not all data points are objects"))

      case Success(_) =>
        Failure(new GeoJsonInvalidDatasetException("Not an array"))

      case Failure(e) =>
        Failure(e)
    }

  def makeDataPoint(dataPoint: JObject): Try[DataPoint] =
    tryFind(dataPoint, "properties") match {
      case Success(JObject(fields)) =>
        for (siteName    <- getStringField(fields, "nom_site");
             address     <- getStringField(fields, "adresse");
             (lat, long) <- getLatLongField(fields, "geo_coordinates"))
        yield
          DataPoint(siteName, address, Some("Paris"), lat, long)
      case _ =>
        Failure(new GeoJsonInvalidDataPointException(dataPoint))
    }

  private def tryFind(json: JValue, name: String): Try[JValue] = {
    (json \ name) match {
      case JNothing => Failure(new GeoJsonMissingFieldException(name))
      case v        => Success(v)
    }
  }
}

object GeoJsonConvertTool {
  private val self = getClass.getSimpleName.split("\\$").last

  private val debug = Option(System.getenv("GEOJSON_DEBUG")).isDefined

  private def printError(msg: => String): Unit =
    System.err.println("Error: " + msg)

  private def errorExit(msg: => String): Unit = {
    printError(msg)
    System.exit(1)
  }

  private val converters: Map[String, () => GeoJsonConverter] = Map(
    "parisopendata" -> (() => new ParisOpenDataConverter),
    "openstreetmap" -> (() => new OpenStreetMapConverter)
  )

  private def printUsage() {
    val formatHelp = converters.keys.map("'" + _ + "'").mkString(", ")
    println(
      s"""Geo JSON Tool.
        |
        |Converts Geographic data from a specified format to the Hotspot format.
        |
        |Usage:
        |
        |    $self -f <format> -i <datafile> -d <dataset_name> [-t <default_town>]
        |
        |with
        |    <format>       Format of input file, one of: $formatHelp.
        |    <datafile>     Input file.
        |    <dataset_name> The name of the dataset
        |    <default_town> The name for the town if addr:city is not filled
        |
        |More information on the Paris Open Data format at this address:
        |    <http://opendata.paris.fr/explore/dataset/liste_des_sites_des_hotspots_paris_wifi/?tab=table>
      """.stripMargin)
  }

  def main(args: Array[String]): Unit = {
    if (args.contains("-h") || args.contains("--help")) {
      printUsage()
      System.exit(0)
    }

    def getConverter(format: String): Try[GeoJsonConverter] =
      Try { converters(format)() } recoverWith {
        case _ => Failure(new GeoJsonUnknownFormatException(format))
      }

    args.toList match {
      case "-f" :: format :: "-i" :: fileName :: "-d" :: dataset :: l =>
        val townTry = l match {
          case "-t" :: defaultTown :: Nil => Success(defaultTown)
          case Nil => Success("")
          case _ =>
            Failure(new Exception("Invalid commandline"))
        }
        townTry map {town =>
          getConverter(format) flatMap (convertGeo(fileName, _, dataset, town)) match {
            case Success(()) =>
            case Failure(e)  => errorExit(e.getMessage)
          }
        }
      case _ =>
        errorExit("Invalid commandline")
    }
  }

  private def convertGeo(fileName: String, converter: GeoJsonConverter, datasetName: String, defaultTown: String): Try[Unit] = {
    for (
      json            <- loadJson(fileName);
      _               <- dumpJson(json);
      dataset         <- converter.getDataset(json);
      importedDataset <- importDataset(dataset, converter);
      exportedDataset <- exportDataset(importedDataset, datasetName, defaultTown)
    ) yield {
      println(compact(render(JArray(exportedDataset))))
    }
  }

  private def importDataset(dataset: List[JObject], converter: GeoJsonConverter): Try[List[DataPoint]] = Try {
    dataset.map(converter.makeDataPoint).map(_.get)
  }

  private def exportDataset(dataset: List[DataPoint], datasetName: String, defaultTown: String): Try[List[JObject]] = Try {
    dataset map (point => dataPointToJson(point, datasetName, defaultTown))
  }

  // Converts a Scala data point to the target JSON format. */
  private def dataPointToJson(d: DataPoint, datasetName: String, defaultTown: String): JObject =
    JObject(List(
      JField("name"     , JString(d.name)),
      JField("address"  , JString(d.address)),
      // XXX make optional
      JField("town"     , JString(d.town.getOrElse(defaultTown))),
      JField("latitude" , JDouble(d.latitude)),
      JField("longitude", JDouble(d.longitude)),
      JField("dataset"  , JString(datasetName))
    ))

  private def dumpJson(json: JValue): Try[Unit] = Try {
    if (debug) {
      println("GEO_JSON_BEGIN")
      if (json == JNothing)
        println("(nothing)")
      else
        println(pretty(render(json)))
      println("GEO_JSON_END")
    }
  }

  private def loadJson(fileName: String): Try[JValue] = Try {
    val source = scala.io.Source.fromFile(fileName)
    val text = source.getLines().mkString
    source.close()
    parse(text)
  }
}

