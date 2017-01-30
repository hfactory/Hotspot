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
package com.ubeeko.hotspot.app

import ch.hsr.geohash.GeoHash

import com.ubeeko.hfactory.app.HApp
import com.ubeeko.hfactory.entities._

import com.ubeeko.hotspot.data.{Dataset, Hotspot}
import com.ubeeko.hfactory.annotations.DescriptionAnnotation
import com.ubeeko.hfactory.app.annotations.HAppController
import com.ubeeko.htalk.bytesconv._
import com.ubeeko.jsonconv._
import com.ubeeko.stringconv.StringConv

import java.awt.geom.Point2D

import scala.annotation.meta.field

// This brings the {To,From}Bytes and {To,From}String instances
// for GeoHash in scope. Needed for the implicit generation of
// the Hotspot entity at registration.
import Hotspot._

class HotspotRegistry extends HEntityRegistry {
  registerEntity[Dataset]
  registerEntity[Hotspot]
}

class HotspotApp extends HApp {
  val hotspotEntity = entityRegistry.getEntity[Hotspot]

  /**
   * Get the hotspots from a data set
   */
  def hotspots(datasetName: String): Iterable[Hotspot] = {
    import com.ubeeko.htalk.criteria._
    ("hotspot" get rows columnValue("dataset", datasetName)) ~ hotspotEntity.io.conv.fromResult
  }
  // XXX Rather than count, specify radius (in kms) ? see
  // <http://munro-bagging.googlecode.com/svn/tags/MunroBagging_v4/Data%20Generator/src/ch/hsr/geohash/queries/GeoHashCircleQuery.java>
  // Use WGS84Point in haversine formula?

  @HAppController(
    httpMethod  = "GET",
    description = "Get the closest points to the given position in the dataset and limit to count responses."
  )
  def getClosest(datasetName: String, lat: Double, long: Double, count: Int): List[Hotspot] = {
    val target = Hotspot.geoHash(lat, long, 6) // 6 chars only as we want a prefix, not a full hash (12 chars).

    val origin = new Point2D.Double(target.getPoint.getLatitude, target.getPoint.getLongitude)
    def distanceToOrigin(hotspot: Hotspot): Double = origin.distanceSq(hotspot.latitude, hotspot.longitude)

    def takeClosest(prefix: GeoHash): List[Hotspot] = {
      val prefixBytes = bytesFrom[GeoHash](prefix)
      val locs = hotspots(datasetName)
      val candidates = locs.toList.filter { c =>
        val rkBytes = bytesFrom[GeoHash](c.rowKey)
        rkBytes.startsWith(prefixBytes)
      }.sortBy(distanceToOrigin).take(count)
      println(s"IO.list with prefix ${prefix.toBase32} returned ${candidates.length} candidates: $candidates")
      candidates
    }

    val results = takeClosest(target) ++ (target.getAdjacent.toList flatMap takeClosest)

    results.sortBy(distanceToOrigin).take(count)
  }

  case class HotspotJSON(
    @(DescriptionAnnotation @field)("Rowkey") rowkey: GeoHash,
    @(DescriptionAnnotation @field)("Fields") fields: Hotspot)

  /**
   * Return a JSON with the rowkey and the fields to have the same behavior
   * than retrieving the whole list
   */ 
  @HAppController(
    httpMethod="GET",
    description="Get the hotspots for a dataset"
  )
  def filteredHotspot(datasetName: String): Iterable[HotspotJSON] = {
    hotspots(datasetName).map { hotspot =>
      HotspotJSON(hotspot.rowKey, hotspot)
    }
  }
}
