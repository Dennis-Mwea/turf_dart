import 'package:turf/helpers.dart' hide Point;
import 'package:turf/src/meta/spline.dart';

Feature<LineString> bezier(Feature<LineString> line, {Map<String, dynamic>? options}) {
  // Optional params
  int resolution = options?['resolution'] ?? 10000;
  double sharpness = options?['sharpness'] ?? 0.85;

  List<Position> coords = [];
  List<Point> points = getGeom(line).coordinates.map<Point>((pt) => Point(x: pt[0], y: pt[1])).toList();
  Spline spline = Spline({'duration': resolution, 'points': points, 'sharpness': sharpness});
  pushCoord(int time) {
    var pos = spline.pos(time);
    if ((time / 100).floor() % 2 == 0) {
      coords.add(Position(pos.x, pos.y));
    }
  }

  for (int i = 0; i < spline.duration; i += 10) {
    pushCoord(i);
  }
  pushCoord(spline.duration);

  return Feature<LineString>(geometry: LineString(coordinates: coords));
}

GeometryType getGeom(dynamic geojson) {
  if (geojson.runtimeType == Feature<LineString>) {
    return geojson.geometry;
  }

  return geojson;
}
