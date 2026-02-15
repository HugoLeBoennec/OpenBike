import '../../domain/entities/route.dart';
import '../services/route_simulator.dart';
import '../../../infrastructure/files/gpx_parser.dart';

class SimulateRoute {
  SimulateRoute({
    required RouteSimulator simulator,
    required GpxRouteParser parser,
  })  : _simulator = simulator,
        _parser = parser;

  final RouteSimulator _simulator;
  final GpxRouteParser _parser;

  Route loadGpx(String gpxContent, {String? name}) {
    return _parser.parse(gpxContent, name: name);
  }

  void start(Route route, {double mass = 80, double crr = 0.004, double cda = 0.32}) {
    _simulator.start(route, mass: mass, crr: crr, cda: cda);
  }

  void pause() => _simulator.pause();
  void resume() => _simulator.resume();
  void stop() => _simulator.stop();
}
