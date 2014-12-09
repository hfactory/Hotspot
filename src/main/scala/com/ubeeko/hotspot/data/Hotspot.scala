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

import com.ubeeko.conversions.{ToString, FromString}
import com.ubeeko.htalk.hbase.{ToBytes, FromBytes}

// A wifi hotspot entity.
case class Hotspot(name: String, latitude: Double, longitude: Double) {
  lazy val geoHash: GeoHash = Hotspot.geoHash(latitude, longitude, 12)
  def rowKey: GeoHash = geoHash
  override def toString = s"$name @ ($latitude, $longitude)"
}

object Hotspot extends Logging {
  def geoHash(latitude: Double, longitude: Double, precision: Int = 12): GeoHash =
    GeoHash.withCharacterPrecision(latitude, longitude, precision)

  implicit object GeoHashFromString extends FromString[GeoHash] {
    def fromString(s: String): GeoHash = GeoHash.fromGeohashString(s)
  }

  implicit object GeoHashToString extends ToString[GeoHash] {
    override def toString(x: GeoHash): String = x.toBase32
  }

  implicit object GeoHashFromBytes extends FromBytes[GeoHash] {
    def fromBytes(b: Array[Byte]): GeoHash = {
      val s = implicitly[FromBytes[String]].apply(b)
      implicitly[FromString[GeoHash]].apply(s)
    }
  }

  implicit object GeoHashToBytes extends ToBytes[GeoHash] {
    def toBytes(h: GeoHash): Array[Byte] = implicitly[ToBytes[String]].apply(h.toBase32)
  }
}
