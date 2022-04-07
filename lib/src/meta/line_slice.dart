import 'package:turf/helpers.dart';
import 'package:turf/src/invariant.dart';
import 'package:turf/src/pointOnLine.dart';

lineSlice(Point start, Point stop, Feature<LineString> line) {
  var coords = getCoords(line);
  if (getType(line) != "LineString") throw Exception("line must be a LineString");

  var startVertex = nearestPointOnLine(line, start);
  var stopVertex = nearestPointOnLine(line, stop);

  var ends;
  if (startVertex.properties!['index'] <= stopVertex.properties!['index']) {
    ends = [startVertex, stopVertex];
  } else {
    ends = [stopVertex, startVertex];
  }
  var clipCoords = <Position>[ends[0].geometry.coordinates];
  for (var i = ends[0].properties.index + 1; i < ends[1].properties.index + 1; i++) {
    clipCoords.add(coords[i]);
  }

  clipCoords.add(ends[1].geometry.coordinates);

  return Feature<LineString>(geometry: LineString(coordinates: clipCoords), properties: line.properties);
}
