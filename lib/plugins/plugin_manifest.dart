import 'package:freezed_annotation/freezed_annotation.dart';

part 'plugin_manifest.freezed.dart';

enum PluginType { device, export, format, widget }

@freezed
class PluginManifest with _$PluginManifest {
  const factory PluginManifest({
    required String id,
    required String name,
    required String version,
    required PluginType type,
    @Default('') String author,
    @Default('') String description,
    @Default([]) List<String> capabilities,
  }) = _PluginManifest;
}
