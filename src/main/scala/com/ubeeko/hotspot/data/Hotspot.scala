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
package com.ubeeko.hotspot.data

import ch.hsr.geohash.GeoHash

import com.typesafe.scalalogging.slf4j.Logging

import com.ubeeko.stringconv._
import com.ubeeko.htalk.bytesconv._

// A wifi hotspot entity.
case class Hotspot(
    name     : String,
    address  : String,
    town     : String,
    latitude : Double,
    longitude: Double,
    dataset  : String) {
  lazy val geoHash: GeoHash = Hotspot.geoHash(latitude, longitude, 12)
  def rowKey: GeoHash = geoHash
  override def toString = s"$name @ ($latitude, $longitude)"
}

object Hotspot extends Logging {
  def geoHash(latitude: Double, longitude: Double, precision: Int = 12): GeoHash =
    GeoHash.withCharacterPrecision(latitude, longitude, precision)

  implicit object GeoHashStringConv extends StringConv[GeoHash] {
    def fromString(s: String): GeoHash = GeoHash.fromGeohashString(s)
    override def toString(x: GeoHash): String = x.toBase32
  }

  implicit object GeoHashBytesConv extends BytesConv[GeoHash] {
    def fromBytes(b: Array[Byte]): GeoHash = stringTo[GeoHash](bytesTo[String](b))
    def toBytes(h: GeoHash): Array[Byte] = bytesFrom[String](stringFrom[GeoHash](h))
  }
}
