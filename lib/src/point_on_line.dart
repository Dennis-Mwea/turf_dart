import 'dart:math' as math;

import 'package:turf/bearing.dart';
import 'package:turf/destination.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';
import 'package:turf/meta.dart';
import 'package:turf/src/invariant.dart';
import 'package:turf/src/kinks.dart';

/// Takes a [Point] and a [LineString] and calculates the closest [Point] on the [LineString]/[MultiLineString].
Feature<Point> nearestPointOnLine<G extends GeometryType>(Feature<G> lines, Point pt, {Map<String, dynamic>? options}) {
  var closestPt = Feature(
    geometry: Point(coordinates: Position(double.infinity, double.infinity, double.infinity)),
    properties: <String, dynamic>{'dist': double.infinity},
  );
  var length = 0.0;

  flattenEach(lines, (line, _, __) {
    final coords = getCoords(line);

    for (var i = 0; i < coords.length - 1; i++) {
      //start
      final start = Feature(geometry: Point(coordinates: Position(coords[i][0], coords[i][1])), properties: {});
      start.properties!['dist'] = distance(pt, start.geometry!);
      //stop
      final stop = Feature(geometry: Point(coordinates: Position(coords[i + 1][0], coords[i + 1][1])), properties: {});
      stop.properties!['dist'] = distance(pt, stop.geometry!);
      // sectionLength
      final sectionLength = distance(start.geometry!, stop.geometry!);
      //perpendicular
      final heightDistance = math.max((start.properties!['dist'] as num), (stop.properties!['dist'] as num));
      final direction = bearing(start.geometry!, stop.geometry!);
      final perpendicularPt1 = destination(pt, heightDistance, direction + 90);
      final perpendicularPt2 = destination(pt, heightDistance, direction - 90);
      final intersect = lineIntersects(
        LineString(coordinates: [perpendicularPt1.coordinates, perpendicularPt2.coordinates]),
        LineString(coordinates: [start.geometry!.coordinates, stop.geometry!.coordinates]),
      );
      Feature<Point>? intersectPt;
      if (intersect.features.length > 0) {
        intersectPt = intersect.features[0];
        intersectPt!.properties!['dist'] = distance(pt, intersectPt.geometry!);
        intersectPt.properties!['location'] = length + distance(start.geometry!, intersectPt.geometry!);
      }

      if (start.properties!['dist'] < (closestPt.properties!['dist'] ?? 0)) {
        closestPt = start;
        closestPt.properties!['index'] = i;
        closestPt.properties!['location'] = length;
      }

      if (stop.properties!['dist'] < (closestPt.properties!['dist'] ?? 0)) {
        closestPt = stop;
        closestPt.properties!['index'] = i + 1;
        closestPt.properties!['location'] = length + sectionLength;
      }

      if (intersectPt != null && intersectPt.properties!['dist'] < (closestPt.properties!['dist'] ?? 0)) {
        closestPt = intersectPt;
        closestPt.properties!['index'] = i;
      }
      // update length
      length += sectionLength;
    }
  });

  return closestPt;
}
