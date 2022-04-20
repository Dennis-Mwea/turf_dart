import 'package:sweepline_intersections/sweepline_intersections.dart';
import 'package:turf/helpers.dart';

/// Takes any [LineString]/[Polygon] GeoJSON and returns the intersecting point(s).
lineIntersects(GeometryType line1, GeometryType line2, {bool removeDuplicates = true, bool ignoreSelfIntersections = false}) {
  List<Feature<GeometryObject>> features = [];

  switch (line1.runtimeType) {
    case LineString:
    case Polygon:
    case MultiLineString:
    case MultiPolygon:
      features.add(Feature(geometry: line1));
      break;
  }

  switch (line2.runtimeType) {
    case LineString:
    case Polygon:
    case MultiLineString:
    case MultiPolygon:
      features.add(Feature(geometry: line2));
      break;
  }

  final intersections = sweeplineIntersections(FeatureCollection(features: features), ignoreSelfIntersections: ignoreSelfIntersections);
  List<Position> results = [];
  if (removeDuplicates) {
    final Map<String, bool> unique = {};
    intersections.forEach((intersection) {
      final key = intersection.join(",");
      if (!unique.containsKey(key)) {
        unique[key] = true;
        results.add(intersection);
      }
    });
  } else {
    results = intersections;
  }

  return FeatureCollection(features: results.map((e) => Feature(geometry: Point(coordinates: e), properties: {})).toList());
}
