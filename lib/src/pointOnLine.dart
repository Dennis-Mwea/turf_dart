import 'dart:math' as math;

import 'package:turf/bearing.dart';
import 'package:turf/destination.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';
import 'package:turf/meta.dart';
import 'package:turf/src/invariant.dart';
import 'package:turf/src/kinks.dart';

abstract class NearestPointOnLine extends Feature<Point> {
  Map<String, dynamic>? properties = {
    // 'index'?: number;
    // 'dist'?: number;
    // 'location'?: number;
    // [key: string]: any;
  };
}

/// Takes a {@link Point} and a {@link LineString} and calculates the closest Point on the (Multi)LineString.
///
/// @name nearestPointOnLine
/// @param {Geometry|Feature<LineString|MultiLineString>} lines lines to snap to
/// @param {Geometry|Feature<Point>|number[]} pt point to snap from
/// @param {Object} [options={}] Optional parameters
/// @param {string} [options.units='kilometers'] can be degrees, radians, miles, or kilometers
/// @returns {Feature<Point>} closest point on the `line` to `point`. The properties object will contain three values: `index`: closest point was found on nth line part, `dist`: distance between pt and the closest point, `location`: distance along the line between start and the closest point.
/// @example
/// var line = turf.lineString([
///     [-77.031669, 38.878605],
///     [-77.029609, 38.881946],
///     [-77.020339, 38.884084],
///     [-77.025661, 38.885821],
///     [-77.021884, 38.889563],
///     [-77.019824, 38.892368]
/// ]);
/// var pt = turf.point([-77.037076, 38.884017]);
///
/// var snapped = turf.nearestPointOnLine(line, pt, {units: 'miles'});
///
/// //addToMap
/// var addToMap = [line, pt, snapped];
/// snapped.properties['marker-color'] = '#00f';
Feature<Point> nearestPointOnLine<G extends GeometryType>(Feature<G> lines, Point pt, {Map<String, dynamic>? options}) {
  var closestPt = Feature(
    geometry: Point(coordinates: Position(double.infinity, double.infinity, double.infinity)),
    properties: <String, dynamic>{},
  );
  var length = 0.0;

  flattenEach(lines, (line, _, __) {
    final coords = getCoords(line);

    for (var i = 0; i < coords.length - 1; i++) {
      //start
      final start = Feature(geometry: Point(coordinates: Position(coords[i][0], coords[i][1])));
      start.properties!['dist'] = distance(pt, start.geometry!);
      //stop
      final stop = Feature(geometry: Point(coordinates: Position(coords[i + 1][0], coords[i + 1][1])));
      stop.properties!['dist'] = distance(pt, stop.geometry!);
      // sectionLength
      final sectionLength = distance(start.geometry!, stop.geometry!);
      //perpendicular
      final heightDistance = math.max((start.properties!['dist'] as num), (stop.properties!['dist'] as num));
      final direction = bearing(start.geometry!, stop.geometry!);
      final perpendicularPt1 = destination(pt, heightDistance, direction + 90);
      final perpendicularPt2 = destination(pt, heightDistance, direction - 90);
      final intersect = lineIntersects(
        Feature(geometry: LineString(coordinates: [perpendicularPt1.coordinates, perpendicularPt2.coordinates])),
        Feature(geometry: LineString(coordinates: [start.geometry.coordinates, stop.geometry.coordinates])),
      );
      var intersectPt;
      if (intersect.features.length > 0) {
        intersectPt = intersect.features[0];
        intersectPt.properties!.dist = distance(pt, intersectPt);
        intersectPt.properties!.location = length + distance(start.geometry!, intersectPt);
      }

      if (start.properties!['dist'] < closestPt.properties!['dist']) {
        closestPt = start;
        closestPt.properties!['index'] = i;
        closestPt.properties!['location'] = length;
      }
      if (stop.properties!['dist'] < closestPt.properties['dist']) {
        closestPt = stop;
        closestPt.properties!['index'] = i + 1;
        closestPt.properties!['location'] = length + sectionLength;
      }
      if (intersectPt && intersectPt.properties!.dist < closestPt.properties!['dist']) {
        closestPt = intersectPt;
        closestPt.properties['index'] = i;
      }
      // update length
      length += sectionLength;
    }
  });

  return closestPt;
}
