import '../../domain/entities/ride.dart';
import '../../domain/ports/export_port.dart';

class ExportActivity {
  final List<ExportPort> _exportPorts;

  ExportActivity(this._exportPorts);

  Future<Map<ExportPort, String>> call(Ride ride, ExportFormat format) async {
    final results = <ExportPort, String>{};
    for (final port in _exportPorts) {
      final id = await port.exportActivity(ride, format);
      results[port] = id;
    }
    return results;
  }
}
