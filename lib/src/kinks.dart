lineIntersects(
  dynamic line1StartX,
  dynamic line1StartY,
  dynamic line1EndX,
  dynamic line1EndY,
  dynamic line2StartX,
  dynamic line2StartY,
  dynamic line2EndX,
  dynamic line2EndY,
) {
  // if the lines intersect, the result contains the x and y of the
  // intersection (treating the lines as infinite) and booleans for whether
  // line segment 1 or line segment 2 contain the point
  var denominator;
  var a;
  var b;
  var numerator1;
  var numerator2;
  var result = {
    'x': null,
    'y': null,
    'onLine1': false,
    'onLine2': false,
  };

  denominator = (line2EndY - line2StartY) * (line1EndX - line1StartX) - (line2EndX - line2StartX) * (line1EndY - line1StartY);
  if (denominator == 0) {
    return result['x'] != null && result['y'] != null ? result : false;
  }
  a = line1StartY - line2StartY;
  b = line1StartX - line2StartX;
  numerator1 = (line2EndX - line2StartX) * a - (line2EndY - line2StartY) * b;
  numerator2 = (line1EndX - line1StartX) * a - (line1EndY - line1StartY) * b;
  a = numerator1 / denominator;
  b = numerator2 / denominator;

  // if we cast these lines infinitely in both directions, they intersect here:
  result['x'] = line1StartX + a * (line1EndX - line1StartX);
  result['y'] = line1StartY + a * (line1EndY - line1StartY);

  // if line1 is a segment and line2 is infinite, they intersect if:
  if (a >= 0 && a <= 1) {
    result['onLine1'] = true;
  }

  // if line2 is a segment and line1 is infinite, they intersect if:
  if (b >= 0 && b <= 1) {
    result['onLine2'] = true;
  }
  // if line1 and line2 are segments, they intersect if both of the above are true
  if (result['onLine1'] as bool && result['onLine2'] as bool) {
    return [result['x'], result['y']];
  } else {
    return false;
  }
}
