import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';
import 'package:turf/line_segment.dart';

double? length(GeoJSONObject geojson, [Unit unit = Unit.kilometers]) {
  return segmentReduce(geojson, (previousValue, segment, _, __, ___, ____, _____) {
    final coords = segment.geometry!.coordinates;

    return previousValue! + (distance(Point(coordinates: coords[0]), Point(coordinates: coords[1]), unit) as double);
  }, 0);
}
