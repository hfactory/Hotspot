name := "hotspot"

version := "0.2"

scalaVersion := "2.10.6"

organization := "io.hfactory.hotspot"

resolvers ++= Seq(
  "Ubeeko nexus public" at "http://nexus.hfactory.io/nexus/content/groups/public",
  "Ubeeko nexus releases" at "http://nexus.hfactory.io/nexus/content/repositories/releases/",
  "Ubeeko nexus snapshots" at "http://nexus.hfactory.io/nexus/content/repositories/snapshots/"
)

libraryDependencies ++= Seq(
  "ch.qos.logback"      % "logback-classic"    % "1.0.13" % "provided",
  "com.typesafe"       %% "scalalogging-slf4j" % "1.0.1"  % "provided",
  "com.ubeeko"         %% "hfactory-app"       % "1.6"    % "provided",
  "com.ubeeko"         %% "hfactory-core"      % "1.6"    % "provided",
  "org.scalatest"       % "scalatest_2.10"     % "2.2.6" % "test"
)

scalacOptions ++= Seq(
  "-unchecked",
  "-deprecation",
  "-Xlint",
  "-Ywarn-dead-code",
  "-Xlog-implicits",
  "-language:_",
  "-target:jvm-1.7",
  "-encoding", "UTF-8"
)

testOptions += Tests.Argument(TestFrameworks.JUnit, "-v")

addCompilerPlugin("org.scalamacros" % "paradise" % "2.1.0-M5" cross CrossVersion.full)
