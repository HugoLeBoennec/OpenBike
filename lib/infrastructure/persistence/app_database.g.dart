// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RidesTable extends Rides with TableInfo<$RidesTable, RideRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RidesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<int> startTime = GeneratedColumn<int>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<int> endTime = GeneratedColumn<int>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workout_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgPowerMeta = const VerificationMeta(
    'avgPower',
  );
  @override
  late final GeneratedColumn<double> avgPower = GeneratedColumn<double>(
    'avg_power',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _normalizedPowerMeta = const VerificationMeta(
    'normalizedPower',
  );
  @override
  late final GeneratedColumn<double> normalizedPower = GeneratedColumn<double>(
    'normalized_power',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxPowerMeta = const VerificationMeta(
    'maxPower',
  );
  @override
  late final GeneratedColumn<double> maxPower = GeneratedColumn<double>(
    'max_power',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgCadenceMeta = const VerificationMeta(
    'avgCadence',
  );
  @override
  late final GeneratedColumn<double> avgCadence = GeneratedColumn<double>(
    'avg_cadence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgHrMeta = const VerificationMeta('avgHr');
  @override
  late final GeneratedColumn<double> avgHr = GeneratedColumn<double>(
    'avg_hr',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxHrMeta = const VerificationMeta('maxHr');
  @override
  late final GeneratedColumn<double> maxHr = GeneratedColumn<double>(
    'max_hr',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalDistanceMeta = const VerificationMeta(
    'totalDistance',
  );
  @override
  late final GeneratedColumn<double> totalDistance = GeneratedColumn<double>(
    'total_distance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pauseDurationSecondsMeta =
      const VerificationMeta('pauseDurationSeconds');
  @override
  late final GeneratedColumn<int> pauseDurationSeconds = GeneratedColumn<int>(
    'pause_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tssMeta = const VerificationMeta('tss');
  @override
  late final GeneratedColumn<double> tss = GeneratedColumn<double>(
    'tss',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intensityFactorMeta = const VerificationMeta(
    'intensityFactor',
  );
  @override
  late final GeneratedColumn<double> intensityFactor = GeneratedColumn<double>(
    'intensity_factor',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ftpAtTimeMeta = const VerificationMeta(
    'ftpAtTime',
  );
  @override
  late final GeneratedColumn<double> ftpAtTime = GeneratedColumn<double>(
    'ftp_at_time',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elevationGainMMeta = const VerificationMeta(
    'elevationGainM',
  );
  @override
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
  VerificationContext validateIntegrity(
    Insertable<RideRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('avg_power')) {
      context.handle(
        _avgPowerMeta,
        avgPower.isAcceptableOrUnknown(data['avg_power']!, _avgPowerMeta),
      );
    }
    if (data.containsKey('normalized_power')) {
      context.handle(
        _normalizedPowerMeta,
        normalizedPower.isAcceptableOrUnknown(
          data['normalized_power']!,
          _normalizedPowerMeta,
        ),
      );
    }
    if (data.containsKey('max_power')) {
      context.handle(
        _maxPowerMeta,
        maxPower.isAcceptableOrUnknown(data['max_power']!, _maxPowerMeta),
      );
    }
    if (data.containsKey('avg_cadence')) {
      context.handle(
        _avgCadenceMeta,
        avgCadence.isAcceptableOrUnknown(data['avg_cadence']!, _avgCadenceMeta),
      );
    }
    if (data.containsKey('avg_hr')) {
      context.handle(
        _avgHrMeta,
        avgHr.isAcceptableOrUnknown(data['avg_hr']!, _avgHrMeta),
      );
    }
    if (data.containsKey('max_hr')) {
      context.handle(
        _maxHrMeta,
        maxHr.isAcceptableOrUnknown(data['max_hr']!, _maxHrMeta),
      );
    }
    if (data.containsKey('total_distance')) {
      context.handle(
        _totalDistanceMeta,
        totalDistance.isAcceptableOrUnknown(
          data['total_distance']!,
          _totalDistanceMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('pause_duration_seconds')) {
      context.handle(
        _pauseDurationSecondsMeta,
        pauseDurationSeconds.isAcceptableOrUnknown(
          data['pause_duration_seconds']!,
          _pauseDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('tss')) {
      context.handle(
        _tssMeta,
        tss.isAcceptableOrUnknown(data['tss']!, _tssMeta),
      );
    }
    if (data.containsKey('intensity_factor')) {
      context.handle(
        _intensityFactorMeta,
        intensityFactor.isAcceptableOrUnknown(
          data['intensity_factor']!,
          _intensityFactorMeta,
        ),
      );
    }
    if (data.containsKey('ftp_at_time')) {
      context.handle(
        _ftpAtTimeMeta,
        ftpAtTime.isAcceptableOrUnknown(data['ftp_at_time']!, _ftpAtTimeMeta),
      );
    }
    if (data.containsKey('elevation_gain_m')) {
      context.handle(
        _elevationGainMMeta,
        elevationGainM.isAcceptableOrUnknown(
          data['elevation_gain_m']!,
          _elevationGainMMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RideRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RideRow(
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
  $RidesTable createAlias(String alias) {
    return $RidesTable(attachedDatabase, alias);
  }
}

class RideRow extends DataClass implements Insertable<RideRow> {
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
  const RideRow({
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

  factory RideRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RideRow(
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

  RideRow copyWith({
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
  }) => RideRow(
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
  RideRow copyWithCompanion(RidesCompanion data) {
    return RideRow(
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
    return (StringBuffer('RideRow(')
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
      (other is RideRow &&
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

class RidesCompanion extends UpdateCompanion<RideRow> {
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
  static Insertable<RideRow> custom({
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

class $SensorReadingsTable extends SensorReadings
    with TableInfo<$SensorReadingsTable, SensorReadingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SensorReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
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
  static const VerificationMeta _rideIdMeta = const VerificationMeta('rideId');
  @override
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
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _powerWattsMeta = const VerificationMeta(
    'powerWatts',
  );
  @override
  late final GeneratedColumn<double> powerWatts = GeneratedColumn<double>(
    'power_watts',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cadenceRpmMeta = const VerificationMeta(
    'cadenceRpm',
  );
  @override
  late final GeneratedColumn<double> cadenceRpm = GeneratedColumn<double>(
    'cadence_rpm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heartRateBpmMeta = const VerificationMeta(
    'heartRateBpm',
  );
  @override
  late final GeneratedColumn<int> heartRateBpm = GeneratedColumn<int>(
    'heart_rate_bpm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedKmhMeta = const VerificationMeta(
    'speedKmh',
  );
  @override
  late final GeneratedColumn<double> speedKmh = GeneratedColumn<double>(
    'speed_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
    'distance_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradePercentMeta = const VerificationMeta(
    'gradePercent',
  );
  @override
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
  VerificationContext validateIntegrity(
    Insertable<SensorReadingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ride_id')) {
      context.handle(
        _rideIdMeta,
        rideId.isAcceptableOrUnknown(data['ride_id']!, _rideIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rideIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('power_watts')) {
      context.handle(
        _powerWattsMeta,
        powerWatts.isAcceptableOrUnknown(data['power_watts']!, _powerWattsMeta),
      );
    }
    if (data.containsKey('cadence_rpm')) {
      context.handle(
        _cadenceRpmMeta,
        cadenceRpm.isAcceptableOrUnknown(data['cadence_rpm']!, _cadenceRpmMeta),
      );
    }
    if (data.containsKey('heart_rate_bpm')) {
      context.handle(
        _heartRateBpmMeta,
        heartRateBpm.isAcceptableOrUnknown(
          data['heart_rate_bpm']!,
          _heartRateBpmMeta,
        ),
      );
    }
    if (data.containsKey('speed_kmh')) {
      context.handle(
        _speedKmhMeta,
        speedKmh.isAcceptableOrUnknown(data['speed_kmh']!, _speedKmhMeta),
      );
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    }
    if (data.containsKey('grade_percent')) {
      context.handle(
        _gradePercentMeta,
        gradePercent.isAcceptableOrUnknown(
          data['grade_percent']!,
          _gradePercentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorReadingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorReadingRow(
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
  $SensorReadingsTable createAlias(String alias) {
    return $SensorReadingsTable(attachedDatabase, alias);
  }
}

class SensorReadingRow extends DataClass
    implements Insertable<SensorReadingRow> {
  final int id;
  final String rideId;
  final int timestamp;
  final double? powerWatts;
  final double? cadenceRpm;
  final int? heartRateBpm;
  final double? speedKmh;
  final double? distanceM;
  final double? gradePercent;
  const SensorReadingRow({
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

  factory SensorReadingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorReadingRow(
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

  SensorReadingRow copyWith({
    int? id,
    String? rideId,
    int? timestamp,
    Value<double?> powerWatts = const Value.absent(),
    Value<double?> cadenceRpm = const Value.absent(),
    Value<int?> heartRateBpm = const Value.absent(),
    Value<double?> speedKmh = const Value.absent(),
    Value<double?> distanceM = const Value.absent(),
    Value<double?> gradePercent = const Value.absent(),
  }) => SensorReadingRow(
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
  SensorReadingRow copyWithCompanion(SensorReadingsCompanion data) {
    return SensorReadingRow(
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
    return (StringBuffer('SensorReadingRow(')
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
      (other is SensorReadingRow &&
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

class SensorReadingsCompanion extends UpdateCompanion<SensorReadingRow> {
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
  static Insertable<SensorReadingRow> custom({
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

class $LapsTable extends Laps with TableInfo<$LapsTable, LapRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LapsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
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
  static const VerificationMeta _rideIdMeta = const VerificationMeta('rideId');
  @override
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
  static const VerificationMeta _startIndexMeta = const VerificationMeta(
    'startIndex',
  );
  @override
  late final GeneratedColumn<int> startIndex = GeneratedColumn<int>(
    'start_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endIndexMeta = const VerificationMeta(
    'endIndex',
  );
  @override
  late final GeneratedColumn<int> endIndex = GeneratedColumn<int>(
    'end_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<int> startTime = GeneratedColumn<int>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
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
  VerificationContext validateIntegrity(
    Insertable<LapRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ride_id')) {
      context.handle(
        _rideIdMeta,
        rideId.isAcceptableOrUnknown(data['ride_id']!, _rideIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rideIdMeta);
    }
    if (data.containsKey('start_index')) {
      context.handle(
        _startIndexMeta,
        startIndex.isAcceptableOrUnknown(data['start_index']!, _startIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_startIndexMeta);
    }
    if (data.containsKey('end_index')) {
      context.handle(
        _endIndexMeta,
        endIndex.isAcceptableOrUnknown(data['end_index']!, _endIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_endIndexMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LapRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LapRow(
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
  $LapsTable createAlias(String alias) {
    return $LapsTable(attachedDatabase, alias);
  }
}

class LapRow extends DataClass implements Insertable<LapRow> {
  final int id;
  final String rideId;
  final int startIndex;
  final int endIndex;
  final int startTime;
  final int durationMs;
  const LapRow({
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

  factory LapRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LapRow(
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

  LapRow copyWith({
    int? id,
    String? rideId,
    int? startIndex,
    int? endIndex,
    int? startTime,
    int? durationMs,
  }) => LapRow(
    id: id ?? this.id,
    rideId: rideId ?? this.rideId,
    startIndex: startIndex ?? this.startIndex,
    endIndex: endIndex ?? this.endIndex,
    startTime: startTime ?? this.startTime,
    durationMs: durationMs ?? this.durationMs,
  );
  LapRow copyWithCompanion(LapsCompanion data) {
    return LapRow(
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
    return (StringBuffer('LapRow(')
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
      (other is LapRow &&
          other.id == this.id &&
          other.rideId == this.rideId &&
          other.startIndex == this.startIndex &&
          other.endIndex == this.endIndex &&
          other.startTime == this.startTime &&
          other.durationMs == this.durationMs);
}

class LapsCompanion extends UpdateCompanion<LapRow> {
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
  static Insertable<LapRow> custom({
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

class $WorkoutsTable extends Workouts
    with TableInfo<$WorkoutsTable, WorkoutRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepsJsonMeta = const VerificationMeta(
    'stepsJson',
  );
  @override
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
  VerificationContext validateIntegrity(
    Insertable<WorkoutRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('steps_json')) {
      context.handle(
        _stepsJsonMeta,
        stepsJson.isAcceptableOrUnknown(data['steps_json']!, _stepsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_stepsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutRow(
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
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class WorkoutRow extends DataClass implements Insertable<WorkoutRow> {
  final String id;
  final String name;
  final String? description;
  final String stepsJson;
  const WorkoutRow({
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

  factory WorkoutRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutRow(
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

  WorkoutRow copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? stepsJson,
  }) => WorkoutRow(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    stepsJson: stepsJson ?? this.stepsJson,
  );
  WorkoutRow copyWithCompanion(WorkoutsCompanion data) {
    return WorkoutRow(
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
    return (StringBuffer('WorkoutRow(')
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
      (other is WorkoutRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.stepsJson == this.stepsJson);
}

class WorkoutsCompanion extends UpdateCompanion<WorkoutRow> {
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
  static Insertable<WorkoutRow> custom({
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

class $WorkoutStepsTable extends WorkoutSteps
    with TableInfo<$WorkoutStepsTable, WorkoutStepRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
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
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
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
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _powerTargetPercentMeta =
      const VerificationMeta('powerTargetPercent');
  @override
  late final GeneratedColumn<double> powerTargetPercent =
      GeneratedColumn<double>(
        'power_target_percent',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _powerLowPercentMeta = const VerificationMeta(
    'powerLowPercent',
  );
  @override
  late final GeneratedColumn<double> powerLowPercent = GeneratedColumn<double>(
    'power_low_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _powerHighPercentMeta = const VerificationMeta(
    'powerHighPercent',
  );
  @override
  late final GeneratedColumn<double> powerHighPercent = GeneratedColumn<double>(
    'power_high_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cadenceTargetMeta = const VerificationMeta(
    'cadenceTarget',
  );
  @override
  late final GeneratedColumn<int> cadenceTarget = GeneratedColumn<int>(
    'cadence_target',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeatCountMeta = const VerificationMeta(
    'repeatCount',
  );
  @override
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
  VerificationContext validateIntegrity(
    Insertable<WorkoutStepRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('power_target_percent')) {
      context.handle(
        _powerTargetPercentMeta,
        powerTargetPercent.isAcceptableOrUnknown(
          data['power_target_percent']!,
          _powerTargetPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_powerTargetPercentMeta);
    }
    if (data.containsKey('power_low_percent')) {
      context.handle(
        _powerLowPercentMeta,
        powerLowPercent.isAcceptableOrUnknown(
          data['power_low_percent']!,
          _powerLowPercentMeta,
        ),
      );
    }
    if (data.containsKey('power_high_percent')) {
      context.handle(
        _powerHighPercentMeta,
        powerHighPercent.isAcceptableOrUnknown(
          data['power_high_percent']!,
          _powerHighPercentMeta,
        ),
      );
    }
    if (data.containsKey('cadence_target')) {
      context.handle(
        _cadenceTargetMeta,
        cadenceTarget.isAcceptableOrUnknown(
          data['cadence_target']!,
          _cadenceTargetMeta,
        ),
      );
    }
    if (data.containsKey('repeat_count')) {
      context.handle(
        _repeatCountMeta,
        repeatCount.isAcceptableOrUnknown(
          data['repeat_count']!,
          _repeatCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutStepRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutStepRow(
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
  $WorkoutStepsTable createAlias(String alias) {
    return $WorkoutStepsTable(attachedDatabase, alias);
  }
}

class WorkoutStepRow extends DataClass implements Insertable<WorkoutStepRow> {
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
  const WorkoutStepRow({
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

  factory WorkoutStepRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutStepRow(
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

  WorkoutStepRow copyWith({
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
  }) => WorkoutStepRow(
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
  WorkoutStepRow copyWithCompanion(WorkoutStepsCompanion data) {
    return WorkoutStepRow(
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
    return (StringBuffer('WorkoutStepRow(')
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
      (other is WorkoutStepRow &&
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

class WorkoutStepsCompanion extends UpdateCompanion<WorkoutStepRow> {
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
  static Insertable<WorkoutStepRow> custom({
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

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ftpMeta = const VerificationMeta('ftp');
  @override
  late final GeneratedColumn<double> ftp = GeneratedColumn<double>(
    'ftp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxHrMeta = const VerificationMeta('maxHr');
  @override
  late final GeneratedColumn<int> maxHr = GeneratedColumn<int>(
    'max_hr',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restHrMeta = const VerificationMeta('restHr');
  @override
  late final GeneratedColumn<int> restHr = GeneratedColumn<int>(
    'rest_hr',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
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
  VerificationContext validateIntegrity(
    Insertable<UserProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('ftp')) {
      context.handle(
        _ftpMeta,
        ftp.isAcceptableOrUnknown(data['ftp']!, _ftpMeta),
      );
    } else if (isInserting) {
      context.missing(_ftpMeta);
    }
    if (data.containsKey('max_hr')) {
      context.handle(
        _maxHrMeta,
        maxHr.isAcceptableOrUnknown(data['max_hr']!, _maxHrMeta),
      );
    }
    if (data.containsKey('rest_hr')) {
      context.handle(
        _restHrMeta,
        restHr.isAcceptableOrUnknown(data['rest_hr']!, _restHrMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
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
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  final String id;
  final String name;
  final double ftp;
  final int? maxHr;
  final int? restHr;
  final double? weight;
  final double? height;
  const UserProfileRow({
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

  factory UserProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
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

  UserProfileRow copyWith({
    String? id,
    String? name,
    double? ftp,
    Value<int?> maxHr = const Value.absent(),
    Value<int?> restHr = const Value.absent(),
    Value<double?> weight = const Value.absent(),
    Value<double?> height = const Value.absent(),
  }) => UserProfileRow(
    id: id ?? this.id,
    name: name ?? this.name,
    ftp: ftp ?? this.ftp,
    maxHr: maxHr.present ? maxHr.value : this.maxHr,
    restHr: restHr.present ? restHr.value : this.restHr,
    weight: weight.present ? weight.value : this.weight,
    height: height.present ? height.value : this.height,
  );
  UserProfileRow copyWithCompanion(UserProfilesCompanion data) {
    return UserProfileRow(
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
    return (StringBuffer('UserProfileRow(')
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
      (other is UserProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.ftp == this.ftp &&
          other.maxHr == this.maxHr &&
          other.restHr == this.restHr &&
          other.weight == this.weight &&
          other.height == this.height);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfileRow> {
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
  static Insertable<UserProfileRow> custom({
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

class $ExportQueueTable extends ExportQueue
    with TableInfo<$ExportQueueTable, ExportQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExportQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
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
  static const VerificationMeta _rideIdMeta = const VerificationMeta('rideId');
  @override
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
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptMeta = const VerificationMeta(
    'lastAttempt',
  );
  @override
  late final GeneratedColumn<int> lastAttempt = GeneratedColumn<int>(
    'last_attempt',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultPathMeta = const VerificationMeta(
    'resultPath',
  );
  @override
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
  VerificationContext validateIntegrity(
    Insertable<ExportQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ride_id')) {
      context.handle(
        _rideIdMeta,
        rideId.isAcceptableOrUnknown(data['ride_id']!, _rideIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rideIdMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_attempt')) {
      context.handle(
        _lastAttemptMeta,
        lastAttempt.isAcceptableOrUnknown(
          data['last_attempt']!,
          _lastAttemptMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('result_path')) {
      context.handle(
        _resultPathMeta,
        resultPath.isAcceptableOrUnknown(data['result_path']!, _resultPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExportQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportQueueRow(
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
  $ExportQueueTable createAlias(String alias) {
    return $ExportQueueTable(attachedDatabase, alias);
  }
}

class ExportQueueRow extends DataClass implements Insertable<ExportQueueRow> {
  final int id;
  final String rideId;
  final String target;
  final String status;
  final int retryCount;
  final int? lastAttempt;
  final String? errorMessage;
  final int createdAt;
  final String? resultPath;
  const ExportQueueRow({
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

  factory ExportQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportQueueRow(
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

  ExportQueueRow copyWith({
    int? id,
    String? rideId,
    String? target,
    String? status,
    int? retryCount,
    Value<int?> lastAttempt = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    int? createdAt,
    Value<String?> resultPath = const Value.absent(),
  }) => ExportQueueRow(
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
  ExportQueueRow copyWithCompanion(ExportQueueCompanion data) {
    return ExportQueueRow(
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
    return (StringBuffer('ExportQueueRow(')
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
      (other is ExportQueueRow &&
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

class ExportQueueCompanion extends UpdateCompanion<ExportQueueRow> {
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
  static Insertable<ExportQueueRow> custom({
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

class $ScheduledWorkoutsTable extends ScheduledWorkouts
    with TableInfo<$ScheduledWorkoutsTable, ScheduledWorkoutRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduledWorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedRideIdMeta = const VerificationMeta(
    'completedRideId',
  );
  @override
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
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
  VerificationContext validateIntegrity(
    Insertable<ScheduledWorkoutRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('completed_ride_id')) {
      context.handle(
        _completedRideIdMeta,
        completedRideId.isAcceptableOrUnknown(
          data['completed_ride_id']!,
          _completedRideIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduledWorkoutRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduledWorkoutRow(
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
  $ScheduledWorkoutsTable createAlias(String alias) {
    return $ScheduledWorkoutsTable(attachedDatabase, alias);
  }
}

class ScheduledWorkoutRow extends DataClass
    implements Insertable<ScheduledWorkoutRow> {
  final String id;
  final String workoutId;
  final int date;
  final String? completedRideId;
  final String? notes;
  final int createdAt;
  const ScheduledWorkoutRow({
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

  factory ScheduledWorkoutRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduledWorkoutRow(
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

  ScheduledWorkoutRow copyWith({
    String? id,
    String? workoutId,
    int? date,
    Value<String?> completedRideId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? createdAt,
  }) => ScheduledWorkoutRow(
    id: id ?? this.id,
    workoutId: workoutId ?? this.workoutId,
    date: date ?? this.date,
    completedRideId: completedRideId.present
        ? completedRideId.value
        : this.completedRideId,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  ScheduledWorkoutRow copyWithCompanion(ScheduledWorkoutsCompanion data) {
    return ScheduledWorkoutRow(
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
    return (StringBuffer('ScheduledWorkoutRow(')
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
      (other is ScheduledWorkoutRow &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.date == this.date &&
          other.completedRideId == this.completedRideId &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class ScheduledWorkoutsCompanion extends UpdateCompanion<ScheduledWorkoutRow> {
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
  static Insertable<ScheduledWorkoutRow> custom({
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

class $PersonalRecordsTable extends PersonalRecords
    with TableInfo<$PersonalRecordsTable, PersonalRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
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
  static const VerificationMeta _rideIdMeta = const VerificationMeta('rideId');
  @override
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
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wattsMeta = const VerificationMeta('watts');
  @override
  late final GeneratedColumn<double> watts = GeneratedColumn<double>(
    'watts',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
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
  VerificationContext validateIntegrity(
    Insertable<PersonalRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ride_id')) {
      context.handle(
        _rideIdMeta,
        rideId.isAcceptableOrUnknown(data['ride_id']!, _rideIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rideIdMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('watts')) {
      context.handle(
        _wattsMeta,
        watts.isAcceptableOrUnknown(data['watts']!, _wattsMeta),
      );
    } else if (isInserting) {
      context.missing(_wattsMeta);
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_achievedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {rideId, durationSeconds},
  ];
  @override
  PersonalRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalRecordRow(
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
  $PersonalRecordsTable createAlias(String alias) {
    return $PersonalRecordsTable(attachedDatabase, alias);
  }
}

class PersonalRecordRow extends DataClass
    implements Insertable<PersonalRecordRow> {
  final int id;
  final String rideId;
  final int durationSeconds;
  final double watts;
  final int achievedAt;
  const PersonalRecordRow({
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

  factory PersonalRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalRecordRow(
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

  PersonalRecordRow copyWith({
    int? id,
    String? rideId,
    int? durationSeconds,
    double? watts,
    int? achievedAt,
  }) => PersonalRecordRow(
    id: id ?? this.id,
    rideId: rideId ?? this.rideId,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    watts: watts ?? this.watts,
    achievedAt: achievedAt ?? this.achievedAt,
  );
  PersonalRecordRow copyWithCompanion(PersonalRecordsCompanion data) {
    return PersonalRecordRow(
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
    return (StringBuffer('PersonalRecordRow(')
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
      (other is PersonalRecordRow &&
          other.id == this.id &&
          other.rideId == this.rideId &&
          other.durationSeconds == this.durationSeconds &&
          other.watts == this.watts &&
          other.achievedAt == this.achievedAt);
}

class PersonalRecordsCompanion extends UpdateCompanion<PersonalRecordRow> {
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
  static Insertable<PersonalRecordRow> custom({
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

class $FtpHistoryTable extends FtpHistory
    with TableInfo<$FtpHistoryTable, FtpHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FtpHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
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
  static const VerificationMeta _effectiveDateMeta = const VerificationMeta(
    'effectiveDate',
  );
  @override
  late final GeneratedColumn<int> effectiveDate = GeneratedColumn<int>(
    'effective_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ftpMeta = const VerificationMeta('ftp');
  @override
  late final GeneratedColumn<double> ftp = GeneratedColumn<double>(
    'ftp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, effectiveDate, ftp, source];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ftp_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<FtpHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('effective_date')) {
      context.handle(
        _effectiveDateMeta,
        effectiveDate.isAcceptableOrUnknown(
          data['effective_date']!,
          _effectiveDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveDateMeta);
    }
    if (data.containsKey('ftp')) {
      context.handle(
        _ftpMeta,
        ftp.isAcceptableOrUnknown(data['ftp']!, _ftpMeta),
      );
    } else if (isInserting) {
      context.missing(_ftpMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FtpHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FtpHistoryRow(
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
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
    );
  }

  @override
  $FtpHistoryTable createAlias(String alias) {
    return $FtpHistoryTable(attachedDatabase, alias);
  }
}

class FtpHistoryRow extends DataClass implements Insertable<FtpHistoryRow> {
  final int id;
  final int effectiveDate;
  final double ftp;

  /// [FtpSource] name. Nullable because rows written before schema v6 have no
  /// recorded provenance — those read back as [FtpSource.manual], which is the
  /// conservative reading (they never count as a test for retest reminders).
  /// Stored as text rather than a drift `textEnum` so an unrecognised value
  /// from a future version degrades to `manual` instead of throwing on read.
  final String? source;
  const FtpHistoryRow({
    required this.id,
    required this.effectiveDate,
    required this.ftp,
    this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['effective_date'] = Variable<int>(effectiveDate);
    map['ftp'] = Variable<double>(ftp);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    return map;
  }

  FtpHistoryCompanion toCompanion(bool nullToAbsent) {
    return FtpHistoryCompanion(
      id: Value(id),
      effectiveDate: Value(effectiveDate),
      ftp: Value(ftp),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
    );
  }

  factory FtpHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FtpHistoryRow(
      id: serializer.fromJson<int>(json['id']),
      effectiveDate: serializer.fromJson<int>(json['effectiveDate']),
      ftp: serializer.fromJson<double>(json['ftp']),
      source: serializer.fromJson<String?>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'effectiveDate': serializer.toJson<int>(effectiveDate),
      'ftp': serializer.toJson<double>(ftp),
      'source': serializer.toJson<String?>(source),
    };
  }

  FtpHistoryRow copyWith({
    int? id,
    int? effectiveDate,
    double? ftp,
    Value<String?> source = const Value.absent(),
  }) => FtpHistoryRow(
    id: id ?? this.id,
    effectiveDate: effectiveDate ?? this.effectiveDate,
    ftp: ftp ?? this.ftp,
    source: source.present ? source.value : this.source,
  );
  FtpHistoryRow copyWithCompanion(FtpHistoryCompanion data) {
    return FtpHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      effectiveDate: data.effectiveDate.present
          ? data.effectiveDate.value
          : this.effectiveDate,
      ftp: data.ftp.present ? data.ftp.value : this.ftp,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FtpHistoryRow(')
          ..write('id: $id, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('ftp: $ftp, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, effectiveDate, ftp, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FtpHistoryRow &&
          other.id == this.id &&
          other.effectiveDate == this.effectiveDate &&
          other.ftp == this.ftp &&
          other.source == this.source);
}

class FtpHistoryCompanion extends UpdateCompanion<FtpHistoryRow> {
  final Value<int> id;
  final Value<int> effectiveDate;
  final Value<double> ftp;
  final Value<String?> source;
  const FtpHistoryCompanion({
    this.id = const Value.absent(),
    this.effectiveDate = const Value.absent(),
    this.ftp = const Value.absent(),
    this.source = const Value.absent(),
  });
  FtpHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int effectiveDate,
    required double ftp,
    this.source = const Value.absent(),
  }) : effectiveDate = Value(effectiveDate),
       ftp = Value(ftp);
  static Insertable<FtpHistoryRow> custom({
    Expression<int>? id,
    Expression<int>? effectiveDate,
    Expression<double>? ftp,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (effectiveDate != null) 'effective_date': effectiveDate,
      if (ftp != null) 'ftp': ftp,
      if (source != null) 'source': source,
    });
  }

  FtpHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? effectiveDate,
    Value<double>? ftp,
    Value<String?>? source,
  }) {
    return FtpHistoryCompanion(
      id: id ?? this.id,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      ftp: ftp ?? this.ftp,
      source: source ?? this.source,
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
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FtpHistoryCompanion(')
          ..write('id: $id, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('ftp: $ftp, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RidesTable rides = $RidesTable(this);
  late final $SensorReadingsTable sensorReadings = $SensorReadingsTable(this);
  late final $LapsTable laps = $LapsTable(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $WorkoutStepsTable workoutSteps = $WorkoutStepsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $ExportQueueTable exportQueue = $ExportQueueTable(this);
  late final $ScheduledWorkoutsTable scheduledWorkouts =
      $ScheduledWorkoutsTable(this);
  late final $PersonalRecordsTable personalRecords = $PersonalRecordsTable(
    this,
  );
  late final $FtpHistoryTable ftpHistory = $FtpHistoryTable(this);
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
}

typedef $$RidesTableCreateCompanionBuilder =
    RidesCompanion Function({
      required String id,
      required int startTime,
      Value<int?> endTime,
      Value<String?> title,
      Value<String?> notes,
      Value<String?> workoutId,
      required String status,
      Value<double?> avgPower,
      Value<double?> normalizedPower,
      Value<double?> maxPower,
      Value<double?> avgCadence,
      Value<double?> avgHr,
      Value<double?> maxHr,
      Value<double?> totalDistance,
      Value<int?> durationSeconds,
      Value<int?> pauseDurationSeconds,
      Value<double?> tss,
      Value<double?> intensityFactor,
      Value<double?> ftpAtTime,
      Value<double?> elevationGainM,
      Value<int> rowid,
    });
typedef $$RidesTableUpdateCompanionBuilder =
    RidesCompanion Function({
      Value<String> id,
      Value<int> startTime,
      Value<int?> endTime,
      Value<String?> title,
      Value<String?> notes,
      Value<String?> workoutId,
      Value<String> status,
      Value<double?> avgPower,
      Value<double?> normalizedPower,
      Value<double?> maxPower,
      Value<double?> avgCadence,
      Value<double?> avgHr,
      Value<double?> maxHr,
      Value<double?> totalDistance,
      Value<int?> durationSeconds,
      Value<int?> pauseDurationSeconds,
      Value<double?> tss,
      Value<double?> intensityFactor,
      Value<double?> ftpAtTime,
      Value<double?> elevationGainM,
      Value<int> rowid,
    });

final class $$RidesTableReferences
    extends BaseReferences<_$AppDatabase, $RidesTable, RideRow> {
  $$RidesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SensorReadingsTable, List<SensorReadingRow>>
  _sensorReadingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sensorReadings,
    aliasName: $_aliasNameGenerator(db.rides.id, db.sensorReadings.rideId),
  );

  $$SensorReadingsTableProcessedTableManager get sensorReadingsRefs {
    final manager = $$SensorReadingsTableTableManager(
      $_db,
      $_db.sensorReadings,
    ).filter((f) => f.rideId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sensorReadingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LapsTable, List<LapRow>> _lapsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.laps,
    aliasName: $_aliasNameGenerator(db.rides.id, db.laps.rideId),
  );

  $$LapsTableProcessedTableManager get lapsRefs {
    final manager = $$LapsTableTableManager(
      $_db,
      $_db.laps,
    ).filter((f) => f.rideId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lapsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExportQueueTable, List<ExportQueueRow>>
  _exportQueueRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exportQueue,
    aliasName: $_aliasNameGenerator(db.rides.id, db.exportQueue.rideId),
  );

  $$ExportQueueTableProcessedTableManager get exportQueueRefs {
    final manager = $$ExportQueueTableTableManager(
      $_db,
      $_db.exportQueue,
    ).filter((f) => f.rideId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_exportQueueRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScheduledWorkoutsTable, List<ScheduledWorkoutRow>>
  _scheduledWorkoutsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scheduledWorkouts,
        aliasName: $_aliasNameGenerator(
          db.rides.id,
          db.scheduledWorkouts.completedRideId,
        ),
      );

  $$ScheduledWorkoutsTableProcessedTableManager get scheduledWorkoutsRefs {
    final manager =
        $$ScheduledWorkoutsTableTableManager(
          $_db,
          $_db.scheduledWorkouts,
        ).filter(
          (f) => f.completedRideId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _scheduledWorkoutsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PersonalRecordsTable, List<PersonalRecordRow>>
  _personalRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personalRecords,
    aliasName: $_aliasNameGenerator(db.rides.id, db.personalRecords.rideId),
  );

  $$PersonalRecordsTableProcessedTableManager get personalRecordsRefs {
    final manager = $$PersonalRecordsTableTableManager(
      $_db,
      $_db.personalRecords,
    ).filter((f) => f.rideId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RidesTableFilterComposer extends Composer<_$AppDatabase, $RidesTable> {
  $$RidesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workoutId => $composableBuilder(
    column: $table.workoutId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgPower => $composableBuilder(
    column: $table.avgPower,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get normalizedPower => $composableBuilder(
    column: $table.normalizedPower,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxPower => $composableBuilder(
    column: $table.maxPower,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgHr => $composableBuilder(
    column: $table.avgHr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxHr => $composableBuilder(
    column: $table.maxHr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalDistance => $composableBuilder(
    column: $table.totalDistance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pauseDurationSeconds => $composableBuilder(
    column: $table.pauseDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tss => $composableBuilder(
    column: $table.tss,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get intensityFactor => $composableBuilder(
    column: $table.intensityFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ftpAtTime => $composableBuilder(
    column: $table.ftpAtTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGainM => $composableBuilder(
    column: $table.elevationGainM,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sensorReadingsRefs(
    Expression<bool> Function($$SensorReadingsTableFilterComposer f) f,
  ) {
    final $$SensorReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sensorReadings,
      getReferencedColumn: (t) => t.rideId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SensorReadingsTableFilterComposer(
            $db: $db,
            $table: $db.sensorReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lapsRefs(
    Expression<bool> Function($$LapsTableFilterComposer f) f,
  ) {
    final $$LapsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.laps,
      getReferencedColumn: (t) => t.rideId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LapsTableFilterComposer(
            $db: $db,
            $table: $db.laps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exportQueueRefs(
    Expression<bool> Function($$ExportQueueTableFilterComposer f) f,
  ) {
    final $$ExportQueueTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exportQueue,
      getReferencedColumn: (t) => t.rideId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExportQueueTableFilterComposer(
            $db: $db,
            $table: $db.exportQueue,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scheduledWorkoutsRefs(
    Expression<bool> Function($$ScheduledWorkoutsTableFilterComposer f) f,
  ) {
    final $$ScheduledWorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduledWorkouts,
      getReferencedColumn: (t) => t.completedRideId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduledWorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.scheduledWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> personalRecordsRefs(
    Expression<bool> Function($$PersonalRecordsTableFilterComposer f) f,
  ) {
    final $$PersonalRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.rideId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableFilterComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RidesTableOrderingComposer
    extends Composer<_$AppDatabase, $RidesTable> {
  $$RidesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workoutId => $composableBuilder(
    column: $table.workoutId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgPower => $composableBuilder(
    column: $table.avgPower,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get normalizedPower => $composableBuilder(
    column: $table.normalizedPower,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxPower => $composableBuilder(
    column: $table.maxPower,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgHr => $composableBuilder(
    column: $table.avgHr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxHr => $composableBuilder(
    column: $table.maxHr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalDistance => $composableBuilder(
    column: $table.totalDistance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pauseDurationSeconds => $composableBuilder(
    column: $table.pauseDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tss => $composableBuilder(
    column: $table.tss,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get intensityFactor => $composableBuilder(
    column: $table.intensityFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ftpAtTime => $composableBuilder(
    column: $table.ftpAtTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGainM => $composableBuilder(
    column: $table.elevationGainM,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RidesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RidesTable> {
  $$RidesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<int> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get workoutId =>
      $composableBuilder(column: $table.workoutId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get avgPower =>
      $composableBuilder(column: $table.avgPower, builder: (column) => column);

  GeneratedColumn<double> get normalizedPower => $composableBuilder(
    column: $table.normalizedPower,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxPower =>
      $composableBuilder(column: $table.maxPower, builder: (column) => column);

  GeneratedColumn<double> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgHr =>
      $composableBuilder(column: $table.avgHr, builder: (column) => column);

  GeneratedColumn<double> get maxHr =>
      $composableBuilder(column: $table.maxHr, builder: (column) => column);

  GeneratedColumn<double> get totalDistance => $composableBuilder(
    column: $table.totalDistance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pauseDurationSeconds => $composableBuilder(
    column: $table.pauseDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tss =>
      $composableBuilder(column: $table.tss, builder: (column) => column);

  GeneratedColumn<double> get intensityFactor => $composableBuilder(
    column: $table.intensityFactor,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ftpAtTime =>
      $composableBuilder(column: $table.ftpAtTime, builder: (column) => column);

  GeneratedColumn<double> get elevationGainM => $composableBuilder(
    column: $table.elevationGainM,
    builder: (column) => column,
  );

  Expression<T> sensorReadingsRefs<T extends Object>(
    Expression<T> Function($$SensorReadingsTableAnnotationComposer a) f,
  ) {
    final $$SensorReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sensorReadings,
      getReferencedColumn: (t) => t.rideId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SensorReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.sensorReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lapsRefs<T extends Object>(
    Expression<T> Function($$LapsTableAnnotationComposer a) f,
  ) {
    final $$LapsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.laps,
      getReferencedColumn: (t) => t.rideId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LapsTableAnnotationComposer(
            $db: $db,
            $table: $db.laps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exportQueueRefs<T extends Object>(
    Expression<T> Function($$ExportQueueTableAnnotationComposer a) f,
  ) {
    final $$ExportQueueTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exportQueue,
      getReferencedColumn: (t) => t.rideId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExportQueueTableAnnotationComposer(
            $db: $db,
            $table: $db.exportQueue,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scheduledWorkoutsRefs<T extends Object>(
    Expression<T> Function($$ScheduledWorkoutsTableAnnotationComposer a) f,
  ) {
    final $$ScheduledWorkoutsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scheduledWorkouts,
          getReferencedColumn: (t) => t.completedRideId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduledWorkoutsTableAnnotationComposer(
                $db: $db,
                $table: $db.scheduledWorkouts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> personalRecordsRefs<T extends Object>(
    Expression<T> Function($$PersonalRecordsTableAnnotationComposer a) f,
  ) {
    final $$PersonalRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.rideId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RidesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RidesTable,
          RideRow,
          $$RidesTableFilterComposer,
          $$RidesTableOrderingComposer,
          $$RidesTableAnnotationComposer,
          $$RidesTableCreateCompanionBuilder,
          $$RidesTableUpdateCompanionBuilder,
          (RideRow, $$RidesTableReferences),
          RideRow,
          PrefetchHooks Function({
            bool sensorReadingsRefs,
            bool lapsRefs,
            bool exportQueueRefs,
            bool scheduledWorkoutsRefs,
            bool personalRecordsRefs,
          })
        > {
  $$RidesTableTableManager(_$AppDatabase db, $RidesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RidesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RidesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RidesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> startTime = const Value.absent(),
                Value<int?> endTime = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> workoutId = const Value.absent(),
                Value<String> status = const Value.absent(),
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
                Value<int> rowid = const Value.absent(),
              }) => RidesCompanion(
                id: id,
                startTime: startTime,
                endTime: endTime,
                title: title,
                notes: notes,
                workoutId: workoutId,
                status: status,
                avgPower: avgPower,
                normalizedPower: normalizedPower,
                maxPower: maxPower,
                avgCadence: avgCadence,
                avgHr: avgHr,
                maxHr: maxHr,
                totalDistance: totalDistance,
                durationSeconds: durationSeconds,
                pauseDurationSeconds: pauseDurationSeconds,
                tss: tss,
                intensityFactor: intensityFactor,
                ftpAtTime: ftpAtTime,
                elevationGainM: elevationGainM,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int startTime,
                Value<int?> endTime = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> workoutId = const Value.absent(),
                required String status,
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
                Value<int> rowid = const Value.absent(),
              }) => RidesCompanion.insert(
                id: id,
                startTime: startTime,
                endTime: endTime,
                title: title,
                notes: notes,
                workoutId: workoutId,
                status: status,
                avgPower: avgPower,
                normalizedPower: normalizedPower,
                maxPower: maxPower,
                avgCadence: avgCadence,
                avgHr: avgHr,
                maxHr: maxHr,
                totalDistance: totalDistance,
                durationSeconds: durationSeconds,
                pauseDurationSeconds: pauseDurationSeconds,
                tss: tss,
                intensityFactor: intensityFactor,
                ftpAtTime: ftpAtTime,
                elevationGainM: elevationGainM,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RidesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sensorReadingsRefs = false,
                lapsRefs = false,
                exportQueueRefs = false,
                scheduledWorkoutsRefs = false,
                personalRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sensorReadingsRefs) db.sensorReadings,
                    if (lapsRefs) db.laps,
                    if (exportQueueRefs) db.exportQueue,
                    if (scheduledWorkoutsRefs) db.scheduledWorkouts,
                    if (personalRecordsRefs) db.personalRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sensorReadingsRefs)
                        await $_getPrefetchedData<
                          RideRow,
                          $RidesTable,
                          SensorReadingRow
                        >(
                          currentTable: table,
                          referencedTable: $$RidesTableReferences
                              ._sensorReadingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RidesTableReferences(
                                db,
                                table,
                                p0,
                              ).sensorReadingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rideId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lapsRefs)
                        await $_getPrefetchedData<RideRow, $RidesTable, LapRow>(
                          currentTable: table,
                          referencedTable: $$RidesTableReferences
                              ._lapsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RidesTableReferences(db, table, p0).lapsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rideId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exportQueueRefs)
                        await $_getPrefetchedData<
                          RideRow,
                          $RidesTable,
                          ExportQueueRow
                        >(
                          currentTable: table,
                          referencedTable: $$RidesTableReferences
                              ._exportQueueRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RidesTableReferences(
                                db,
                                table,
                                p0,
                              ).exportQueueRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rideId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scheduledWorkoutsRefs)
                        await $_getPrefetchedData<
                          RideRow,
                          $RidesTable,
                          ScheduledWorkoutRow
                        >(
                          currentTable: table,
                          referencedTable: $$RidesTableReferences
                              ._scheduledWorkoutsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RidesTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduledWorkoutsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.completedRideId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (personalRecordsRefs)
                        await $_getPrefetchedData<
                          RideRow,
                          $RidesTable,
                          PersonalRecordRow
                        >(
                          currentTable: table,
                          referencedTable: $$RidesTableReferences
                              ._personalRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RidesTableReferences(
                                db,
                                table,
                                p0,
                              ).personalRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rideId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RidesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RidesTable,
      RideRow,
      $$RidesTableFilterComposer,
      $$RidesTableOrderingComposer,
      $$RidesTableAnnotationComposer,
      $$RidesTableCreateCompanionBuilder,
      $$RidesTableUpdateCompanionBuilder,
      (RideRow, $$RidesTableReferences),
      RideRow,
      PrefetchHooks Function({
        bool sensorReadingsRefs,
        bool lapsRefs,
        bool exportQueueRefs,
        bool scheduledWorkoutsRefs,
        bool personalRecordsRefs,
      })
    >;
typedef $$SensorReadingsTableCreateCompanionBuilder =
    SensorReadingsCompanion Function({
      Value<int> id,
      required String rideId,
      required int timestamp,
      Value<double?> powerWatts,
      Value<double?> cadenceRpm,
      Value<int?> heartRateBpm,
      Value<double?> speedKmh,
      Value<double?> distanceM,
      Value<double?> gradePercent,
    });
typedef $$SensorReadingsTableUpdateCompanionBuilder =
    SensorReadingsCompanion Function({
      Value<int> id,
      Value<String> rideId,
      Value<int> timestamp,
      Value<double?> powerWatts,
      Value<double?> cadenceRpm,
      Value<int?> heartRateBpm,
      Value<double?> speedKmh,
      Value<double?> distanceM,
      Value<double?> gradePercent,
    });

final class $$SensorReadingsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SensorReadingsTable, SensorReadingRow> {
  $$SensorReadingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RidesTable _rideIdTable(_$AppDatabase db) => db.rides.createAlias(
    $_aliasNameGenerator(db.sensorReadings.rideId, db.rides.id),
  );

  $$RidesTableProcessedTableManager get rideId {
    final $_column = $_itemColumn<String>('ride_id')!;

    final manager = $$RidesTableTableManager(
      $_db,
      $_db.rides,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rideIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SensorReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $SensorReadingsTable> {
  $$SensorReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get powerWatts => $composableBuilder(
    column: $table.powerWatts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cadenceRpm => $composableBuilder(
    column: $table.cadenceRpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heartRateBpm => $composableBuilder(
    column: $table.heartRateBpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedKmh => $composableBuilder(
    column: $table.speedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gradePercent => $composableBuilder(
    column: $table.gradePercent,
    builder: (column) => ColumnFilters(column),
  );

  $$RidesTableFilterComposer get rideId {
    final $$RidesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableFilterComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SensorReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SensorReadingsTable> {
  $$SensorReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get powerWatts => $composableBuilder(
    column: $table.powerWatts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cadenceRpm => $composableBuilder(
    column: $table.cadenceRpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heartRateBpm => $composableBuilder(
    column: $table.heartRateBpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedKmh => $composableBuilder(
    column: $table.speedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gradePercent => $composableBuilder(
    column: $table.gradePercent,
    builder: (column) => ColumnOrderings(column),
  );

  $$RidesTableOrderingComposer get rideId {
    final $$RidesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableOrderingComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SensorReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SensorReadingsTable> {
  $$SensorReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get powerWatts => $composableBuilder(
    column: $table.powerWatts,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cadenceRpm => $composableBuilder(
    column: $table.cadenceRpm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get heartRateBpm => $composableBuilder(
    column: $table.heartRateBpm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speedKmh =>
      $composableBuilder(column: $table.speedKmh, builder: (column) => column);

  GeneratedColumn<double> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<double> get gradePercent => $composableBuilder(
    column: $table.gradePercent,
    builder: (column) => column,
  );

  $$RidesTableAnnotationComposer get rideId {
    final $$RidesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableAnnotationComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SensorReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SensorReadingsTable,
          SensorReadingRow,
          $$SensorReadingsTableFilterComposer,
          $$SensorReadingsTableOrderingComposer,
          $$SensorReadingsTableAnnotationComposer,
          $$SensorReadingsTableCreateCompanionBuilder,
          $$SensorReadingsTableUpdateCompanionBuilder,
          (SensorReadingRow, $$SensorReadingsTableReferences),
          SensorReadingRow,
          PrefetchHooks Function({bool rideId})
        > {
  $$SensorReadingsTableTableManager(
    _$AppDatabase db,
    $SensorReadingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SensorReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SensorReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SensorReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rideId = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<double?> powerWatts = const Value.absent(),
                Value<double?> cadenceRpm = const Value.absent(),
                Value<int?> heartRateBpm = const Value.absent(),
                Value<double?> speedKmh = const Value.absent(),
                Value<double?> distanceM = const Value.absent(),
                Value<double?> gradePercent = const Value.absent(),
              }) => SensorReadingsCompanion(
                id: id,
                rideId: rideId,
                timestamp: timestamp,
                powerWatts: powerWatts,
                cadenceRpm: cadenceRpm,
                heartRateBpm: heartRateBpm,
                speedKmh: speedKmh,
                distanceM: distanceM,
                gradePercent: gradePercent,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rideId,
                required int timestamp,
                Value<double?> powerWatts = const Value.absent(),
                Value<double?> cadenceRpm = const Value.absent(),
                Value<int?> heartRateBpm = const Value.absent(),
                Value<double?> speedKmh = const Value.absent(),
                Value<double?> distanceM = const Value.absent(),
                Value<double?> gradePercent = const Value.absent(),
              }) => SensorReadingsCompanion.insert(
                id: id,
                rideId: rideId,
                timestamp: timestamp,
                powerWatts: powerWatts,
                cadenceRpm: cadenceRpm,
                heartRateBpm: heartRateBpm,
                speedKmh: speedKmh,
                distanceM: distanceM,
                gradePercent: gradePercent,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SensorReadingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rideId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (rideId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rideId,
                                referencedTable: $$SensorReadingsTableReferences
                                    ._rideIdTable(db),
                                referencedColumn:
                                    $$SensorReadingsTableReferences
                                        ._rideIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SensorReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SensorReadingsTable,
      SensorReadingRow,
      $$SensorReadingsTableFilterComposer,
      $$SensorReadingsTableOrderingComposer,
      $$SensorReadingsTableAnnotationComposer,
      $$SensorReadingsTableCreateCompanionBuilder,
      $$SensorReadingsTableUpdateCompanionBuilder,
      (SensorReadingRow, $$SensorReadingsTableReferences),
      SensorReadingRow,
      PrefetchHooks Function({bool rideId})
    >;
typedef $$LapsTableCreateCompanionBuilder =
    LapsCompanion Function({
      Value<int> id,
      required String rideId,
      required int startIndex,
      required int endIndex,
      required int startTime,
      required int durationMs,
    });
typedef $$LapsTableUpdateCompanionBuilder =
    LapsCompanion Function({
      Value<int> id,
      Value<String> rideId,
      Value<int> startIndex,
      Value<int> endIndex,
      Value<int> startTime,
      Value<int> durationMs,
    });

final class $$LapsTableReferences
    extends BaseReferences<_$AppDatabase, $LapsTable, LapRow> {
  $$LapsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RidesTable _rideIdTable(_$AppDatabase db) =>
      db.rides.createAlias($_aliasNameGenerator(db.laps.rideId, db.rides.id));

  $$RidesTableProcessedTableManager get rideId {
    final $_column = $_itemColumn<String>('ride_id')!;

    final manager = $$RidesTableTableManager(
      $_db,
      $_db.rides,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rideIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LapsTableFilterComposer extends Composer<_$AppDatabase, $LapsTable> {
  $$LapsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startIndex => $composableBuilder(
    column: $table.startIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endIndex => $composableBuilder(
    column: $table.endIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  $$RidesTableFilterComposer get rideId {
    final $$RidesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableFilterComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LapsTableOrderingComposer extends Composer<_$AppDatabase, $LapsTable> {
  $$LapsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startIndex => $composableBuilder(
    column: $table.startIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endIndex => $composableBuilder(
    column: $table.endIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$RidesTableOrderingComposer get rideId {
    final $$RidesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableOrderingComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LapsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LapsTable> {
  $$LapsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startIndex => $composableBuilder(
    column: $table.startIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endIndex =>
      $composableBuilder(column: $table.endIndex, builder: (column) => column);

  GeneratedColumn<int> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  $$RidesTableAnnotationComposer get rideId {
    final $$RidesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableAnnotationComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LapsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LapsTable,
          LapRow,
          $$LapsTableFilterComposer,
          $$LapsTableOrderingComposer,
          $$LapsTableAnnotationComposer,
          $$LapsTableCreateCompanionBuilder,
          $$LapsTableUpdateCompanionBuilder,
          (LapRow, $$LapsTableReferences),
          LapRow,
          PrefetchHooks Function({bool rideId})
        > {
  $$LapsTableTableManager(_$AppDatabase db, $LapsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LapsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LapsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LapsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rideId = const Value.absent(),
                Value<int> startIndex = const Value.absent(),
                Value<int> endIndex = const Value.absent(),
                Value<int> startTime = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
              }) => LapsCompanion(
                id: id,
                rideId: rideId,
                startIndex: startIndex,
                endIndex: endIndex,
                startTime: startTime,
                durationMs: durationMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rideId,
                required int startIndex,
                required int endIndex,
                required int startTime,
                required int durationMs,
              }) => LapsCompanion.insert(
                id: id,
                rideId: rideId,
                startIndex: startIndex,
                endIndex: endIndex,
                startTime: startTime,
                durationMs: durationMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$LapsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({rideId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (rideId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rideId,
                                referencedTable: $$LapsTableReferences
                                    ._rideIdTable(db),
                                referencedColumn: $$LapsTableReferences
                                    ._rideIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LapsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LapsTable,
      LapRow,
      $$LapsTableFilterComposer,
      $$LapsTableOrderingComposer,
      $$LapsTableAnnotationComposer,
      $$LapsTableCreateCompanionBuilder,
      $$LapsTableUpdateCompanionBuilder,
      (LapRow, $$LapsTableReferences),
      LapRow,
      PrefetchHooks Function({bool rideId})
    >;
typedef $$WorkoutsTableCreateCompanionBuilder =
    WorkoutsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      required String stepsJson,
      Value<int> rowid,
    });
typedef $$WorkoutsTableUpdateCompanionBuilder =
    WorkoutsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String> stepsJson,
      Value<int> rowid,
    });

final class $$WorkoutsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutsTable, WorkoutRow> {
  $$WorkoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutStepsTable, List<WorkoutStepRow>>
  _workoutStepsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSteps,
    aliasName: $_aliasNameGenerator(db.workouts.id, db.workoutSteps.workoutId),
  );

  $$WorkoutStepsTableProcessedTableManager get workoutStepsRefs {
    final manager = $$WorkoutStepsTableTableManager(
      $_db,
      $_db.workoutSteps,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutStepsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScheduledWorkoutsTable, List<ScheduledWorkoutRow>>
  _scheduledWorkoutsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scheduledWorkouts,
        aliasName: $_aliasNameGenerator(
          db.workouts.id,
          db.scheduledWorkouts.workoutId,
        ),
      );

  $$ScheduledWorkoutsTableProcessedTableManager get scheduledWorkoutsRefs {
    final manager = $$ScheduledWorkoutsTableTableManager(
      $_db,
      $_db.scheduledWorkouts,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scheduledWorkoutsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepsJson => $composableBuilder(
    column: $table.stepsJson,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutStepsRefs(
    Expression<bool> Function($$WorkoutStepsTableFilterComposer f) f,
  ) {
    final $$WorkoutStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSteps,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutStepsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scheduledWorkoutsRefs(
    Expression<bool> Function($$ScheduledWorkoutsTableFilterComposer f) f,
  ) {
    final $$ScheduledWorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduledWorkouts,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduledWorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.scheduledWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepsJson => $composableBuilder(
    column: $table.stepsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stepsJson =>
      $composableBuilder(column: $table.stepsJson, builder: (column) => column);

  Expression<T> workoutStepsRefs<T extends Object>(
    Expression<T> Function($$WorkoutStepsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutStepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSteps,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutStepsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scheduledWorkoutsRefs<T extends Object>(
    Expression<T> Function($$ScheduledWorkoutsTableAnnotationComposer a) f,
  ) {
    final $$ScheduledWorkoutsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scheduledWorkouts,
          getReferencedColumn: (t) => t.workoutId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduledWorkoutsTableAnnotationComposer(
                $db: $db,
                $table: $db.scheduledWorkouts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutsTable,
          WorkoutRow,
          $$WorkoutsTableFilterComposer,
          $$WorkoutsTableOrderingComposer,
          $$WorkoutsTableAnnotationComposer,
          $$WorkoutsTableCreateCompanionBuilder,
          $$WorkoutsTableUpdateCompanionBuilder,
          (WorkoutRow, $$WorkoutsTableReferences),
          WorkoutRow,
          PrefetchHooks Function({
            bool workoutStepsRefs,
            bool scheduledWorkoutsRefs,
          })
        > {
  $$WorkoutsTableTableManager(_$AppDatabase db, $WorkoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> stepsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutsCompanion(
                id: id,
                name: name,
                description: description,
                stepsJson: stepsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required String stepsJson,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutsCompanion.insert(
                id: id,
                name: name,
                description: description,
                stepsJson: stepsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutStepsRefs = false, scheduledWorkoutsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutStepsRefs) db.workoutSteps,
                    if (scheduledWorkoutsRefs) db.scheduledWorkouts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutStepsRefs)
                        await $_getPrefetchedData<
                          WorkoutRow,
                          $WorkoutsTable,
                          WorkoutStepRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutsTableReferences
                              ._workoutStepsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutStepsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scheduledWorkoutsRefs)
                        await $_getPrefetchedData<
                          WorkoutRow,
                          $WorkoutsTable,
                          ScheduledWorkoutRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutsTableReferences
                              ._scheduledWorkoutsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduledWorkoutsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutsTable,
      WorkoutRow,
      $$WorkoutsTableFilterComposer,
      $$WorkoutsTableOrderingComposer,
      $$WorkoutsTableAnnotationComposer,
      $$WorkoutsTableCreateCompanionBuilder,
      $$WorkoutsTableUpdateCompanionBuilder,
      (WorkoutRow, $$WorkoutsTableReferences),
      WorkoutRow,
      PrefetchHooks Function({
        bool workoutStepsRefs,
        bool scheduledWorkoutsRefs,
      })
    >;
typedef $$WorkoutStepsTableCreateCompanionBuilder =
    WorkoutStepsCompanion Function({
      Value<int> id,
      required String workoutId,
      required int orderIndex,
      required String type,
      required int durationSeconds,
      required double powerTargetPercent,
      Value<double?> powerLowPercent,
      Value<double?> powerHighPercent,
      Value<int?> cadenceTarget,
      Value<int?> repeatCount,
    });
typedef $$WorkoutStepsTableUpdateCompanionBuilder =
    WorkoutStepsCompanion Function({
      Value<int> id,
      Value<String> workoutId,
      Value<int> orderIndex,
      Value<String> type,
      Value<int> durationSeconds,
      Value<double> powerTargetPercent,
      Value<double?> powerLowPercent,
      Value<double?> powerHighPercent,
      Value<int?> cadenceTarget,
      Value<int?> repeatCount,
    });

final class $$WorkoutStepsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutStepsTable, WorkoutStepRow> {
  $$WorkoutStepsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias(
        $_aliasNameGenerator(db.workoutSteps.workoutId, db.workouts.id),
      );

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<String>('workout_id')!;

    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutStepsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutStepsTable> {
  $$WorkoutStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get powerTargetPercent => $composableBuilder(
    column: $table.powerTargetPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get powerLowPercent => $composableBuilder(
    column: $table.powerLowPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get powerHighPercent => $composableBuilder(
    column: $table.powerHighPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cadenceTarget => $composableBuilder(
    column: $table.cadenceTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatCount => $composableBuilder(
    column: $table.repeatCount,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutStepsTable> {
  $$WorkoutStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get powerTargetPercent => $composableBuilder(
    column: $table.powerTargetPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get powerLowPercent => $composableBuilder(
    column: $table.powerLowPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get powerHighPercent => $composableBuilder(
    column: $table.powerHighPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cadenceTarget => $composableBuilder(
    column: $table.cadenceTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatCount => $composableBuilder(
    column: $table.repeatCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutStepsTable> {
  $$WorkoutStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get powerTargetPercent => $composableBuilder(
    column: $table.powerTargetPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get powerLowPercent => $composableBuilder(
    column: $table.powerLowPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get powerHighPercent => $composableBuilder(
    column: $table.powerHighPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cadenceTarget => $composableBuilder(
    column: $table.cadenceTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeatCount => $composableBuilder(
    column: $table.repeatCount,
    builder: (column) => column,
  );

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutStepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutStepsTable,
          WorkoutStepRow,
          $$WorkoutStepsTableFilterComposer,
          $$WorkoutStepsTableOrderingComposer,
          $$WorkoutStepsTableAnnotationComposer,
          $$WorkoutStepsTableCreateCompanionBuilder,
          $$WorkoutStepsTableUpdateCompanionBuilder,
          (WorkoutStepRow, $$WorkoutStepsTableReferences),
          WorkoutStepRow,
          PrefetchHooks Function({bool workoutId})
        > {
  $$WorkoutStepsTableTableManager(_$AppDatabase db, $WorkoutStepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> workoutId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double> powerTargetPercent = const Value.absent(),
                Value<double?> powerLowPercent = const Value.absent(),
                Value<double?> powerHighPercent = const Value.absent(),
                Value<int?> cadenceTarget = const Value.absent(),
                Value<int?> repeatCount = const Value.absent(),
              }) => WorkoutStepsCompanion(
                id: id,
                workoutId: workoutId,
                orderIndex: orderIndex,
                type: type,
                durationSeconds: durationSeconds,
                powerTargetPercent: powerTargetPercent,
                powerLowPercent: powerLowPercent,
                powerHighPercent: powerHighPercent,
                cadenceTarget: cadenceTarget,
                repeatCount: repeatCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String workoutId,
                required int orderIndex,
                required String type,
                required int durationSeconds,
                required double powerTargetPercent,
                Value<double?> powerLowPercent = const Value.absent(),
                Value<double?> powerHighPercent = const Value.absent(),
                Value<int?> cadenceTarget = const Value.absent(),
                Value<int?> repeatCount = const Value.absent(),
              }) => WorkoutStepsCompanion.insert(
                id: id,
                workoutId: workoutId,
                orderIndex: orderIndex,
                type: type,
                durationSeconds: durationSeconds,
                powerTargetPercent: powerTargetPercent,
                powerLowPercent: powerLowPercent,
                powerHighPercent: powerHighPercent,
                cadenceTarget: cadenceTarget,
                repeatCount: repeatCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutStepsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workoutId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workoutId,
                                referencedTable: $$WorkoutStepsTableReferences
                                    ._workoutIdTable(db),
                                referencedColumn: $$WorkoutStepsTableReferences
                                    ._workoutIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutStepsTable,
      WorkoutStepRow,
      $$WorkoutStepsTableFilterComposer,
      $$WorkoutStepsTableOrderingComposer,
      $$WorkoutStepsTableAnnotationComposer,
      $$WorkoutStepsTableCreateCompanionBuilder,
      $$WorkoutStepsTableUpdateCompanionBuilder,
      (WorkoutStepRow, $$WorkoutStepsTableReferences),
      WorkoutStepRow,
      PrefetchHooks Function({bool workoutId})
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      required String name,
      required double ftp,
      Value<int?> maxHr,
      Value<int?> restHr,
      Value<double?> weight,
      Value<double?> height,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> ftp,
      Value<int?> maxHr,
      Value<int?> restHr,
      Value<double?> weight,
      Value<double?> height,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ftp => $composableBuilder(
    column: $table.ftp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxHr => $composableBuilder(
    column: $table.maxHr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restHr => $composableBuilder(
    column: $table.restHr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ftp => $composableBuilder(
    column: $table.ftp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxHr => $composableBuilder(
    column: $table.maxHr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restHr => $composableBuilder(
    column: $table.restHr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get ftp =>
      $composableBuilder(column: $table.ftp, builder: (column) => column);

  GeneratedColumn<int> get maxHr =>
      $composableBuilder(column: $table.maxHr, builder: (column) => column);

  GeneratedColumn<int> get restHr =>
      $composableBuilder(column: $table.restHr, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfileRow,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfileRow,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow>,
          ),
          UserProfileRow,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> ftp = const Value.absent(),
                Value<int?> maxHr = const Value.absent(),
                Value<int?> restHr = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<double?> height = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                name: name,
                ftp: ftp,
                maxHr: maxHr,
                restHr: restHr,
                weight: weight,
                height: height,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double ftp,
                Value<int?> maxHr = const Value.absent(),
                Value<int?> restHr = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<double?> height = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                name: name,
                ftp: ftp,
                maxHr: maxHr,
                restHr: restHr,
                weight: weight,
                height: height,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfileRow,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfileRow,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow>,
      ),
      UserProfileRow,
      PrefetchHooks Function()
    >;
typedef $$ExportQueueTableCreateCompanionBuilder =
    ExportQueueCompanion Function({
      Value<int> id,
      required String rideId,
      required String target,
      Value<String> status,
      Value<int> retryCount,
      Value<int?> lastAttempt,
      Value<String?> errorMessage,
      required int createdAt,
      Value<String?> resultPath,
    });
typedef $$ExportQueueTableUpdateCompanionBuilder =
    ExportQueueCompanion Function({
      Value<int> id,
      Value<String> rideId,
      Value<String> target,
      Value<String> status,
      Value<int> retryCount,
      Value<int?> lastAttempt,
      Value<String?> errorMessage,
      Value<int> createdAt,
      Value<String?> resultPath,
    });

final class $$ExportQueueTableReferences
    extends BaseReferences<_$AppDatabase, $ExportQueueTable, ExportQueueRow> {
  $$ExportQueueTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RidesTable _rideIdTable(_$AppDatabase db) => db.rides.createAlias(
    $_aliasNameGenerator(db.exportQueue.rideId, db.rides.id),
  );

  $$RidesTableProcessedTableManager get rideId {
    final $_column = $_itemColumn<String>('ride_id')!;

    final manager = $$RidesTableTableManager(
      $_db,
      $_db.rides,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rideIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExportQueueTableFilterComposer
    extends Composer<_$AppDatabase, $ExportQueueTable> {
  $$ExportQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultPath => $composableBuilder(
    column: $table.resultPath,
    builder: (column) => ColumnFilters(column),
  );

  $$RidesTableFilterComposer get rideId {
    final $$RidesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableFilterComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $ExportQueueTable> {
  $$ExportQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultPath => $composableBuilder(
    column: $table.resultPath,
    builder: (column) => ColumnOrderings(column),
  );

  $$RidesTableOrderingComposer get rideId {
    final $$RidesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableOrderingComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExportQueueTable> {
  $$ExportQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get resultPath => $composableBuilder(
    column: $table.resultPath,
    builder: (column) => column,
  );

  $$RidesTableAnnotationComposer get rideId {
    final $$RidesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableAnnotationComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExportQueueTable,
          ExportQueueRow,
          $$ExportQueueTableFilterComposer,
          $$ExportQueueTableOrderingComposer,
          $$ExportQueueTableAnnotationComposer,
          $$ExportQueueTableCreateCompanionBuilder,
          $$ExportQueueTableUpdateCompanionBuilder,
          (ExportQueueRow, $$ExportQueueTableReferences),
          ExportQueueRow,
          PrefetchHooks Function({bool rideId})
        > {
  $$ExportQueueTableTableManager(_$AppDatabase db, $ExportQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExportQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExportQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExportQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rideId = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<int?> lastAttempt = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String?> resultPath = const Value.absent(),
              }) => ExportQueueCompanion(
                id: id,
                rideId: rideId,
                target: target,
                status: status,
                retryCount: retryCount,
                lastAttempt: lastAttempt,
                errorMessage: errorMessage,
                createdAt: createdAt,
                resultPath: resultPath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rideId,
                required String target,
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<int?> lastAttempt = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                required int createdAt,
                Value<String?> resultPath = const Value.absent(),
              }) => ExportQueueCompanion.insert(
                id: id,
                rideId: rideId,
                target: target,
                status: status,
                retryCount: retryCount,
                lastAttempt: lastAttempt,
                errorMessage: errorMessage,
                createdAt: createdAt,
                resultPath: resultPath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExportQueueTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rideId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (rideId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rideId,
                                referencedTable: $$ExportQueueTableReferences
                                    ._rideIdTable(db),
                                referencedColumn: $$ExportQueueTableReferences
                                    ._rideIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExportQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExportQueueTable,
      ExportQueueRow,
      $$ExportQueueTableFilterComposer,
      $$ExportQueueTableOrderingComposer,
      $$ExportQueueTableAnnotationComposer,
      $$ExportQueueTableCreateCompanionBuilder,
      $$ExportQueueTableUpdateCompanionBuilder,
      (ExportQueueRow, $$ExportQueueTableReferences),
      ExportQueueRow,
      PrefetchHooks Function({bool rideId})
    >;
typedef $$ScheduledWorkoutsTableCreateCompanionBuilder =
    ScheduledWorkoutsCompanion Function({
      required String id,
      required String workoutId,
      required int date,
      Value<String?> completedRideId,
      Value<String?> notes,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$ScheduledWorkoutsTableUpdateCompanionBuilder =
    ScheduledWorkoutsCompanion Function({
      Value<String> id,
      Value<String> workoutId,
      Value<int> date,
      Value<String?> completedRideId,
      Value<String?> notes,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$ScheduledWorkoutsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ScheduledWorkoutsTable,
          ScheduledWorkoutRow
        > {
  $$ScheduledWorkoutsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias(
        $_aliasNameGenerator(db.scheduledWorkouts.workoutId, db.workouts.id),
      );

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<String>('workout_id')!;

    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RidesTable _completedRideIdTable(_$AppDatabase db) =>
      db.rides.createAlias(
        $_aliasNameGenerator(db.scheduledWorkouts.completedRideId, db.rides.id),
      );

  $$RidesTableProcessedTableManager? get completedRideId {
    final $_column = $_itemColumn<String>('completed_ride_id');
    if ($_column == null) return null;
    final manager = $$RidesTableTableManager(
      $_db,
      $_db.rides,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_completedRideIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScheduledWorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduledWorkoutsTable> {
  $$ScheduledWorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RidesTableFilterComposer get completedRideId {
    final $$RidesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.completedRideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableFilterComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduledWorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduledWorkoutsTable> {
  $$ScheduledWorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RidesTableOrderingComposer get completedRideId {
    final $$RidesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.completedRideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableOrderingComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduledWorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduledWorkoutsTable> {
  $$ScheduledWorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RidesTableAnnotationComposer get completedRideId {
    final $$RidesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.completedRideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableAnnotationComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduledWorkoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduledWorkoutsTable,
          ScheduledWorkoutRow,
          $$ScheduledWorkoutsTableFilterComposer,
          $$ScheduledWorkoutsTableOrderingComposer,
          $$ScheduledWorkoutsTableAnnotationComposer,
          $$ScheduledWorkoutsTableCreateCompanionBuilder,
          $$ScheduledWorkoutsTableUpdateCompanionBuilder,
          (ScheduledWorkoutRow, $$ScheduledWorkoutsTableReferences),
          ScheduledWorkoutRow,
          PrefetchHooks Function({bool workoutId, bool completedRideId})
        > {
  $$ScheduledWorkoutsTableTableManager(
    _$AppDatabase db,
    $ScheduledWorkoutsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduledWorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduledWorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduledWorkoutsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutId = const Value.absent(),
                Value<int> date = const Value.absent(),
                Value<String?> completedRideId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduledWorkoutsCompanion(
                id: id,
                workoutId: workoutId,
                date: date,
                completedRideId: completedRideId,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workoutId,
                required int date,
                Value<String?> completedRideId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ScheduledWorkoutsCompanion.insert(
                id: id,
                workoutId: workoutId,
                date: date,
                completedRideId: completedRideId,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScheduledWorkoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutId = false, completedRideId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workoutId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutId,
                                    referencedTable:
                                        $$ScheduledWorkoutsTableReferences
                                            ._workoutIdTable(db),
                                    referencedColumn:
                                        $$ScheduledWorkoutsTableReferences
                                            ._workoutIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (completedRideId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.completedRideId,
                                    referencedTable:
                                        $$ScheduledWorkoutsTableReferences
                                            ._completedRideIdTable(db),
                                    referencedColumn:
                                        $$ScheduledWorkoutsTableReferences
                                            ._completedRideIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ScheduledWorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduledWorkoutsTable,
      ScheduledWorkoutRow,
      $$ScheduledWorkoutsTableFilterComposer,
      $$ScheduledWorkoutsTableOrderingComposer,
      $$ScheduledWorkoutsTableAnnotationComposer,
      $$ScheduledWorkoutsTableCreateCompanionBuilder,
      $$ScheduledWorkoutsTableUpdateCompanionBuilder,
      (ScheduledWorkoutRow, $$ScheduledWorkoutsTableReferences),
      ScheduledWorkoutRow,
      PrefetchHooks Function({bool workoutId, bool completedRideId})
    >;
typedef $$PersonalRecordsTableCreateCompanionBuilder =
    PersonalRecordsCompanion Function({
      Value<int> id,
      required String rideId,
      required int durationSeconds,
      required double watts,
      required int achievedAt,
    });
typedef $$PersonalRecordsTableUpdateCompanionBuilder =
    PersonalRecordsCompanion Function({
      Value<int> id,
      Value<String> rideId,
      Value<int> durationSeconds,
      Value<double> watts,
      Value<int> achievedAt,
    });

final class $$PersonalRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PersonalRecordsTable,
          PersonalRecordRow
        > {
  $$PersonalRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RidesTable _rideIdTable(_$AppDatabase db) => db.rides.createAlias(
    $_aliasNameGenerator(db.personalRecords.rideId, db.rides.id),
  );

  $$RidesTableProcessedTableManager get rideId {
    final $_column = $_itemColumn<String>('ride_id')!;

    final manager = $$RidesTableTableManager(
      $_db,
      $_db.rides,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rideIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get watts => $composableBuilder(
    column: $table.watts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RidesTableFilterComposer get rideId {
    final $$RidesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableFilterComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get watts => $composableBuilder(
    column: $table.watts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RidesTableOrderingComposer get rideId {
    final $$RidesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableOrderingComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get watts =>
      $composableBuilder(column: $table.watts, builder: (column) => column);

  GeneratedColumn<int> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  $$RidesTableAnnotationComposer get rideId {
    final $$RidesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableAnnotationComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalRecordsTable,
          PersonalRecordRow,
          $$PersonalRecordsTableFilterComposer,
          $$PersonalRecordsTableOrderingComposer,
          $$PersonalRecordsTableAnnotationComposer,
          $$PersonalRecordsTableCreateCompanionBuilder,
          $$PersonalRecordsTableUpdateCompanionBuilder,
          (PersonalRecordRow, $$PersonalRecordsTableReferences),
          PersonalRecordRow,
          PrefetchHooks Function({bool rideId})
        > {
  $$PersonalRecordsTableTableManager(
    _$AppDatabase db,
    $PersonalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rideId = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double> watts = const Value.absent(),
                Value<int> achievedAt = const Value.absent(),
              }) => PersonalRecordsCompanion(
                id: id,
                rideId: rideId,
                durationSeconds: durationSeconds,
                watts: watts,
                achievedAt: achievedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rideId,
                required int durationSeconds,
                required double watts,
                required int achievedAt,
              }) => PersonalRecordsCompanion.insert(
                id: id,
                rideId: rideId,
                durationSeconds: durationSeconds,
                watts: watts,
                achievedAt: achievedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonalRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rideId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (rideId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rideId,
                                referencedTable:
                                    $$PersonalRecordsTableReferences
                                        ._rideIdTable(db),
                                referencedColumn:
                                    $$PersonalRecordsTableReferences
                                        ._rideIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PersonalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalRecordsTable,
      PersonalRecordRow,
      $$PersonalRecordsTableFilterComposer,
      $$PersonalRecordsTableOrderingComposer,
      $$PersonalRecordsTableAnnotationComposer,
      $$PersonalRecordsTableCreateCompanionBuilder,
      $$PersonalRecordsTableUpdateCompanionBuilder,
      (PersonalRecordRow, $$PersonalRecordsTableReferences),
      PersonalRecordRow,
      PrefetchHooks Function({bool rideId})
    >;
typedef $$FtpHistoryTableCreateCompanionBuilder =
    FtpHistoryCompanion Function({
      Value<int> id,
      required int effectiveDate,
      required double ftp,
      Value<String?> source,
    });
typedef $$FtpHistoryTableUpdateCompanionBuilder =
    FtpHistoryCompanion Function({
      Value<int> id,
      Value<int> effectiveDate,
      Value<double> ftp,
      Value<String?> source,
    });

class $$FtpHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $FtpHistoryTable> {
  $$FtpHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ftp => $composableBuilder(
    column: $table.ftp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FtpHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $FtpHistoryTable> {
  $$FtpHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ftp => $composableBuilder(
    column: $table.ftp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FtpHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $FtpHistoryTable> {
  $$FtpHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ftp =>
      $composableBuilder(column: $table.ftp, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$FtpHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FtpHistoryTable,
          FtpHistoryRow,
          $$FtpHistoryTableFilterComposer,
          $$FtpHistoryTableOrderingComposer,
          $$FtpHistoryTableAnnotationComposer,
          $$FtpHistoryTableCreateCompanionBuilder,
          $$FtpHistoryTableUpdateCompanionBuilder,
          (
            FtpHistoryRow,
            BaseReferences<_$AppDatabase, $FtpHistoryTable, FtpHistoryRow>,
          ),
          FtpHistoryRow,
          PrefetchHooks Function()
        > {
  $$FtpHistoryTableTableManager(_$AppDatabase db, $FtpHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FtpHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FtpHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FtpHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> effectiveDate = const Value.absent(),
                Value<double> ftp = const Value.absent(),
                Value<String?> source = const Value.absent(),
              }) => FtpHistoryCompanion(
                id: id,
                effectiveDate: effectiveDate,
                ftp: ftp,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int effectiveDate,
                required double ftp,
                Value<String?> source = const Value.absent(),
              }) => FtpHistoryCompanion.insert(
                id: id,
                effectiveDate: effectiveDate,
                ftp: ftp,
                source: source,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FtpHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FtpHistoryTable,
      FtpHistoryRow,
      $$FtpHistoryTableFilterComposer,
      $$FtpHistoryTableOrderingComposer,
      $$FtpHistoryTableAnnotationComposer,
      $$FtpHistoryTableCreateCompanionBuilder,
      $$FtpHistoryTableUpdateCompanionBuilder,
      (
        FtpHistoryRow,
        BaseReferences<_$AppDatabase, $FtpHistoryTable, FtpHistoryRow>,
      ),
      FtpHistoryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RidesTableTableManager get rides =>
      $$RidesTableTableManager(_db, _db.rides);
  $$SensorReadingsTableTableManager get sensorReadings =>
      $$SensorReadingsTableTableManager(_db, _db.sensorReadings);
  $$LapsTableTableManager get laps => $$LapsTableTableManager(_db, _db.laps);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$WorkoutStepsTableTableManager get workoutSteps =>
      $$WorkoutStepsTableTableManager(_db, _db.workoutSteps);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$ExportQueueTableTableManager get exportQueue =>
      $$ExportQueueTableTableManager(_db, _db.exportQueue);
  $$ScheduledWorkoutsTableTableManager get scheduledWorkouts =>
      $$ScheduledWorkoutsTableTableManager(_db, _db.scheduledWorkouts);
  $$PersonalRecordsTableTableManager get personalRecords =>
      $$PersonalRecordsTableTableManager(_db, _db.personalRecords);
  $$FtpHistoryTableTableManager get ftpHistory =>
      $$FtpHistoryTableTableManager(_db, _db.ftpHistory);
}
