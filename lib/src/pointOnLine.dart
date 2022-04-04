import 'package:turf/helpers.dart';
import 'package:turf/meta.dart';
import 'package:turf/src/invariant.dart';
import 'package:turf/src/meta/greatCircle.dart';

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
NearestPointOnLine nearestPointOnLine<G extends GeometryType>(Feature<G> lines, Coord type, {Map<String, dynamic>? options}) {
  var closestPt = Position(double.infinity, double.infinity, double.infinity);
  var length = 0.0;

  flattenEach(lines, (line, _, __) {
    final coords = getCoords(line);

    for (var i = 0; i < coords.length - 1; i++) {
      //start
      const start = point(coords[i]);
      start.properties!.dist = distance(pt, start, options);
      //stop
      const stop = point(coords[i + 1]);
      stop.properties!.dist = distance(pt, stop, options);
    }
  });
}
