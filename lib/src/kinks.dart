import 'package:sweepline_intersections/sweepline_intersections.dart';
import 'package:turf/helpers.dart';

/// Takes any [LineString]/[Polygon] GeoJSON and returns the intersecting point(s).
lineIntersects(
  dynamic line1,
  dynamic line2, {
  bool removeDuplicates = true,
  bool ignoreSelfIntersections = false,
}) {
  List<Feature<GeometryObject>> features = [];

  switch (line1.type.runtimeType) {
    case FeatureCollection:
      features.addAll((line1 as FeatureCollection).features);
      break;
    case Feature:
      features.add(line1 as Feature);
      break;
    case LineString:
    case Polygon:
    case MultiLineString:
    case MultiPolygon:
      features.add(Feature(geometry: line1));
      break;
  }

  switch (line2.type.runtimeType) {
    case FeatureCollection:
      features.addAll((line2 as FeatureCollection).features);
      break;
    case Feature:
      features.add(line2 as Feature);
      break;
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
    const Map<String, bool> unique = {};
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

  return FeatureCollection(features: results.map((e) => Feature(geometry: Point(coordinates: e))).toList());
}
