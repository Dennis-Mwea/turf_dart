import 'package:turf/helpers.dart';
import 'package:turf/polyline.dart';

var feetToMiles = 0.000189394;
var feetToKilometers = 0.0003048;
var metersToFeet = 3.28084;
var userHasEnteredManeuverZone = false;

class CurrentStep {
  /// Configuration options
  /// @param {object} `units` - either `miles` or `km`. `maxReRouteDistance` - max distance the user can be from the route. `maxSnapToLocation` - max distance to snap user to route. `completionDistance` - distance away from end of step that is considered a completion. If this distance is shorter than the step distance, it will be changed to 10ft. `warnUserTime` - number of seconds ahead of maneuver to warn user about maneuver. `shortCompletionDistance` - if the step is shorter than the `completionDistance`, this distance will be used to calculate if the step has been completed. `userBearingCompleteThreshold` - Bearing threshold for the user to complete a step
  final Map<String, dynamic> options;

  CurrentStep({Map<String, dynamic>? opts})
      : options = {'units': opts?['units'] ?? 'miles', 'userBearingCompleteThreshold': opts?['userBearingCompleteThreshold'] ?? 30} {
    options['maxReRouteDistance'] = opts?['maxReRouteDistance'] != null
        ? opts!['maxReRouteDistance']
        : opts?['units'] == 'miles'
            ? 150 * feetToMiles
            : 150 * feetToKilometers;
    options['maxSnapToLocation'] = opts?['maxSnapToLocation'] != null
        ? opts!['maxSnapToLocation']
        : opts?['units'] == 'miles'
            ? 50 * feetToMiles
            : 50 * feetToKilometers;
    options['completionDistance'] = opts?['completionDistance'] != null
        ? opts!['completionDistance']
        : opts?['units'] == 'miles'
            ? 50 * feetToMiles
            : 50 * feetToKilometers;
    options['shortCompletionDistance'] = opts?['shortCompletionDistance'] != null
        ? opts!['shortCompletionDistance']
        : opts?['units'] == 'miles'
            ? 10 * feetToMiles
            : 10 * feetToKilometers;
  }
}

/// Given a user location and route, calculates closest step to user.
/// @param {object} user point feature representing user location. Must be a valid GeoJSON object.
/// @param {object} route from [Mapbox directions API](https://www.mapbox.com/developers/api/directions/).
/// The Mapbox directions API returns an object with up to 2 `routes` on the `route` key. `getCurrentStep` expects of these routes, either the first or second.
/// @param {number} userCurrentStep along the route
/// @param {number} userBearing current user bearing. If provided, the user must be within a certain threadhold of the steps exit bearing to successful complete a step.
/// @returns {object} Containing 3 keys: `step`, `distance`, `snapToLocation`. `distance` is the line distance to end of step, `absoluteDistance` is the users absolute distance to the end of the route `snapToLocation` is location along route which is closest to the user.
Map<String, dynamic> getCurrentStep(GeoJSONObject geoJson, Map<String, dynamic> route, num userCurrentStep, num userBearing) {
  var currentStep = {};
  var stepCoordinates;
  if (route['steps'][userCurrentStep].geometry.runtimeType == String) {
    stepCoordinates = decodePolyline(route['steps'][userCurrentStep].geometry).map((coordinate) => [coordinate[1], coordinate[0]]);
  } else {
    stepCoordinates = route['steps'][userCurrentStep].geometry.coordinates;
  }

  var segmentRoute = Feature.fromJson({
    'geometry': {'type': 'LineString', 'coordinates': stepCoordinates}
  });

  var closestPoint = turfPointOnLine(segmentRoute, user);

  return {'step': '', 'distance': '', 'snapToLocation': '', 'absoluteDistance': ''};
}
