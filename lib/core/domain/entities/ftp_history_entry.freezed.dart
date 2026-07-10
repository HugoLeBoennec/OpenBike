// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ftp_history_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FtpHistoryEntry {
  DateTime get effectiveDate => throw _privateConstructorUsedError;
  Watts get ftp => throw _privateConstructorUsedError;

  /// Create a copy of FtpHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FtpHistoryEntryCopyWith<FtpHistoryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FtpHistoryEntryCopyWith<$Res> {
  factory $FtpHistoryEntryCopyWith(
    FtpHistoryEntry value,
    $Res Function(FtpHistoryEntry) then,
  ) = _$FtpHistoryEntryCopyWithImpl<$Res, FtpHistoryEntry>;
  @useResult
  $Res call({DateTime effectiveDate, Watts ftp});

  $WattsCopyWith<$Res> get ftp;
}

/// @nodoc
class _$FtpHistoryEntryCopyWithImpl<$Res, $Val extends FtpHistoryEntry>
    implements $FtpHistoryEntryCopyWith<$Res> {
  _$FtpHistoryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FtpHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? effectiveDate = null, Object? ftp = null}) {
    return _then(
      _value.copyWith(
            effectiveDate: null == effectiveDate
                ? _value.effectiveDate
                : effectiveDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            ftp: null == ftp
                ? _value.ftp
                : ftp // ignore: cast_nullable_to_non_nullable
                      as Watts,
          )
          as $Val,
    );
  }

  /// Create a copy of FtpHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WattsCopyWith<$Res> get ftp {
    return $WattsCopyWith<$Res>(_value.ftp, (value) {
      return _then(_value.copyWith(ftp: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FtpHistoryEntryImplCopyWith<$Res>
    implements $FtpHistoryEntryCopyWith<$Res> {
  factory _$$FtpHistoryEntryImplCopyWith(
    _$FtpHistoryEntryImpl value,
    $Res Function(_$FtpHistoryEntryImpl) then,
  ) = __$$FtpHistoryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime effectiveDate, Watts ftp});

  @override
  $WattsCopyWith<$Res> get ftp;
}

/// @nodoc
class __$$FtpHistoryEntryImplCopyWithImpl<$Res>
    extends _$FtpHistoryEntryCopyWithImpl<$Res, _$FtpHistoryEntryImpl>
    implements _$$FtpHistoryEntryImplCopyWith<$Res> {
  __$$FtpHistoryEntryImplCopyWithImpl(
    _$FtpHistoryEntryImpl _value,
    $Res Function(_$FtpHistoryEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FtpHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? effectiveDate = null, Object? ftp = null}) {
    return _then(
      _$FtpHistoryEntryImpl(
        effectiveDate: null == effectiveDate
            ? _value.effectiveDate
            : effectiveDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        ftp: null == ftp
            ? _value.ftp
            : ftp // ignore: cast_nullable_to_non_nullable
                  as Watts,
      ),
    );
  }
}

/// @nodoc

class _$FtpHistoryEntryImpl implements _FtpHistoryEntry {
  const _$FtpHistoryEntryImpl({required this.effectiveDate, required this.ftp});

  @override
  final DateTime effectiveDate;
  @override
  final Watts ftp;

  @override
  String toString() {
    return 'FtpHistoryEntry(effectiveDate: $effectiveDate, ftp: $ftp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FtpHistoryEntryImpl &&
            (identical(other.effectiveDate, effectiveDate) ||
                other.effectiveDate == effectiveDate) &&
            (identical(other.ftp, ftp) || other.ftp == ftp));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effectiveDate, ftp);

  /// Create a copy of FtpHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FtpHistoryEntryImplCopyWith<_$FtpHistoryEntryImpl> get copyWith =>
      __$$FtpHistoryEntryImplCopyWithImpl<_$FtpHistoryEntryImpl>(
        this,
        _$identity,
      );
}

abstract class _FtpHistoryEntry implements FtpHistoryEntry {
  const factory _FtpHistoryEntry({
    required final DateTime effectiveDate,
    required final Watts ftp,
  }) = _$FtpHistoryEntryImpl;

  @override
  DateTime get effectiveDate;
  @override
  Watts get ftp;

  /// Create a copy of FtpHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FtpHistoryEntryImplCopyWith<_$FtpHistoryEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
