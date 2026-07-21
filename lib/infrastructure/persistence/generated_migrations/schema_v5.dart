// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Rides extends Table with TableInfo<Rides, RidesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Rides(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> startTime = GeneratedColumn<int>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> endTime = GeneratedColumn<int>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workout_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<double> avgPower = GeneratedColumn<double>(
    'avg_power',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> normalizedPower = GeneratedColumn<double>(
    'normalized_power',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> maxPower = GeneratedColumn<double>(
    'max_power',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> avgCadence = GeneratedColumn<double>(
    'avg_cadence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> avgHr = GeneratedColumn<double>(
    'avg_hr',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> maxHr = GeneratedColumn<double>(
    'max_hr',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> totalDistance = GeneratedColumn<double>(
    'total_distance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<int> pauseDurationSeconds = GeneratedColumn<int>(
    'pause_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> tss = GeneratedColumn<double>(
    'tss',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> intensityFactor = GeneratedColumn<double>(
    'intensity_factor',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> ftpAtTime = GeneratedColumn<double>(
    'ftp_at_time',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> elevationGainM = GeneratedColumn<double>(
    'elevation_gain_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startTime,
    endTime,
    title,
    notes,
    workoutId,
    status,
    avgPower,
    normalizedPower,
    maxPower,
    avgCadence,
    avgHr,
    maxHr,
    totalDistance,
    durationSeconds,
    pauseDurationSeconds,
    tss,
    intensityFactor,
    ftpAtTime,
    elevationGainM,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rides';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RidesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RidesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_time'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      avgPower: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_power'],
      ),
      normalizedPower: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}normalized_power'],
      ),
      maxPower: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_power'],
      ),
      avgCadence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_cadence'],
      ),
      avgHr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_hr'],
      ),
      maxHr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_hr'],
      ),
      totalDistance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_distance'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      pauseDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pause_duration_seconds'],
      ),
      tss: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tss'],
      ),
      intensityFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}intensity_factor'],
      ),
      ftpAtTime: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ftp_at_time'],
      ),
      elevationGainM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain_m'],
      ),
    );
  }

  @override
  Rides createAlias(String alias) {
    return Rides(attachedDatabase, alias);
  }
}

class RidesData extends DataClass implements Insertable<RidesData> {
  final String id;
  final int startTime;
  final int? endTime;
  final String? title;
  final String? notes;
  final String? workoutId;
  final String status;
  final double? avgPower;
  final double? normalizedPower;
  final double? maxPower;
  final double? avgCadence;
  final double? avgHr;
  final double? maxHr;
  final double? totalDistance;
  final int? durationSeconds;
  final int? pauseDurationSeconds;
  final double? tss;
  final double? intensityFactor;
  final double? ftpAtTime;
  final double? elevationGainM;
  const RidesData({
    required this.id,
    required this.startTime,
    this.endTime,
    this.title,
    this.notes,
    this.workoutId,
    required this.status,
    this.avgPower,
    this.normalizedPower,
    this.maxPower,
    this.avgCadence,
    this.avgHr,
    this.maxHr,
    this.totalDistance,
    this.durationSeconds,
    this.pauseDurationSeconds,
    this.tss,
    this.intensityFactor,
    this.ftpAtTime,
    this.elevationGainM,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start_time'] = Variable<int>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<int>(endTime);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || workoutId != null) {
      map['workout_id'] = Variable<String>(workoutId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || avgPower != null) {
      map['avg_power'] = Variable<double>(avgPower);
    }
    if (!nullToAbsent || normalizedPower != null) {
      map['normalized_power'] = Variable<double>(normalizedPower);
    }
    if (!nullToAbsent || maxPower != null) {
      map['max_power'] = Variable<double>(maxPower);
    }
    if (!nullToAbsent || avgCadence != null) {
      map['avg_cadence'] = Variable<double>(avgCadence);
    }
    if (!nullToAbsent || avgHr != null) {
      map['avg_hr'] = Variable<double>(avgHr);
    }
    if (!nullToAbsent || maxHr != null) {
      map['max_hr'] = Variable<double>(maxHr);
    }
    if (!nullToAbsent || totalDistance != null) {
      map['total_distance'] = Variable<double>(totalDistance);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || pauseDurationSeconds != null) {
      map['pause_duration_seconds'] = Variable<int>(pauseDurationSeconds);
    }
    if (!nullToAbsent || tss != null) {
      map['tss'] = Variable<double>(tss);
    }
    if (!nullToAbsent || intensityFactor != null) {
      map['intensity_factor'] = Variable<double>(intensityFactor);
    }
    if (!nullToAbsent || ftpAtTime != null) {
      map['ftp_at_time'] = Variable<double>(ftpAtTime);
    }
    if (!nullToAbsent || elevationGainM != null) {
      map['elevation_gain_m'] = Variable<double>(elevationGainM);
    }
    return map;
  }

  RidesCompanion toCompanion(bool nullToAbsent) {
    return RidesCompanion(
      id: Value(id),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      workoutId: workoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(workoutId),
      status: Value(status),
      avgPower: avgPower == null && nullToAbsent
          ? const Value.absent()
          : Value(avgPower),
      normalizedPower: normalizedPower == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedPower),
      maxPower: maxPower == null && nullToAbsent
          ? const Value.absent()
          : Value(maxPower),
      avgCadence: avgCadence == null && nullToAbsent
          ? const Value.absent()
          : Value(avgCadence),
      avgHr: avgHr == null && nullToAbsent
          ? const Value.absent()
          : Value(avgHr),
      maxHr: maxHr == null && nullToAbsent
          ? const Value.absent()
          : Value(maxHr),
      totalDistance: totalDistance == null && nullToAbsent
          ? const Value.absent()
          : Value(totalDistance),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      pauseDurationSeconds: pauseDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(pauseDurationSeconds),
      tss: tss == null && nullToAbsent ? const Value.absent() : Value(tss),
      intensityFactor: intensityFactor == null && nullToAbsent
          ? const Value.absent()
          : Value(intensityFactor),
      ftpAtTime: ftpAtTime == null && nullToAbsent
          ? const Value.absent()
          : Value(ftpAtTime),
      elevationGainM: elevationGainM == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationGainM),
    );
  }

  factory RidesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RidesData(
      id: serializer.fromJson<String>(json['id']),
      startTime: serializer.fromJson<int>(json['startTime']),
      endTime: serializer.fromJson<int?>(json['endTime']),
      title: serializer.fromJson<String?>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      workoutId: serializer.fromJson<String?>(json['workoutId']),
      status: serializer.fromJson<String>(json['status']),
      avgPower: serializer.fromJson<double?>(json['avgPower']),
      normalizedPower: serializer.fromJson<double?>(json['normalizedPower']),
      maxPower: serializer.fromJson<double?>(json['maxPower']),
      avgCadence: serializer.fromJson<double?>(json['avgCadence']),
      avgHr: serializer.fromJson<double?>(json['avgHr']),
      maxHr: serializer.fromJson<double?>(json['maxHr']),
      totalDistance: serializer.fromJson<double?>(json['totalDistance']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      pauseDurationSeconds: serializer.fromJson<int?>(
        json['pauseDurationSeconds'],
      ),
      tss: serializer.fromJson<double?>(json['tss']),
      intensityFactor: serializer.fromJson<double?>(json['intensityFactor']),
      ftpAtTime: serializer.fromJson<double?>(json['ftpAtTime']),
      elevationGainM: serializer.fromJson<double?>(json['elevationGainM']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startTime': serializer.toJson<int>(startTime),
      'endTime': serializer.toJson<int?>(endTime),
      'title': serializer.toJson<String?>(title),
      'notes': serializer.toJson<String?>(notes),
      'workoutId': serializer.toJson<String?>(workoutId),
      'status': serializer.toJson<String>(status),
      'avgPower': serializer.toJson<double?>(avgPower),
      'normalizedPower': serializer.toJson<double?>(normalizedPower),
      'maxPower': serializer.toJson<double?>(maxPower),
      'avgCadence': serializer.toJson<double?>(avgCadence),
      'avgHr': serializer.toJson<double?>(avgHr),
      'maxHr': serializer.toJson<double?>(maxHr),
      'totalDistance': serializer.toJson<double?>(totalDistance),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'pauseDurationSeconds': serializer.toJson<int?>(pauseDurationSeconds),
      'tss': serializer.toJson<double?>(tss),
      'intensityFactor': serializer.toJson<double?>(intensityFactor),
      'ftpAtTime': serializer.toJson<double?>(ftpAtTime),
      'elevationGainM': serializer.toJson<double?>(elevationGainM),
    };
  }

  RidesData copyWith({
    String? id,
    int? startTime,
    Value<int?> endTime = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> workoutId = const Value.absent(),
    String? status,
    Value<double?> avgPower = const Value.absent(),
    Value<double?> normalizedPower = const Value.absent(),
    Value<double?> maxPower = const Value.absent(),
    Value<double?> avgCadence = const Value.absent(),
    Value<double?> avgHr = const Value.absent(),
    Value<double?> maxHr = const Value.absent(),
    Value<double?> totalDistance = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    Value<int?> pauseDurationSeconds = const Value.absent(),
    Value<double?> tss = const Value.absent(),
    Value<double?> intensityFactor = const Value.absent(),
    Value<double?> ftpAtTime = const Value.absent(),
    Value<double?> elevationGainM = const Value.absent(),
  }) => RidesData(
    id: id ?? this.id,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    title: title.present ? title.value : this.title,
    notes: notes.present ? notes.value : this.notes,
    workoutId: workoutId.present ? workoutId.value : this.workoutId,
    status: status ?? this.status,
    avgPower: avgPower.present ? avgPower.value : this.avgPower,
    normalizedPower: normalizedPower.present
        ? normalizedPower.value
        : this.normalizedPower,
    maxPower: maxPower.present ? maxPower.value : this.maxPower,
    avgCadence: avgCadence.present ? avgCadence.value : this.avgCadence,
    avgHr: avgHr.present ? avgHr.value : this.avgHr,
    maxHr: maxHr.present ? maxHr.value : this.maxHr,
    totalDistance: totalDistance.present
        ? totalDistance.value
        : this.totalDistance,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    pauseDurationSeconds: pauseDurationSeconds.present
        ? pauseDurationSeconds.value
        : this.pauseDurationSeconds,
    tss: tss.present ? tss.value : this.tss,
    intensityFactor: intensityFactor.present
        ? intensityFactor.value
        : this.intensityFactor,
    ftpAtTime: ftpAtTime.present ? ftpAtTime.value : this.ftpAtTime,
    elevationGainM: elevationGainM.present
        ? elevationGainM.value
        : this.elevationGainM,
  );
  RidesData copyWithCompanion(RidesCompanion data) {
    return RidesData(
      id: data.id.present ? data.id.value : this.id,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      status: data.status.present ? data.status.value : this.status,
      avgPower: data.avgPower.present ? data.avgPower.value : this.avgPower,
      normalizedPower: data.normalizedPower.present
          ? data.normalizedPower.value
          : this.normalizedPower,
      maxPower: data.maxPower.present ? data.maxPower.value : this.maxPower,
      avgCadence: data.avgCadence.present
          ? data.avgCadence.value
          : this.avgCadence,
      avgHr: data.avgHr.present ? data.avgHr.value : this.avgHr,
      maxHr: data.maxHr.present ? data.maxHr.value : this.maxHr,
      totalDistance: data.totalDistance.present
          ? data.totalDistance.value
          : this.totalDistance,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      pauseDurationSeconds: data.pauseDurationSeconds.present
          ? data.pauseDurationSeconds.value
          : this.pauseDurationSeconds,
      tss: data.tss.present ? data.tss.value : this.tss,
      intensityFactor: data.intensityFactor.present
          ? data.intensityFactor.value
          : this.intensityFactor,
      ftpAtTime: data.ftpAtTime.present ? data.ftpAtTime.value : this.ftpAtTime,
      elevationGainM: data.elevationGainM.present
          ? data.elevationGainM.value
          : this.elevationGainM,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RidesData(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('workoutId: $workoutId, ')
          ..write('status: $status, ')
          ..write('avgPower: $avgPower, ')
          ..write('normalizedPower: $normalizedPower, ')
          ..write('maxPower: $maxPower, ')
          ..write('avgCadence: $avgCadence, ')
          ..write('avgHr: $avgHr, ')
          ..write('maxHr: $maxHr, ')
          ..write('totalDistance: $totalDistance, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('pauseDurationSeconds: $pauseDurationSeconds, ')
          ..write('tss: $tss, ')
          ..write('intensityFactor: $intensityFactor, ')
          ..write('ftpAtTime: $ftpAtTime, ')
          ..write('elevationGainM: $elevationGainM')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startTime,
    endTime,
    title,
    notes,
    workoutId,
    status,
    avgPower,
    normalizedPower,
    maxPower,
    avgCadence,
    avgHr,
    maxHr,
    totalDistance,
    durationSeconds,
    pauseDurationSeconds,
    tss,
    intensityFactor,
    ftpAtTime,
    elevationGainM,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RidesData &&
          other.id == this.id &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.workoutId == this.workoutId &&
          other.status == this.status &&
          other.avgPower == this.avgPower &&
          other.normalizedPower == this.normalizedPower &&
          other.maxPower == this.maxPower &&
          other.avgCadence == this.avgCadence &&
          other.avgHr == this.avgHr &&
          other.maxHr == this.maxHr &&
          other.totalDistance == this.totalDistance &&
          other.durationSeconds == this.durationSeconds &&
          other.pauseDurationSeconds == this.pauseDurationSeconds &&
          other.tss == this.tss &&
          other.intensityFactor == this.intensityFactor &&
          other.ftpAtTime == this.ftpAtTime &&
          other.elevationGainM == this.elevationGainM);
}

class RidesCompanion extends UpdateCompanion<RidesData> {
  final Value<String> id;
  final Value<int> startTime;
  final Value<int?> endTime;
  final Value<String?> title;
  final Value<String?> notes;
  final Value<String?> workoutId;
  final Value<String> status;
  final Value<double?> avgPower;
  final Value<double?> normalizedPower;
  final Value<double?> maxPower;
  final Value<double?> avgCadence;
  final Value<double?> avgHr;
  final Value<double?> maxHr;
  final Value<double?> totalDistance;
  final Value<int?> durationSeconds;
  final Value<int?> pauseDurationSeconds;
  final Value<double?> tss;
  final Value<double?> intensityFactor;
  final Value<double?> ftpAtTime;
  final Value<double?> elevationGainM;
  final Value<int> rowid;
  const RidesCompanion({
    this.id = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.status = const Value.absent(),
    this.avgPower = const Value.absent(),
    this.normalizedPower = const Value.absent(),
    this.maxPower = const Value.absent(),
    this.avgCadence = const Value.absent(),
    this.avgHr = const Value.absent(),
    this.maxHr = const Value.absent(),
    this.totalDistance = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.pauseDurationSeconds = const Value.absent(),
    this.tss = const Value.absent(),
    this.intensityFactor = const Value.absent(),
    this.ftpAtTime = const Value.absent(),
    this.elevationGainM = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RidesCompanion.insert({
    required String id,
    required int startTime,
    this.endTime = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.workoutId = const Value.absent(),
    required String status,
    this.avgPower = const Value.absent(),
    this.normalizedPower = const Value.absent(),
    this.maxPower = const Value.absent(),
    this.avgCadence = const Value.absent(),
    this.avgHr = const Value.absent(),
    this.maxHr = const Value.absent(),
    this.totalDistance = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.pauseDurationSeconds = const Value.absent(),
    this.tss = const Value.absent(),
    this.intensityFactor = const Value.absent(),
    this.ftpAtTime = const Value.absent(),
    this.elevationGainM = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startTime = Value(startTime),
       status = Value(status);
  static Insertable<RidesData> custom({
    Expression<String>? id,
    Expression<int>? startTime,
    Expression<int>? endTime,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? workoutId,
    Expression<String>? status,
    Expression<double>? avgPower,
    Expression<double>? normalizedPower,
    Expression<double>? maxPower,
    Expression<double>? avgCadence,
    Expression<double>? avgHr,
    Expression<double>? maxHr,
    Expression<double>? totalDistance,
    Expression<int>? durationSeconds,
    Expression<int>? pauseDurationSeconds,
    Expression<double>? tss,
    Expression<double>? intensityFactor,
    Expression<double>? ftpAtTime,
    Expression<double>? elevationGainM,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (workoutId != null) 'workout_id': workoutId,
      if (status != null) 'status': status,
      if (avgPower != null) 'avg_power': avgPower,
      if (normalizedPower != null) 'normalized_power': normalizedPower,
      if (maxPower != null) 'max_power': maxPower,
      if (avgCadence != null) 'avg_cadence': avgCadence,
      if (avgHr != null) 'avg_hr': avgHr,
      if (maxHr != null) 'max_hr': maxHr,
      if (totalDistance != null) 'total_distance': totalDistance,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (pauseDurationSeconds != null)
        'pause_duration_seconds': pauseDurationSeconds,
      if (tss != null) 'tss': tss,
      if (intensityFactor != null) 'intensity_factor': intensityFactor,
      if (ftpAtTime != null) 'ftp_at_time': ftpAtTime,
      if (elevationGainM != null) 'elevation_gain_m': elevationGainM,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RidesCompanion copyWith({
    Value<String>? id,
    Value<int>? startTime,
    Value<int?>? endTime,
    Value<String?>? title,
    Value<String?>? notes,
    Value<String?>? workoutId,
    Value<String>? status,
    Value<double?>? avgPower,
    Value<double?>? normalizedPower,
    Value<double?>? maxPower,
    Value<double?>? avgCadence,
    Value<double?>? avgHr,
    Value<double?>? maxHr,
    Value<double?>? totalDistance,
    Value<int?>? durationSeconds,
    Value<int?>? pauseDurationSeconds,
    Value<double?>? tss,
    Value<double?>? intensityFactor,
    Value<double?>? ftpAtTime,
    Value<double?>? elevationGainM,
    Value<int>? rowid,
  }) {
    return RidesCompanion(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      workoutId: workoutId ?? this.workoutId,
      status: status ?? this.status,
      avgPower: avgPower ?? this.avgPower,
      normalizedPower: normalizedPower ?? this.normalizedPower,
      maxPower: maxPower ?? this.maxPower,
      avgCadence: avgCadence ?? this.avgCadence,
      avgHr: avgHr ?? this.avgHr,
      maxHr: maxHr ?? this.maxHr,
      totalDistance: totalDistance ?? this.totalDistance,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      pauseDurationSeconds: pauseDurationSeconds ?? this.pauseDurationSeconds,
      tss: tss ?? this.tss,
      intensityFactor: intensityFactor ?? this.intensityFactor,
      ftpAtTime: ftpAtTime ?? this.ftpAtTime,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<int>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<int>(endTime.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (avgPower.present) {
      map['avg_power'] = Variable<double>(avgPower.value);
    }
    if (normalizedPower.present) {
      map['normalized_power'] = Variable<double>(normalizedPower.value);
    }
    if (maxPower.present) {
      map['max_power'] = Variable<double>(maxPower.value);
    }
    if (avgCadence.present) {
      map['avg_cadence'] = Variable<double>(avgCadence.value);
    }
    if (avgHr.present) {
      map['avg_hr'] = Variable<double>(avgHr.value);
    }
    if (maxHr.present) {
      map['max_hr'] = Variable<double>(maxHr.value);
    }
    if (totalDistance.present) {
      map['total_distance'] = Variable<double>(totalDistance.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (pauseDurationSeconds.present) {
      map['pause_duration_seconds'] = Variable<int>(pauseDurationSeconds.value);
    }
    if (tss.present) {
      map['tss'] = Variable<double>(tss.value);
    }
    if (intensityFactor.present) {
      map['intensity_factor'] = Variable<double>(intensityFactor.value);
    }
    if (ftpAtTime.present) {
      map['ftp_at_time'] = Variable<double>(ftpAtTime.value);
    }
    if (elevationGainM.present) {
      map['elevation_gain_m'] = Variable<double>(elevationGainM.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RidesCompanion(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('workoutId: $workoutId, ')
          ..write('status: $status, ')
          ..write('avgPower: $avgPower, ')
          ..write('normalizedPower: $normalizedPower, ')
          ..write('maxPower: $maxPower, ')
          ..write('avgCadence: $avgCadence, ')
          ..write('avgHr: $avgHr, ')
          ..write('maxHr: $maxHr, ')
          ..write('totalDistance: $totalDistance, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('pauseDurationSeconds: $pauseDurationSeconds, ')
          ..write('tss: $tss, ')
          ..write('intensityFactor: $intensityFactor, ')
          ..write('ftpAtTime: $ftpAtTime, ')
          ..write('elevationGainM: $elevationGainM, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SensorReadings extends Table
    with TableInfo<SensorReadings, SensorReadingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SensorReadings(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  late final GeneratedColumn<String> rideId = GeneratedColumn<String>(
    'ride_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rides (id)',
    ),
  );
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<double> powerWatts = GeneratedColumn<double>(
    'power_watts',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> cadenceRpm = GeneratedColumn<double>(
    'cadence_rpm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<int> heartRateBpm = GeneratedColumn<int>(
    'heart_rate_bpm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> speedKmh = GeneratedColumn<double>(
    'speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
    'distance_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> gradePercent = GeneratedColumn<double>(
    'grade_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rideId,
    timestamp,
    powerWatts,
    cadenceRpm,
    heartRateBpm,
    speedKmh,
    distanceM,
    gradePercent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sensor_readings';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorReadingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorReadingsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rideId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ride_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
      powerWatts: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}power_watts'],
      ),
      cadenceRpm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cadence_rpm'],
      ),
      heartRateBpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}heart_rate_bpm'],
      ),
      speedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_kmh'],
      ),
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_m'],
      ),
      gradePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grade_percent'],
      ),
    );
  }

  @override
  SensorReadings createAlias(String alias) {
    return SensorReadings(attachedDatabase, alias);
  }
}

class SensorReadingsData extends DataClass
    implements Insertable<SensorReadingsData> {
  final int id;
  final String rideId;
  final int timestamp;
  final double? powerWatts;
  final double? cadenceRpm;
  final int? heartRateBpm;
  final double? speedKmh;
  final double? distanceM;
  final double? gradePercent;
  const SensorReadingsData({
    required this.id,
    required this.rideId,
    required this.timestamp,
    this.powerWatts,
    this.cadenceRpm,
    this.heartRateBpm,
    this.speedKmh,
    this.distanceM,
    this.gradePercent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ride_id'] = Variable<String>(rideId);
    map['timestamp'] = Variable<int>(timestamp);
    if (!nullToAbsent || powerWatts != null) {
      map['power_watts'] = Variable<double>(powerWatts);
    }
    if (!nullToAbsent || cadenceRpm != null) {
      map['cadence_rpm'] = Variable<double>(cadenceRpm);
    }
    if (!nullToAbsent || heartRateBpm != null) {
      map['heart_rate_bpm'] = Variable<int>(heartRateBpm);
    }
    if (!nullToAbsent || speedKmh != null) {
      map['speed_kmh'] = Variable<double>(speedKmh);
    }
    if (!nullToAbsent || distanceM != null) {
      map['distance_m'] = Variable<double>(distanceM);
    }
    if (!nullToAbsent || gradePercent != null) {
      map['grade_percent'] = Variable<double>(gradePercent);
    }
    return map;
  }

  SensorReadingsCompanion toCompanion(bool nullToAbsent) {
    return SensorReadingsCompanion(
      id: Value(id),
      rideId: Value(rideId),
      timestamp: Value(timestamp),
      powerWatts: powerWatts == null && nullToAbsent
          ? const Value.absent()
          : Value(powerWatts),
      cadenceRpm: cadenceRpm == null && nullToAbsent
          ? const Value.absent()
          : Value(cadenceRpm),
      heartRateBpm: heartRateBpm == null && nullToAbsent
          ? const Value.absent()
          : Value(heartRateBpm),
      speedKmh: speedKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(speedKmh),
      distanceM: distanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceM),
      gradePercent: gradePercent == null && nullToAbsent
          ? const Value.absent()
          : Value(gradePercent),
    );
  }

  factory SensorReadingsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorReadingsData(
      id: serializer.fromJson<int>(json['id']),
      rideId: serializer.fromJson<String>(json['rideId']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      powerWatts: serializer.fromJson<double?>(json['powerWatts']),
      cadenceRpm: serializer.fromJson<double?>(json['cadenceRpm']),
      heartRateBpm: serializer.fromJson<int?>(json['heartRateBpm']),
      speedKmh: serializer.fromJson<double?>(json['speedKmh']),
      distanceM: serializer.fromJson<double?>(json['distanceM']),
      gradePercent: serializer.fromJson<double?>(json['gradePercent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rideId': serializer.toJson<String>(rideId),
      'timestamp': serializer.toJson<int>(timestamp),
      'powerWatts': serializer.toJson<double?>(powerWatts),
      'cadenceRpm': serializer.toJson<double?>(cadenceRpm),
      'heartRateBpm': serializer.toJson<int?>(heartRateBpm),
      'speedKmh': serializer.toJson<double?>(speedKmh),
      'distanceM': serializer.toJson<double?>(distanceM),
      'gradePercent': serializer.toJson<double?>(gradePercent),
    };
  }

  SensorReadingsData copyWith({
    int? id,
    String? rideId,
    int? timestamp,
    Value<double?> powerWatts = const Value.absent(),
    Value<double?> cadenceRpm = const Value.absent(),
    Value<int?> heartRateBpm = const Value.absent(),
    Value<double?> speedKmh = const Value.absent(),
    Value<double?> distanceM = const Value.absent(),
    Value<double?> gradePercent = const Value.absent(),
  }) => SensorReadingsData(
    id: id ?? this.id,
    rideId: rideId ?? this.rideId,
    timestamp: timestamp ?? this.timestamp,
    powerWatts: powerWatts.present ? powerWatts.value : this.powerWatts,
    cadenceRpm: cadenceRpm.present ? cadenceRpm.value : this.cadenceRpm,
    heartRateBpm: heartRateBpm.present ? heartRateBpm.value : this.heartRateBpm,
    speedKmh: speedKmh.present ? speedKmh.value : this.speedKmh,
    distanceM: distanceM.present ? distanceM.value : this.distanceM,
    gradePercent: gradePercent.present ? gradePercent.value : this.gradePercent,
  );
  SensorReadingsData copyWithCompanion(SensorReadingsCompanion data) {
    return SensorReadingsData(
      id: data.id.present ? data.id.value : this.id,
      rideId: data.rideId.present ? data.rideId.value : this.rideId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      powerWatts: data.powerWatts.present
          ? data.powerWatts.value
          : this.powerWatts,
      cadenceRpm: data.cadenceRpm.present
          ? data.cadenceRpm.value
          : this.cadenceRpm,
      heartRateBpm: data.heartRateBpm.present
          ? data.heartRateBpm.value
          : this.heartRateBpm,
      speedKmh: data.speedKmh.present ? data.speedKmh.value : this.speedKmh,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      gradePercent: data.gradePercent.present
          ? data.gradePercent.value
          : this.gradePercent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SensorReadingsData(')
          ..write('id: $id, ')
          ..write('rideId: $rideId, ')
          ..write('timestamp: $timestamp, ')
          ..write('powerWatts: $powerWatts, ')
          ..write('cadenceRpm: $cadenceRpm, ')
          ..write('heartRateBpm: $heartRateBpm, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('distanceM: $distanceM, ')
          ..write('gradePercent: $gradePercent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rideId,
    timestamp,
    powerWatts,
    cadenceRpm,
    heartRateBpm,
    speedKmh,
    distanceM,
    gradePercent,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SensorReadingsData &&
          other.id == this.id &&
          other.rideId == this.rideId &&
          other.timestamp == this.timestamp &&
          other.powerWatts == this.powerWatts &&
          other.cadenceRpm == this.cadenceRpm &&
          other.heartRateBpm == this.heartRateBpm &&
          other.speedKmh == this.speedKmh &&
          other.distanceM == this.distanceM &&
          other.gradePercent == this.gradePercent);
}

class SensorReadingsCompanion extends UpdateCompanion<SensorReadingsData> {
  final Value<int> id;
  final Value<String> rideId;
  final Value<int> timestamp;
  final Value<double?> powerWatts;
  final Value<double?> cadenceRpm;
  final Value<int?> heartRateBpm;
  final Value<double?> speedKmh;
  final Value<double?> distanceM;
  final Value<double?> gradePercent;
  const SensorReadingsCompanion({
    this.id = const Value.absent(),
    this.rideId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.powerWatts = const Value.absent(),
    this.cadenceRpm = const Value.absent(),
    this.heartRateBpm = const Value.absent(),
    this.speedKmh = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.gradePercent = const Value.absent(),
  });
  SensorReadingsCompanion.insert({
    this.id = const Value.absent(),
    required String rideId,
    required int timestamp,
    this.powerWatts = const Value.absent(),
    this.cadenceRpm = const Value.absent(),
    this.heartRateBpm = const Value.absent(),
    this.speedKmh = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.gradePercent = const Value.absent(),
  }) : rideId = Value(rideId),
       timestamp = Value(timestamp);
  static Insertable<SensorReadingsData> custom({
    Expression<int>? id,
    Expression<String>? rideId,
    Expression<int>? timestamp,
    Expression<double>? powerWatts,
    Expression<double>? cadenceRpm,
    Expression<int>? heartRateBpm,
    Expression<double>? speedKmh,
    Expression<double>? distanceM,
    Expression<double>? gradePercent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rideId != null) 'ride_id': rideId,
      if (timestamp != null) 'timestamp': timestamp,
      if (powerWatts != null) 'power_watts': powerWatts,
      if (cadenceRpm != null) 'cadence_rpm': cadenceRpm,
      if (heartRateBpm != null) 'heart_rate_bpm': heartRateBpm,
      if (speedKmh != null) 'speed_kmh': speedKmh,
      if (distanceM != null) 'distance_m': distanceM,
      if (gradePercent != null) 'grade_percent': gradePercent,
    });
  }

  SensorReadingsCompanion copyWith({
    Value<int>? id,
    Value<String>? rideId,
    Value<int>? timestamp,
    Value<double?>? powerWatts,
    Value<double?>? cadenceRpm,
    Value<int?>? heartRateBpm,
    Value<double?>? speedKmh,
    Value<double?>? distanceM,
    Value<double?>? gradePercent,
  }) {
    return SensorReadingsCompanion(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      timestamp: timestamp ?? this.timestamp,
      powerWatts: powerWatts ?? this.powerWatts,
      cadenceRpm: cadenceRpm ?? this.cadenceRpm,
      heartRateBpm: heartRateBpm ?? this.heartRateBpm,
      speedKmh: speedKmh ?? this.speedKmh,
      distanceM: distanceM ?? this.distanceM,
      gradePercent: gradePercent ?? this.gradePercent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rideId.present) {
      map['ride_id'] = Variable<String>(rideId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (powerWatts.present) {
      map['power_watts'] = Variable<double>(powerWatts.value);
    }
    if (cadenceRpm.present) {
      map['cadence_rpm'] = Variable<double>(cadenceRpm.value);
    }
    if (heartRateBpm.present) {
      map['heart_rate_bpm'] = Variable<int>(heartRateBpm.value);
    }
    if (speedKmh.present) {
      map['speed_kmh'] = Variable<double>(speedKmh.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (gradePercent.present) {
      map['grade_percent'] = Variable<double>(gradePercent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SensorReadingsCompanion(')
          ..write('id: $id, ')
          ..write('rideId: $rideId, ')
          ..write('timestamp: $timestamp, ')
          ..write('powerWatts: $powerWatts, ')
          ..write('cadenceRpm: $cadenceRpm, ')
          ..write('heartRateBpm: $heartRateBpm, ')
          ..write('speedKmh: $speedKmh, ')
          ..write('distanceM: $distanceM, ')
          ..write('gradePercent: $gradePercent')
          ..write(')'))
        .toString();
  }
}

class Laps extends Table with TableInfo<Laps, LapsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Laps(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  late final GeneratedColumn<String> rideId = GeneratedColumn<String>(
    'ride_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rides (id)',
    ),
  );
  late final GeneratedColumn<int> startIndex = GeneratedColumn<int>(
    'start_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> endIndex = GeneratedColumn<int>(
    'end_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> startTime = GeneratedColumn<int>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rideId,
    startIndex,
    endIndex,
    startTime,
    durationMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'laps';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LapsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LapsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rideId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ride_id'],
      )!,
      startIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_index'],
      )!,
      endIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_index'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
    );
  }

  @override
  Laps createAlias(String alias) {
    return Laps(attachedDatabase, alias);
  }
}

class LapsData extends DataClass implements Insertable<LapsData> {
  final int id;
  final String rideId;
  final int startIndex;
  final int endIndex;
  final int startTime;
  final int durationMs;
  const LapsData({
    required this.id,
    required this.rideId,
    required this.startIndex,
    required this.endIndex,
    required this.startTime,
    required this.durationMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ride_id'] = Variable<String>(rideId);
    map['start_index'] = Variable<int>(startIndex);
    map['end_index'] = Variable<int>(endIndex);
    map['start_time'] = Variable<int>(startTime);
    map['duration_ms'] = Variable<int>(durationMs);
    return map;
  }

  LapsCompanion toCompanion(bool nullToAbsent) {
    return LapsCompanion(
      id: Value(id),
      rideId: Value(rideId),
      startIndex: Value(startIndex),
      endIndex: Value(endIndex),
      startTime: Value(startTime),
      durationMs: Value(durationMs),
    );
  }

  factory LapsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LapsData(
      id: serializer.fromJson<int>(json['id']),
      rideId: serializer.fromJson<String>(json['rideId']),
      startIndex: serializer.fromJson<int>(json['startIndex']),
      endIndex: serializer.fromJson<int>(json['endIndex']),
      startTime: serializer.fromJson<int>(json['startTime']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rideId': serializer.toJson<String>(rideId),
      'startIndex': serializer.toJson<int>(startIndex),
      'endIndex': serializer.toJson<int>(endIndex),
      'startTime': serializer.toJson<int>(startTime),
      'durationMs': serializer.toJson<int>(durationMs),
    };
  }

  LapsData copyWith({
    int? id,
    String? rideId,
    int? startIndex,
    int? endIndex,
    int? startTime,
    int? durationMs,
  }) => LapsData(
    id: id ?? this.id,
    rideId: rideId ?? this.rideId,
    startIndex: startIndex ?? this.startIndex,
    endIndex: endIndex ?? this.endIndex,
    startTime: startTime ?? this.startTime,
    durationMs: durationMs ?? this.durationMs,
  );
  LapsData copyWithCompanion(LapsCompanion data) {
    return LapsData(
      id: data.id.present ? data.id.value : this.id,
      rideId: data.rideId.present ? data.rideId.value : this.rideId,
      startIndex: data.startIndex.present
          ? data.startIndex.value
          : this.startIndex,
      endIndex: data.endIndex.present ? data.endIndex.value : this.endIndex,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LapsData(')
          ..write('id: $id, ')
          ..write('rideId: $rideId, ')
          ..write('startIndex: $startIndex, ')
          ..write('endIndex: $endIndex, ')
          ..write('startTime: $startTime, ')
          ..write('durationMs: $durationMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, rideId, startIndex, endIndex, startTime, durationMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LapsData &&
          other.id == this.id &&
          other.rideId == this.rideId &&
          other.startIndex == this.startIndex &&
          other.endIndex == this.endIndex &&
          other.startTime == this.startTime &&
          other.durationMs == this.durationMs);
}

class LapsCompanion extends UpdateCompanion<LapsData> {
  final Value<int> id;
  final Value<String> rideId;
  final Value<int> startIndex;
  final Value<int> endIndex;
  final Value<int> startTime;
  final Value<int> durationMs;
  const LapsCompanion({
    this.id = const Value.absent(),
    this.rideId = const Value.absent(),
    this.startIndex = const Value.absent(),
    this.endIndex = const Value.absent(),
    this.startTime = const Value.absent(),
    this.durationMs = const Value.absent(),
  });
  LapsCompanion.insert({
    this.id = const Value.absent(),
    required String rideId,
    required int startIndex,
    required int endIndex,
    required int startTime,
    required int durationMs,
  }) : rideId = Value(rideId),
       startIndex = Value(startIndex),
       endIndex = Value(endIndex),
       startTime = Value(startTime),
       durationMs = Value(durationMs);
  static Insertable<LapsData> custom({
    Expression<int>? id,
    Expression<String>? rideId,
    Expression<int>? startIndex,
    Expression<int>? endIndex,
    Expression<int>? startTime,
    Expression<int>? durationMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rideId != null) 'ride_id': rideId,
      if (startIndex != null) 'start_index': startIndex,
      if (endIndex != null) 'end_index': endIndex,
      if (startTime != null) 'start_time': startTime,
      if (durationMs != null) 'duration_ms': durationMs,
    });
  }

  LapsCompanion copyWith({
    Value<int>? id,
    Value<String>? rideId,
    Value<int>? startIndex,
    Value<int>? endIndex,
    Value<int>? startTime,
    Value<int>? durationMs,
  }) {
    return LapsCompanion(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      startIndex: startIndex ?? this.startIndex,
      endIndex: endIndex ?? this.endIndex,
      startTime: startTime ?? this.startTime,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rideId.present) {
      map['ride_id'] = Variable<String>(rideId.value);
    }
    if (startIndex.present) {
      map['start_index'] = Variable<int>(startIndex.value);
    }
    if (endIndex.present) {
      map['end_index'] = Variable<int>(endIndex.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<int>(startTime.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LapsCompanion(')
          ..write('id: $id, ')
          ..write('rideId: $rideId, ')
          ..write('startIndex: $startIndex, ')
          ..write('endIndex: $endIndex, ')
          ..write('startTime: $startTime, ')
          ..write('durationMs: $durationMs')
          ..write(')'))
        .toString();
  }
}

class Workouts extends Table with TableInfo<Workouts, WorkoutsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Workouts(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> stepsJson = GeneratedColumn<String>(
    'steps_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, description, stepsJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      stepsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}steps_json'],
      )!,
    );
  }

  @override
  Workouts createAlias(String alias) {
    return Workouts(attachedDatabase, alias);
  }
}

class WorkoutsData extends DataClass implements Insertable<WorkoutsData> {
  final String id;
  final String name;
  final String? description;
  final String stepsJson;
  const WorkoutsData({
    required this.id,
    required this.name,
    this.description,
    required this.stepsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['steps_json'] = Variable<String>(stepsJson);
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      stepsJson: Value(stepsJson),
    );
  }

  factory WorkoutsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutsData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      stepsJson: serializer.fromJson<String>(json['stepsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'stepsJson': serializer.toJson<String>(stepsJson),
    };
  }

  WorkoutsData copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? stepsJson,
  }) => WorkoutsData(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    stepsJson: stepsJson ?? this.stepsJson,
  );
  WorkoutsData copyWithCompanion(WorkoutsCompanion data) {
    return WorkoutsData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      stepsJson: data.stepsJson.present ? data.stepsJson.value : this.stepsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('stepsJson: $stepsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, stepsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutsData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.stepsJson == this.stepsJson);
}

class WorkoutsCompanion extends UpdateCompanion<WorkoutsData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> stepsJson;
  final Value<int> rowid;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.stepsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String stepsJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       stepsJson = Value(stepsJson);
  static Insertable<WorkoutsData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? stepsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (stepsJson != null) 'steps_json': stepsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? stepsJson,
    Value<int>? rowid,
  }) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      stepsJson: stepsJson ?? this.stepsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (stepsJson.present) {
      map['steps_json'] = Variable<String>(stepsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('stepsJson: $stepsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class WorkoutSteps extends Table
    with TableInfo<WorkoutSteps, WorkoutStepsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  WorkoutSteps(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workouts (id)',
    ),
  );
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<double> powerTargetPercent =
      GeneratedColumn<double>(
        'power_target_percent',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  late final GeneratedColumn<double> powerLowPercent = GeneratedColumn<double>(
    'power_low_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> powerHighPercent = GeneratedColumn<double>(
    'power_high_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<int> cadenceTarget = GeneratedColumn<int>(
    'cadence_target',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<int> repeatCount = GeneratedColumn<int>(
    'repeat_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutId,
    orderIndex,
    type,
    durationSeconds,
    powerTargetPercent,
    powerLowPercent,
    powerHighPercent,
    cadenceTarget,
    repeatCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_steps';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutStepsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutStepsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      powerTargetPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}power_target_percent'],
      )!,
      powerLowPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}power_low_percent'],
      ),
      powerHighPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}power_high_percent'],
      ),
      cadenceTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cadence_target'],
      ),
      repeatCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_count'],
      ),
    );
  }

  @override
  WorkoutSteps createAlias(String alias) {
    return WorkoutSteps(attachedDatabase, alias);
  }
}

class WorkoutStepsData extends DataClass
    implements Insertable<WorkoutStepsData> {
  final int id;
  final String workoutId;
  final int orderIndex;
  final String type;
  final int durationSeconds;
  final double powerTargetPercent;
  final double? powerLowPercent;
  final double? powerHighPercent;
  final int? cadenceTarget;
  final int? repeatCount;
  const WorkoutStepsData({
    required this.id,
    required this.workoutId,
    required this.orderIndex,
    required this.type,
    required this.durationSeconds,
    required this.powerTargetPercent,
    this.powerLowPercent,
    this.powerHighPercent,
    this.cadenceTarget,
    this.repeatCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workout_id'] = Variable<String>(workoutId);
    map['order_index'] = Variable<int>(orderIndex);
    map['type'] = Variable<String>(type);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['power_target_percent'] = Variable<double>(powerTargetPercent);
    if (!nullToAbsent || powerLowPercent != null) {
      map['power_low_percent'] = Variable<double>(powerLowPercent);
    }
    if (!nullToAbsent || powerHighPercent != null) {
      map['power_high_percent'] = Variable<double>(powerHighPercent);
    }
    if (!nullToAbsent || cadenceTarget != null) {
      map['cadence_target'] = Variable<int>(cadenceTarget);
    }
    if (!nullToAbsent || repeatCount != null) {
      map['repeat_count'] = Variable<int>(repeatCount);
    }
    return map;
  }

  WorkoutStepsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutStepsCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      orderIndex: Value(orderIndex),
      type: Value(type),
      durationSeconds: Value(durationSeconds),
      powerTargetPercent: Value(powerTargetPercent),
      powerLowPercent: powerLowPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(powerLowPercent),
      powerHighPercent: powerHighPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(powerHighPercent),
      cadenceTarget: cadenceTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(cadenceTarget),
      repeatCount: repeatCount == null && nullToAbsent
          ? const Value.absent()
          : Value(repeatCount),
    );
  }

  factory WorkoutStepsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutStepsData(
      id: serializer.fromJson<int>(json['id']),
      workoutId: serializer.fromJson<String>(json['workoutId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      type: serializer.fromJson<String>(json['type']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      powerTargetPercent: serializer.fromJson<double>(
        json['powerTargetPercent'],
      ),
      powerLowPercent: serializer.fromJson<double?>(json['powerLowPercent']),
      powerHighPercent: serializer.fromJson<double?>(json['powerHighPercent']),
      cadenceTarget: serializer.fromJson<int?>(json['cadenceTarget']),
      repeatCount: serializer.fromJson<int?>(json['repeatCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workoutId': serializer.toJson<String>(workoutId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'type': serializer.toJson<String>(type),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'powerTargetPercent': serializer.toJson<double>(powerTargetPercent),
      'powerLowPercent': serializer.toJson<double?>(powerLowPercent),
      'powerHighPercent': serializer.toJson<double?>(powerHighPercent),
      'cadenceTarget': serializer.toJson<int?>(cadenceTarget),
      'repeatCount': serializer.toJson<int?>(repeatCount),
    };
  }

  WorkoutStepsData copyWith({
    int? id,
    String? workoutId,
    int? orderIndex,
    String? type,
    int? durationSeconds,
    double? powerTargetPercent,
    Value<double?> powerLowPercent = const Value.absent(),
    Value<double?> powerHighPercent = const Value.absent(),
    Value<int?> cadenceTarget = const Value.absent(),
    Value<int?> repeatCount = const Value.absent(),
  }) => WorkoutStepsData(
    id: id ?? this.id,
    workoutId: workoutId ?? this.workoutId,
    orderIndex: orderIndex ?? this.orderIndex,
    type: type ?? this.type,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    powerTargetPercent: powerTargetPercent ?? this.powerTargetPercent,
    powerLowPercent: powerLowPercent.present
        ? powerLowPercent.value
        : this.powerLowPercent,
    powerHighPercent: powerHighPercent.present
        ? powerHighPercent.value
        : this.powerHighPercent,
    cadenceTarget: cadenceTarget.present
        ? cadenceTarget.value
        : this.cadenceTarget,
    repeatCount: repeatCount.present ? repeatCount.value : this.repeatCount,
  );
  WorkoutStepsData copyWithCompanion(WorkoutStepsCompanion data) {
    return WorkoutStepsData(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      type: data.type.present ? data.type.value : this.type,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      powerTargetPercent: data.powerTargetPercent.present
          ? data.powerTargetPercent.value
          : this.powerTargetPercent,
      powerLowPercent: data.powerLowPercent.present
          ? data.powerLowPercent.value
          : this.powerLowPercent,
      powerHighPercent: data.powerHighPercent.present
          ? data.powerHighPercent.value
          : this.powerHighPercent,
      cadenceTarget: data.cadenceTarget.present
          ? data.cadenceTarget.value
          : this.cadenceTarget,
      repeatCount: data.repeatCount.present
          ? data.repeatCount.value
          : this.repeatCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutStepsData(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('type: $type, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('powerTargetPercent: $powerTargetPercent, ')
          ..write('powerLowPercent: $powerLowPercent, ')
          ..write('powerHighPercent: $powerHighPercent, ')
          ..write('cadenceTarget: $cadenceTarget, ')
          ..write('repeatCount: $repeatCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutId,
    orderIndex,
    type,
    durationSeconds,
    powerTargetPercent,
    powerLowPercent,
    powerHighPercent,
    cadenceTarget,
    repeatCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutStepsData &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.orderIndex == this.orderIndex &&
          other.type == this.type &&
          other.durationSeconds == this.durationSeconds &&
          other.powerTargetPercent == this.powerTargetPercent &&
          other.powerLowPercent == this.powerLowPercent &&
          other.powerHighPercent == this.powerHighPercent &&
          other.cadenceTarget == this.cadenceTarget &&
          other.repeatCount == this.repeatCount);
}

class WorkoutStepsCompanion extends UpdateCompanion<WorkoutStepsData> {
  final Value<int> id;
  final Value<String> workoutId;
  final Value<int> orderIndex;
  final Value<String> type;
  final Value<int> durationSeconds;
  final Value<double> powerTargetPercent;
  final Value<double?> powerLowPercent;
  final Value<double?> powerHighPercent;
  final Value<int?> cadenceTarget;
  final Value<int?> repeatCount;
  const WorkoutStepsCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.type = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.powerTargetPercent = const Value.absent(),
    this.powerLowPercent = const Value.absent(),
    this.powerHighPercent = const Value.absent(),
    this.cadenceTarget = const Value.absent(),
    this.repeatCount = const Value.absent(),
  });
  WorkoutStepsCompanion.insert({
    this.id = const Value.absent(),
    required String workoutId,
    required int orderIndex,
    required String type,
    required int durationSeconds,
    required double powerTargetPercent,
    this.powerLowPercent = const Value.absent(),
    this.powerHighPercent = const Value.absent(),
    this.cadenceTarget = const Value.absent(),
    this.repeatCount = const Value.absent(),
  }) : workoutId = Value(workoutId),
       orderIndex = Value(orderIndex),
       type = Value(type),
       durationSeconds = Value(durationSeconds),
       powerTargetPercent = Value(powerTargetPercent);
  static Insertable<WorkoutStepsData> custom({
    Expression<int>? id,
    Expression<String>? workoutId,
    Expression<int>? orderIndex,
    Expression<String>? type,
    Expression<int>? durationSeconds,
    Expression<double>? powerTargetPercent,
    Expression<double>? powerLowPercent,
    Expression<double>? powerHighPercent,
    Expression<int>? cadenceTarget,
    Expression<int>? repeatCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (type != null) 'type': type,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (powerTargetPercent != null)
        'power_target_percent': powerTargetPercent,
      if (powerLowPercent != null) 'power_low_percent': powerLowPercent,
      if (powerHighPercent != null) 'power_high_percent': powerHighPercent,
      if (cadenceTarget != null) 'cadence_target': cadenceTarget,
      if (repeatCount != null) 'repeat_count': repeatCount,
    });
  }

  WorkoutStepsCompanion copyWith({
    Value<int>? id,
    Value<String>? workoutId,
    Value<int>? orderIndex,
    Value<String>? type,
    Value<int>? durationSeconds,
    Value<double>? powerTargetPercent,
    Value<double?>? powerLowPercent,
    Value<double?>? powerHighPercent,
    Value<int?>? cadenceTarget,
    Value<int?>? repeatCount,
  }) {
    return WorkoutStepsCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      orderIndex: orderIndex ?? this.orderIndex,
      type: type ?? this.type,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      powerTargetPercent: powerTargetPercent ?? this.powerTargetPercent,
      powerLowPercent: powerLowPercent ?? this.powerLowPercent,
      powerHighPercent: powerHighPercent ?? this.powerHighPercent,
      cadenceTarget: cadenceTarget ?? this.cadenceTarget,
      repeatCount: repeatCount ?? this.repeatCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (powerTargetPercent.present) {
      map['power_target_percent'] = Variable<double>(powerTargetPercent.value);
    }
    if (powerLowPercent.present) {
      map['power_low_percent'] = Variable<double>(powerLowPercent.value);
    }
    if (powerHighPercent.present) {
      map['power_high_percent'] = Variable<double>(powerHighPercent.value);
    }
    if (cadenceTarget.present) {
      map['cadence_target'] = Variable<int>(cadenceTarget.value);
    }
    if (repeatCount.present) {
      map['repeat_count'] = Variable<int>(repeatCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutStepsCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('type: $type, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('powerTargetPercent: $powerTargetPercent, ')
          ..write('powerLowPercent: $powerLowPercent, ')
          ..write('powerHighPercent: $powerHighPercent, ')
          ..write('cadenceTarget: $cadenceTarget, ')
          ..write('repeatCount: $repeatCount')
          ..write(')'))
        .toString();
  }
}

class UserProfiles extends Table
    with TableInfo<UserProfiles, UserProfilesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  UserProfiles(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<double> ftp = GeneratedColumn<double>(
    'ftp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> maxHr = GeneratedColumn<int>(
    'max_hr',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<int> restHr = GeneratedColumn<int>(
    'rest_hr',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    ftp,
    maxHr,
    restHr,
    weight,
    height,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfilesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfilesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      ftp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ftp'],
      )!,
      maxHr: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_hr'],
      ),
      restHr: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_hr'],
      ),
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      ),
    );
  }

  @override
  UserProfiles createAlias(String alias) {
    return UserProfiles(attachedDatabase, alias);
  }
}

class UserProfilesData extends DataClass
    implements Insertable<UserProfilesData> {
  final String id;
  final String name;
  final double ftp;
  final int? maxHr;
  final int? restHr;
  final double? weight;
  final double? height;
  const UserProfilesData({
    required this.id,
    required this.name,
    required this.ftp,
    this.maxHr,
    this.restHr,
    this.weight,
    this.height,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['ftp'] = Variable<double>(ftp);
    if (!nullToAbsent || maxHr != null) {
      map['max_hr'] = Variable<int>(maxHr);
    }
    if (!nullToAbsent || restHr != null) {
      map['rest_hr'] = Variable<int>(restHr);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<double>(height);
    }
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      name: Value(name),
      ftp: Value(ftp),
      maxHr: maxHr == null && nullToAbsent
          ? const Value.absent()
          : Value(maxHr),
      restHr: restHr == null && nullToAbsent
          ? const Value.absent()
          : Value(restHr),
      weight: weight == null && nullToAbsent
          ? const Value.absent()
          : Value(weight),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
    );
  }

  factory UserProfilesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfilesData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      ftp: serializer.fromJson<double>(json['ftp']),
      maxHr: serializer.fromJson<int?>(json['maxHr']),
      restHr: serializer.fromJson<int?>(json['restHr']),
      weight: serializer.fromJson<double?>(json['weight']),
      height: serializer.fromJson<double?>(json['height']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'ftp': serializer.toJson<double>(ftp),
      'maxHr': serializer.toJson<int?>(maxHr),
      'restHr': serializer.toJson<int?>(restHr),
      'weight': serializer.toJson<double?>(weight),
      'height': serializer.toJson<double?>(height),
    };
  }

  UserProfilesData copyWith({
    String? id,
    String? name,
    double? ftp,
    Value<int?> maxHr = const Value.absent(),
    Value<int?> restHr = const Value.absent(),
    Value<double?> weight = const Value.absent(),
    Value<double?> height = const Value.absent(),
  }) => UserProfilesData(
    id: id ?? this.id,
    name: name ?? this.name,
    ftp: ftp ?? this.ftp,
    maxHr: maxHr.present ? maxHr.value : this.maxHr,
    restHr: restHr.present ? restHr.value : this.restHr,
    weight: weight.present ? weight.value : this.weight,
    height: height.present ? height.value : this.height,
  );
  UserProfilesData copyWithCompanion(UserProfilesCompanion data) {
    return UserProfilesData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      ftp: data.ftp.present ? data.ftp.value : this.ftp,
      maxHr: data.maxHr.present ? data.maxHr.value : this.maxHr,
      restHr: data.restHr.present ? data.restHr.value : this.restHr,
      weight: data.weight.present ? data.weight.value : this.weight,
      height: data.height.present ? data.height.value : this.height,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('ftp: $ftp, ')
          ..write('maxHr: $maxHr, ')
          ..write('restHr: $restHr, ')
          ..write('weight: $weight, ')
          ..write('height: $height')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, ftp, maxHr, restHr, weight, height);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfilesData &&
          other.id == this.id &&
          other.name == this.name &&
          other.ftp == this.ftp &&
          other.maxHr == this.maxHr &&
          other.restHr == this.restHr &&
          other.weight == this.weight &&
          other.height == this.height);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfilesData> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> ftp;
  final Value<int?> maxHr;
  final Value<int?> restHr;
  final Value<double?> weight;
  final Value<double?> height;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.ftp = const Value.absent(),
    this.maxHr = const Value.absent(),
    this.restHr = const Value.absent(),
    this.weight = const Value.absent(),
    this.height = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String name,
    required double ftp,
    this.maxHr = const Value.absent(),
    this.restHr = const Value.absent(),
    this.weight = const Value.absent(),
    this.height = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       ftp = Value(ftp);
  static Insertable<UserProfilesData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? ftp,
    Expression<int>? maxHr,
    Expression<int>? restHr,
    Expression<double>? weight,
    Expression<double>? height,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (ftp != null) 'ftp': ftp,
      if (maxHr != null) 'max_hr': maxHr,
      if (restHr != null) 'rest_hr': restHr,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? ftp,
    Value<int?>? maxHr,
    Value<int?>? restHr,
    Value<double?>? weight,
    Value<double?>? height,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      ftp: ftp ?? this.ftp,
      maxHr: maxHr ?? this.maxHr,
      restHr: restHr ?? this.restHr,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (ftp.present) {
      map['ftp'] = Variable<double>(ftp.value);
    }
    if (maxHr.present) {
      map['max_hr'] = Variable<int>(maxHr.value);
    }
    if (restHr.present) {
      map['rest_hr'] = Variable<int>(restHr.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('ftp: $ftp, ')
          ..write('maxHr: $maxHr, ')
          ..write('restHr: $restHr, ')
          ..write('weight: $weight, ')
          ..write('height: $height, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ExportQueue extends Table with TableInfo<ExportQueue, ExportQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ExportQueue(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  late final GeneratedColumn<String> rideId = GeneratedColumn<String>(
    'ride_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rides (id)',
    ),
  );
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('\'pending\''),
  );
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> lastAttempt = GeneratedColumn<int>(
    'last_attempt',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> resultPath = GeneratedColumn<String>(
    'result_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rideId,
    target,
    status,
    retryCount,
    lastAttempt,
    errorMessage,
    createdAt,
    resultPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'export_queue';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExportQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rideId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ride_id'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastAttempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_attempt'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      resultPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_path'],
      ),
    );
  }

  @override
  ExportQueue createAlias(String alias) {
    return ExportQueue(attachedDatabase, alias);
  }
}

class ExportQueueData extends DataClass implements Insertable<ExportQueueData> {
  final int id;
  final String rideId;
  final String target;
  final String status;
  final int retryCount;
  final int? lastAttempt;
  final String? errorMessage;
  final int createdAt;
  final String? resultPath;
  const ExportQueueData({
    required this.id,
    required this.rideId,
    required this.target,
    required this.status,
    required this.retryCount,
    this.lastAttempt,
    this.errorMessage,
    required this.createdAt,
    this.resultPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ride_id'] = Variable<String>(rideId);
    map['target'] = Variable<String>(target);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastAttempt != null) {
      map['last_attempt'] = Variable<int>(lastAttempt);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || resultPath != null) {
      map['result_path'] = Variable<String>(resultPath);
    }
    return map;
  }

  ExportQueueCompanion toCompanion(bool nullToAbsent) {
    return ExportQueueCompanion(
      id: Value(id),
      rideId: Value(rideId),
      target: Value(target),
      status: Value(status),
      retryCount: Value(retryCount),
      lastAttempt: lastAttempt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttempt),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      resultPath: resultPath == null && nullToAbsent
          ? const Value.absent()
          : Value(resultPath),
    );
  }

  factory ExportQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportQueueData(
      id: serializer.fromJson<int>(json['id']),
      rideId: serializer.fromJson<String>(json['rideId']),
      target: serializer.fromJson<String>(json['target']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastAttempt: serializer.fromJson<int?>(json['lastAttempt']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      resultPath: serializer.fromJson<String?>(json['resultPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rideId': serializer.toJson<String>(rideId),
      'target': serializer.toJson<String>(target),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastAttempt': serializer.toJson<int?>(lastAttempt),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<int>(createdAt),
      'resultPath': serializer.toJson<String?>(resultPath),
    };
  }

  ExportQueueData copyWith({
    int? id,
    String? rideId,
    String? target,
    String? status,
    int? retryCount,
    Value<int?> lastAttempt = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    int? createdAt,
    Value<String?> resultPath = const Value.absent(),
  }) => ExportQueueData(
    id: id ?? this.id,
    rideId: rideId ?? this.rideId,
    target: target ?? this.target,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    lastAttempt: lastAttempt.present ? lastAttempt.value : this.lastAttempt,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    createdAt: createdAt ?? this.createdAt,
    resultPath: resultPath.present ? resultPath.value : this.resultPath,
  );
  ExportQueueData copyWithCompanion(ExportQueueCompanion data) {
    return ExportQueueData(
      id: data.id.present ? data.id.value : this.id,
      rideId: data.rideId.present ? data.rideId.value : this.rideId,
      target: data.target.present ? data.target.value : this.target,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastAttempt: data.lastAttempt.present
          ? data.lastAttempt.value
          : this.lastAttempt,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      resultPath: data.resultPath.present
          ? data.resultPath.value
          : this.resultPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExportQueueData(')
          ..write('id: $id, ')
          ..write('rideId: $rideId, ')
          ..write('target: $target, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttempt: $lastAttempt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('resultPath: $resultPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rideId,
    target,
    status,
    retryCount,
    lastAttempt,
    errorMessage,
    createdAt,
    resultPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExportQueueData &&
          other.id == this.id &&
          other.rideId == this.rideId &&
          other.target == this.target &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastAttempt == this.lastAttempt &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.resultPath == this.resultPath);
}

class ExportQueueCompanion extends UpdateCompanion<ExportQueueData> {
  final Value<int> id;
  final Value<String> rideId;
  final Value<String> target;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<int?> lastAttempt;
  final Value<String?> errorMessage;
  final Value<int> createdAt;
  final Value<String?> resultPath;
  const ExportQueueCompanion({
    this.id = const Value.absent(),
    this.rideId = const Value.absent(),
    this.target = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastAttempt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resultPath = const Value.absent(),
  });
  ExportQueueCompanion.insert({
    this.id = const Value.absent(),
    required String rideId,
    required String target,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastAttempt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    required int createdAt,
    this.resultPath = const Value.absent(),
  }) : rideId = Value(rideId),
       target = Value(target),
       createdAt = Value(createdAt);
  static Insertable<ExportQueueData> custom({
    Expression<int>? id,
    Expression<String>? rideId,
    Expression<String>? target,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<int>? lastAttempt,
    Expression<String>? errorMessage,
    Expression<int>? createdAt,
    Expression<String>? resultPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rideId != null) 'ride_id': rideId,
      if (target != null) 'target': target,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastAttempt != null) 'last_attempt': lastAttempt,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (resultPath != null) 'result_path': resultPath,
    });
  }

  ExportQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? rideId,
    Value<String>? target,
    Value<String>? status,
    Value<int>? retryCount,
    Value<int?>? lastAttempt,
    Value<String?>? errorMessage,
    Value<int>? createdAt,
    Value<String?>? resultPath,
  }) {
    return ExportQueueCompanion(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      target: target ?? this.target,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      resultPath: resultPath ?? this.resultPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rideId.present) {
      map['ride_id'] = Variable<String>(rideId.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastAttempt.present) {
      map['last_attempt'] = Variable<int>(lastAttempt.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (resultPath.present) {
      map['result_path'] = Variable<String>(resultPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportQueueCompanion(')
          ..write('id: $id, ')
          ..write('rideId: $rideId, ')
          ..write('target: $target, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttempt: $lastAttempt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('resultPath: $resultPath')
          ..write(')'))
        .toString();
  }
}

class ScheduledWorkouts extends Table
    with TableInfo<ScheduledWorkouts, ScheduledWorkoutsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ScheduledWorkouts(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workouts (id)',
    ),
  );
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> completedRideId = GeneratedColumn<String>(
    'completed_ride_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rides (id)',
    ),
  );
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutId,
    date,
    completedRideId,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scheduled_workouts';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduledWorkoutsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduledWorkoutsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date'],
      )!,
      completedRideId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_ride_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  ScheduledWorkouts createAlias(String alias) {
    return ScheduledWorkouts(attachedDatabase, alias);
  }
}

class ScheduledWorkoutsData extends DataClass
    implements Insertable<ScheduledWorkoutsData> {
  final String id;
  final String workoutId;
  final int date;
  final String? completedRideId;
  final String? notes;
  final int createdAt;
  const ScheduledWorkoutsData({
    required this.id,
    required this.workoutId,
    required this.date,
    this.completedRideId,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_id'] = Variable<String>(workoutId);
    map['date'] = Variable<int>(date);
    if (!nullToAbsent || completedRideId != null) {
      map['completed_ride_id'] = Variable<String>(completedRideId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ScheduledWorkoutsCompanion toCompanion(bool nullToAbsent) {
    return ScheduledWorkoutsCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      date: Value(date),
      completedRideId: completedRideId == null && nullToAbsent
          ? const Value.absent()
          : Value(completedRideId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory ScheduledWorkoutsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduledWorkoutsData(
      id: serializer.fromJson<String>(json['id']),
      workoutId: serializer.fromJson<String>(json['workoutId']),
      date: serializer.fromJson<int>(json['date']),
      completedRideId: serializer.fromJson<String?>(json['completedRideId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutId': serializer.toJson<String>(workoutId),
      'date': serializer.toJson<int>(date),
      'completedRideId': serializer.toJson<String?>(completedRideId),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ScheduledWorkoutsData copyWith({
    String? id,
    String? workoutId,
    int? date,
    Value<String?> completedRideId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? createdAt,
  }) => ScheduledWorkoutsData(
    id: id ?? this.id,
    workoutId: workoutId ?? this.workoutId,
    date: date ?? this.date,
    completedRideId: completedRideId.present
        ? completedRideId.value
        : this.completedRideId,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  ScheduledWorkoutsData copyWithCompanion(ScheduledWorkoutsCompanion data) {
    return ScheduledWorkoutsData(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      date: data.date.present ? data.date.value : this.date,
      completedRideId: data.completedRideId.present
          ? data.completedRideId.value
          : this.completedRideId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledWorkoutsData(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('date: $date, ')
          ..write('completedRideId: $completedRideId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, workoutId, date, completedRideId, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduledWorkoutsData &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.date == this.date &&
          other.completedRideId == this.completedRideId &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class ScheduledWorkoutsCompanion
    extends UpdateCompanion<ScheduledWorkoutsData> {
  final Value<String> id;
  final Value<String> workoutId;
  final Value<int> date;
  final Value<String?> completedRideId;
  final Value<String?> notes;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ScheduledWorkoutsCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.date = const Value.absent(),
    this.completedRideId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduledWorkoutsCompanion.insert({
    required String id,
    required String workoutId,
    required int date,
    this.completedRideId = const Value.absent(),
    this.notes = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workoutId = Value(workoutId),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<ScheduledWorkoutsData> custom({
    Expression<String>? id,
    Expression<String>? workoutId,
    Expression<int>? date,
    Expression<String>? completedRideId,
    Expression<String>? notes,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (date != null) 'date': date,
      if (completedRideId != null) 'completed_ride_id': completedRideId,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduledWorkoutsCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutId,
    Value<int>? date,
    Value<String?>? completedRideId,
    Value<String?>? notes,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ScheduledWorkoutsCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      date: date ?? this.date,
      completedRideId: completedRideId ?? this.completedRideId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (completedRideId.present) {
      map['completed_ride_id'] = Variable<String>(completedRideId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledWorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('date: $date, ')
          ..write('completedRideId: $completedRideId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PersonalRecords extends Table
    with TableInfo<PersonalRecords, PersonalRecordsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PersonalRecords(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  late final GeneratedColumn<String> rideId = GeneratedColumn<String>(
    'ride_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rides (id)',
    ),
  );
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<double> watts = GeneratedColumn<double>(
    'watts',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> achievedAt = GeneratedColumn<int>(
    'achieved_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rideId,
    durationSeconds,
    watts,
    achievedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_records';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {rideId, durationSeconds},
  ];
  @override
  PersonalRecordsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalRecordsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rideId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ride_id'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      watts: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}watts'],
      )!,
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}achieved_at'],
      )!,
    );
  }

  @override
  PersonalRecords createAlias(String alias) {
    return PersonalRecords(attachedDatabase, alias);
  }
}

class PersonalRecordsData extends DataClass
    implements Insertable<PersonalRecordsData> {
  final int id;
  final String rideId;
  final int durationSeconds;
  final double watts;
  final int achievedAt;
  const PersonalRecordsData({
    required this.id,
    required this.rideId,
    required this.durationSeconds,
    required this.watts,
    required this.achievedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ride_id'] = Variable<String>(rideId);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['watts'] = Variable<double>(watts);
    map['achieved_at'] = Variable<int>(achievedAt);
    return map;
  }

  PersonalRecordsCompanion toCompanion(bool nullToAbsent) {
    return PersonalRecordsCompanion(
      id: Value(id),
      rideId: Value(rideId),
      durationSeconds: Value(durationSeconds),
      watts: Value(watts),
      achievedAt: Value(achievedAt),
    );
  }

  factory PersonalRecordsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalRecordsData(
      id: serializer.fromJson<int>(json['id']),
      rideId: serializer.fromJson<String>(json['rideId']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      watts: serializer.fromJson<double>(json['watts']),
      achievedAt: serializer.fromJson<int>(json['achievedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rideId': serializer.toJson<String>(rideId),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'watts': serializer.toJson<double>(watts),
      'achievedAt': serializer.toJson<int>(achievedAt),
    };
  }

  PersonalRecordsData copyWith({
    int? id,
    String? rideId,
    int? durationSeconds,
    double? watts,
    int? achievedAt,
  }) => PersonalRecordsData(
    id: id ?? this.id,
    rideId: rideId ?? this.rideId,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    watts: watts ?? this.watts,
    achievedAt: achievedAt ?? this.achievedAt,
  );
  PersonalRecordsData copyWithCompanion(PersonalRecordsCompanion data) {
    return PersonalRecordsData(
      id: data.id.present ? data.id.value : this.id,
      rideId: data.rideId.present ? data.rideId.value : this.rideId,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      watts: data.watts.present ? data.watts.value : this.watts,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecordsData(')
          ..write('id: $id, ')
          ..write('rideId: $rideId, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('watts: $watts, ')
          ..write('achievedAt: $achievedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, rideId, durationSeconds, watts, achievedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalRecordsData &&
          other.id == this.id &&
          other.rideId == this.rideId &&
          other.durationSeconds == this.durationSeconds &&
          other.watts == this.watts &&
          other.achievedAt == this.achievedAt);
}

class PersonalRecordsCompanion extends UpdateCompanion<PersonalRecordsData> {
  final Value<int> id;
  final Value<String> rideId;
  final Value<int> durationSeconds;
  final Value<double> watts;
  final Value<int> achievedAt;
  const PersonalRecordsCompanion({
    this.id = const Value.absent(),
    this.rideId = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.watts = const Value.absent(),
    this.achievedAt = const Value.absent(),
  });
  PersonalRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String rideId,
    required int durationSeconds,
    required double watts,
    required int achievedAt,
  }) : rideId = Value(rideId),
       durationSeconds = Value(durationSeconds),
       watts = Value(watts),
       achievedAt = Value(achievedAt);
  static Insertable<PersonalRecordsData> custom({
    Expression<int>? id,
    Expression<String>? rideId,
    Expression<int>? durationSeconds,
    Expression<double>? watts,
    Expression<int>? achievedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rideId != null) 'ride_id': rideId,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (watts != null) 'watts': watts,
      if (achievedAt != null) 'achieved_at': achievedAt,
    });
  }

  PersonalRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? rideId,
    Value<int>? durationSeconds,
    Value<double>? watts,
    Value<int>? achievedAt,
  }) {
    return PersonalRecordsCompanion(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      watts: watts ?? this.watts,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rideId.present) {
      map['ride_id'] = Variable<String>(rideId.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (watts.present) {
      map['watts'] = Variable<double>(watts.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<int>(achievedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('rideId: $rideId, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('watts: $watts, ')
          ..write('achievedAt: $achievedAt')
          ..write(')'))
        .toString();
  }
}

class FtpHistory extends Table with TableInfo<FtpHistory, FtpHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  FtpHistory(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  late final GeneratedColumn<int> effectiveDate = GeneratedColumn<int>(
    'effective_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<double> ftp = GeneratedColumn<double>(
    'ftp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, effectiveDate, ftp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ftp_history';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FtpHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FtpHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      effectiveDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effective_date'],
      )!,
      ftp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ftp'],
      )!,
    );
  }

  @override
  FtpHistory createAlias(String alias) {
    return FtpHistory(attachedDatabase, alias);
  }
}

class FtpHistoryData extends DataClass implements Insertable<FtpHistoryData> {
  final int id;
  final int effectiveDate;
  final double ftp;
  const FtpHistoryData({
    required this.id,
    required this.effectiveDate,
    required this.ftp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['effective_date'] = Variable<int>(effectiveDate);
    map['ftp'] = Variable<double>(ftp);
    return map;
  }

  FtpHistoryCompanion toCompanion(bool nullToAbsent) {
    return FtpHistoryCompanion(
      id: Value(id),
      effectiveDate: Value(effectiveDate),
      ftp: Value(ftp),
    );
  }

  factory FtpHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FtpHistoryData(
      id: serializer.fromJson<int>(json['id']),
      effectiveDate: serializer.fromJson<int>(json['effectiveDate']),
      ftp: serializer.fromJson<double>(json['ftp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'effectiveDate': serializer.toJson<int>(effectiveDate),
      'ftp': serializer.toJson<double>(ftp),
    };
  }

  FtpHistoryData copyWith({int? id, int? effectiveDate, double? ftp}) =>
      FtpHistoryData(
        id: id ?? this.id,
        effectiveDate: effectiveDate ?? this.effectiveDate,
        ftp: ftp ?? this.ftp,
      );
  FtpHistoryData copyWithCompanion(FtpHistoryCompanion data) {
    return FtpHistoryData(
      id: data.id.present ? data.id.value : this.id,
      effectiveDate: data.effectiveDate.present
          ? data.effectiveDate.value
          : this.effectiveDate,
      ftp: data.ftp.present ? data.ftp.value : this.ftp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FtpHistoryData(')
          ..write('id: $id, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('ftp: $ftp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, effectiveDate, ftp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FtpHistoryData &&
          other.id == this.id &&
          other.effectiveDate == this.effectiveDate &&
          other.ftp == this.ftp);
}

class FtpHistoryCompanion extends UpdateCompanion<FtpHistoryData> {
  final Value<int> id;
  final Value<int> effectiveDate;
  final Value<double> ftp;
  const FtpHistoryCompanion({
    this.id = const Value.absent(),
    this.effectiveDate = const Value.absent(),
    this.ftp = const Value.absent(),
  });
  FtpHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int effectiveDate,
    required double ftp,
  }) : effectiveDate = Value(effectiveDate),
       ftp = Value(ftp);
  static Insertable<FtpHistoryData> custom({
    Expression<int>? id,
    Expression<int>? effectiveDate,
    Expression<double>? ftp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (effectiveDate != null) 'effective_date': effectiveDate,
      if (ftp != null) 'ftp': ftp,
    });
  }

  FtpHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? effectiveDate,
    Value<double>? ftp,
  }) {
    return FtpHistoryCompanion(
      id: id ?? this.id,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      ftp: ftp ?? this.ftp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (effectiveDate.present) {
      map['effective_date'] = Variable<int>(effectiveDate.value);
    }
    if (ftp.present) {
      map['ftp'] = Variable<double>(ftp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FtpHistoryCompanion(')
          ..write('id: $id, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('ftp: $ftp')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV5 extends GeneratedDatabase {
  DatabaseAtV5(QueryExecutor e) : super(e);
  late final Rides rides = Rides(this);
  late final SensorReadings sensorReadings = SensorReadings(this);
  late final Laps laps = Laps(this);
  late final Workouts workouts = Workouts(this);
  late final WorkoutSteps workoutSteps = WorkoutSteps(this);
  late final UserProfiles userProfiles = UserProfiles(this);
  late final ExportQueue exportQueue = ExportQueue(this);
  late final ScheduledWorkouts scheduledWorkouts = ScheduledWorkouts(this);
  late final PersonalRecords personalRecords = PersonalRecords(this);
  late final FtpHistory ftpHistory = FtpHistory(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    rides,
    sensorReadings,
    laps,
    workouts,
    workoutSteps,
    userProfiles,
    exportQueue,
    scheduledWorkouts,
    personalRecords,
    ftpHistory,
  ];
  @override
  int get schemaVersion => 5;
}
