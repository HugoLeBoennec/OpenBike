import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_device.freezed.dart';

enum DeviceProtocol { bleFtms, antFec, blePower, bleCsc }
enum ControlMode { erg, simulation, resistance }

@freezed
class TrainerDevice with _$TrainerDevice {
  const factory TrainerDevice({
    required String id,
    required String name,
    String? manufacturer,
    required DeviceProtocol protocol,
    @Default(false) bool isControllable,
    @Default([]) List<ControlMode> supportedModes,
  }) = _TrainerDevice;
}
