/// Parsed General FE Data (page 16).
class AntFecGeneralData {
  const AntFecGeneralData({
    this.equipmentType,
    this.elapsedTime,
    this.distanceTraveled,
    this.speed,
    this.heartRate,
  });

  final int? equipmentType;
  final double? elapsedTime;
  final int? distanceTraveled;
  final double? speed; // km/h
  final int? heartRate; // BPM
}

/// Parsed Trainer Specific Data (page 25).
class AntFecTrainerData {
  const AntFecTrainerData({
    this.eventCount,
    this.instantaneousCadence,
    this.accumulatedPower,
    this.instantaneousPower,
    this.trainerStatus,
  });

  final int? eventCount;
  final int? instantaneousCadence; // RPM
  final int? accumulatedPower; // watts (accumulated)
  final int? instantaneousPower; // watts (instant)
  final int? trainerStatus;
}

/// Parsed Manufacturer Info (page 80).
class AntFecManufacturerInfo {
  const AntFecManufacturerInfo({
    this.hardwareRevision,
    this.manufacturerId,
    this.modelNumber,
  });

  final int? hardwareRevision;
  final int? manufacturerId;
  final int? modelNumber;
}

/// Parsed Product Info (page 81).
class AntFecProductInfo {
  const AntFecProductInfo({this.softwareRevision, this.serialNumber});

  final int? softwareRevision;
  final int? serialNumber;
}

/// Parses ANT+ FE-C broadcast data pages (8-byte payloads).
class AntFecParser {
  /// Returns the data page number from byte 0 of the payload.
  int getPageNumber(List<int> payload) {
    if (payload.isEmpty) return -1;
    return payload[0];
  }

  /// Page 16: General FE Data.
  AntFecGeneralData parseGeneralFe(List<int> data) {
    // data[0] = page (16)
    // data[1] = equipment type (bits 0-4)
    // data[2] = elapsed time (0.25s increments, rolls at 64s)
    // data[3] = distance traveled (meters, rolls at 256)
    // data[4-5] = speed (0.001 m/s LE, 0xFFFF = invalid)
    // data[6] = heart rate (0xFF = invalid)
    // data[7] = capabilities + FE state
    final equipmentType = data[1] & 0x1F;
    final elapsedTime = data[2] * 0.25;
    final distance = data[3];
    final speedRaw = data[4] | (data[5] << 8);
    final speed = speedRaw == 0xFFFF ? null : (speedRaw * 0.001 * 3.6);
    final heartRate = data[6] == 0xFF ? null : data[6];

    return AntFecGeneralData(
      equipmentType: equipmentType,
      elapsedTime: elapsedTime,
      distanceTraveled: distance,
      speed: speed,
      heartRate: heartRate,
    );
  }

  /// Page 25: Trainer Specific Data.
  AntFecTrainerData parseTrainerSpecific(List<int> data) {
    // data[0] = page (25)
    // data[1] = update event count (rolls at 256)
    // data[2] = instantaneous cadence (0xFF = invalid)
    // data[3-4] = accumulated power (LE, rolls at 65536)
    // data[5-6] bits 0-11 = instantaneous power (0xFFF = invalid)
    // data[6] bits 4-7 = trainer status / target power limits
    final eventCount = data[1];
    final cadence = data[2] == 0xFF ? null : data[2];
    final accumulatedPower = data[3] | (data[4] << 8);
    final powerRaw = (data[5] | (data[6] << 8)) & 0x0FFF;
    final instantaneousPower = powerRaw == 0xFFF ? null : powerRaw;
    final trainerStatus = (data[6] >> 4) & 0x0F;

    return AntFecTrainerData(
      eventCount: eventCount,
      instantaneousCadence: cadence,
      accumulatedPower: accumulatedPower,
      instantaneousPower: instantaneousPower,
      trainerStatus: trainerStatus,
    );
  }

  /// Page 80: Manufacturer Information.
  AntFecManufacturerInfo parseManufacturerInfo(List<int> data) {
    return AntFecManufacturerInfo(
      hardwareRevision: data[3],
      manufacturerId: data[4] | (data[5] << 8),
      modelNumber: data[6] | (data[7] << 8),
    );
  }

  /// Page 81: Product Information.
  AntFecProductInfo parseProductInfo(List<int> data) {
    return AntFecProductInfo(
      softwareRevision: data[3],
      serialNumber:
          data[4] | (data[5] << 8) | (data[6] << 16) | (data[7] << 24),
    );
  }

  /// Computes delta between accumulated values, handling rollover.
  static int accumulatedDelta(int current, int previous, int maxValue) {
    if (current >= previous) return current - previous;
    return (maxValue - previous) + current;
  }
}
