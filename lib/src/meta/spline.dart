import 'dart:math' as math;

class Point {
  final double x;
  final double y;
  final double? z;

  Point({required this.x, required this.y, this.z});

  Point copyWith({double? x, double? y, double? z}) => Point(x: x ?? this.x, y: y ?? this.y, z: z ?? this.z);
}

class Spline {
  late int duration;
  List<Point> points = [];
  late double sharpness;
  List<Point> centers = [];
  List<List<Point>> controls = [];
  late int stepLength;
  late int length;
  late int delay;
  List steps = [];

  Spline(Map<String, dynamic>? options)
      : points = options?['points'] ?? [],
        duration = options?['duration'] ?? 10000,
        sharpness = options?['sharpness'] ?? 0.85,
        centers = [],
        controls = [],
        stepLength = options?['stepLength'] ?? 60,
        delay = 0 {
    length = points.length;

    // this is to ensure compatibility with the 2d version
    for (int i = 0; i < length; i++) {
      points[i] = points[i].copyWith(z: points[i].z ?? 0);
    }
    for (int i = 0; i < length - 1; i++) {
      Point p1 = points[i];
      Point p2 = points[i + 1];
      centers.add(Point(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2, z: (p1.z ?? 0 + (p2.z ?? 0)) / 2));
    }

    controls.add([points[0], points[0]]);
    for (int i = 0; i < centers.length - 1; i++) {
      double dx = points[i + 1].x - (centers[i].x + centers[i + 1].x) / 2;
      double dy = points[i + 1].y - (centers[i].y + centers[i + 1].y) / 2;
      double dz = points[i + 1].z ?? 0 - (centers[i].y + (centers[i + 1].z ?? 0)) / 2;
      controls.add([
        Point(
            x: (1.0 - sharpness) * points[i + 1].x + sharpness * (centers[i].x + dx),
            y: (1.0 - sharpness) * points[i + 1].y + sharpness * (centers[i].y + dy),
            z: (1.0 - sharpness) * (points[i + 1].z ?? 0) + sharpness * (centers[i].z ?? 0 + dz)),
        Point(
            x: (1.0 - sharpness) * points[i + 1].x + sharpness * (centers[i + 1].x + dx),
            y: (1.0 - sharpness) * points[i + 1].y + sharpness * (centers[i + 1].y + dy),
            z: (1.0 - sharpness) * (points[i + 1].z ?? 0) + sharpness * (centers[i + 1].z ?? 0 + dz)),
      ]);
    }

    controls.add([points[length - 1], points[length - 1]]);
    steps = cacheSteps(stepLength);
  }

  /// Caches an array of equidistant (more or less) points on the curve.
  List cacheSteps(int mindist) {
    List steps = [];
    var laststep = pos(0);
    steps.add(0);
    for (int t = 0; t < duration; t += 10) {
      var step = pos(t);
      double dist = math
          .sqrt((step.x - laststep.x) * (step.x - laststep.x) + (step.y - laststep.y) * (step.y - laststep.y) + (step.z - laststep.z) * (step.z - laststep.z));
      if (dist > mindist) {
        steps.add(t);
        laststep = step;
      }
    }

    return steps;
  }

  /// returns angle and speed in the given point in the curve
  Map<String, double> vector(t) {
    var p1 = pos(t + 10);
    var p2 = pos(t - 10);

    return {
      'angle': (180 * math.atan2(p1.y - p2.y, p1.x - p2.x)) / 3.14,
      'speed': math.sqrt((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y) + (p2.z - p1.z) * (p2.z - p1.z)),
    };
  }

  /// Gets the position of the point, given time.
  ///
  /// WARNING: The speed is not constant. The time it takes between control points is constant.
  ///
  /// For constant speed, use Spline.steps[i];
  pos(int time) {
    int t = time - delay;
    if (t < 0) {
      t = 0;
    }
    if (t > duration) {
      t = duration - 1;
    }
    // t = t-this.delay;
    double t2 = t / duration;
    if (t2 >= 1) {
      return points[length - 1];
    }

    int n = ((points.length - 1) * t2).floor();
    print('CoordsLength: $n');
    double t1 = (length - 1) * t2 - n;

    return bezier(t1, points[n], controls[n][1], controls[n + 1][0], points[n + 1]);
  }
}

bezier(double t, Point p1, Point c1, Point c2, Point p2) {
  List<double> b = B(t);

  return Point(
    x: p2.x * b[0] + c2.x * b[1] + c1.x * b[2] + p1.x * b[3],
    y: p2.y * b[0] + c2.y * b[1] + c1.y * b[2] + p1.y * b[3],
    z: (p2.z ?? 0) * b[0] + (c2.z ?? 0) * b[1] + (c1.z ?? 0) * b[2] + (p1.z ?? 0) * b[3],
  );
}

List<double> B(double t) {
  double t2 = t * t;
  double t3 = t2 * t;

  return [t3, 3 * t2 * (1 - t), 3 * t * (1 - t) * (1 - t), (1 - t) * (1 - t) * (1 - t)];
}
