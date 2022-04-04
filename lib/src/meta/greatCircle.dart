import 'dart:math' as math;

var D2R = math.pi / 180;
var R2D = 180 / math.pi;

class Coord {
  final num lon;
  final num lat;
  final num x;
  final num y;

  Coord(this.lon, this.lat)
      : x = D2R * lon,
        y = D2R * lat;
}
