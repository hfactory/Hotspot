/*
 * Copyright (c) Ubeeko eric-leblouch
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.ubeeko.hotspot.tools

import net.liftweb.json._

object CsvConvertTool {
  private val self = getClass.getSimpleName.split("\\$").last

  // NOTE: Will unconditionally split at semicolons, i.e. a semicolon
  // *within* a field is considered to be a separator.
  def parseCsvLine(line: String): Seq[String] = line.split(";")

  def csvLineToJson(fields: Seq[String]): JObject = {
    val Array(latitude, longitude) = fields(5).split(",").map(_.toDouble)
    JObject(List(
      JField("name"     , JString(fields(0))),
      JField("latitude" , JDouble(latitude)),
      JField("longitude", JDouble(longitude))
    ))
  }

  private def printUsage(): Unit = {
    println(
      s"""Paris OpenData Geo CSV Conversion Tool.
        |
        |Converts Geographic data in Paris OpenData CSV format to the JSON format
        |matching the Hotspot entities and prints the result on standard output.
        |
        |Usage: $self <csvfile>
        |
        |The first CSV line is assumed to be the header line and as such is skipped.
        |
        |More information on the Paris Open Data format at this address:
        |    <http://opendata.paris.fr/explore/dataset/liste_des_sites_des_hotspots_paris_wifi/?tab=table>
      """.stripMargin)
  }

  def formatLines(lines: Iterator[String]) = {
    val fields =  lines map parseCsvLine
    // The drop() skips the header line.
    fields.drop(1) map { fields =>
      csvLineToJson(fields)
    }
  }

  def main(args: Array[String]): Unit = {
    if (args.contains("-h") || args.contains("--help")) {
      printUsage()
      System.exit(0)
    }

    if (args.length != 1) {
      System.err.println("Error: invalid commandline")
      System.exit(1)
    }

    val fileName = args(0)
    val csvLines = scala.io.Source.fromFile(fileName).getLines
    println(compact(render(JArray(formatLines(csvLines).toList))))
  }
}
