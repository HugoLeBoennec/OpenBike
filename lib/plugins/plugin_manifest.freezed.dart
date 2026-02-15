// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plugin_manifest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$PluginManifest {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;
  PluginType get type => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get capabilities => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PluginManifestCopyWith<PluginManifest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PluginManifestCopyWith<$Res> {
  factory $PluginManifestCopyWith(
          PluginManifest value, $Res Function(PluginManifest) then) =
      _$PluginManifestCopyWithImpl<$Res, PluginManifest>;
  @useResult
  $Res call(
      {String id,
      String name,
      String version,
      PluginType type,
      String author,
      String description,
      List<String> capabilities});
}

/// @nodoc
class _$PluginManifestCopyWithImpl<$Res, $Val extends PluginManifest>
    implements $PluginManifestCopyWith<$Res> {
  _$PluginManifestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? version = null,
    Object? type = null,
    Object? author = null,
    Object? description = null,
    Object? capabilities = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PluginType,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      capabilities: null == capabilities
          ? _value.capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PluginManifestCopyWith<$Res>
    implements $PluginManifestCopyWith<$Res> {
  factory _$$_PluginManifestCopyWith(
          _$_PluginManifest value, $Res Function(_$_PluginManifest) then) =
      __$$_PluginManifestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String version,
      PluginType type,
      String author,
      String description,
      List<String> capabilities});
}

/// @nodoc
class __$$_PluginManifestCopyWithImpl<$Res>
    extends _$PluginManifestCopyWithImpl<$Res, _$_PluginManifest>
    implements _$$_PluginManifestCopyWith<$Res> {
  __$$_PluginManifestCopyWithImpl(
      _$_PluginManifest _value, $Res Function(_$_PluginManifest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? version = null,
    Object? type = null,
    Object? author = null,
    Object? description = null,
    Object? capabilities = null,
  }) {
    return _then(_$_PluginManifest(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PluginType,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      capabilities: null == capabilities
          ? _value._capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$_PluginManifest implements _PluginManifest {
  const _$_PluginManifest(
      {required this.id,
      required this.name,
      required this.version,
      required this.type,
      this.author = '',
      this.description = '',
      final List<String> capabilities = const []})
      : _capabilities = capabilities;

  @override
  final String id;
  @override
  final String name;
  @override
  final String version;
  @override
  final PluginType type;
  @override
  @JsonKey()
  final String author;
  @override
  @JsonKey()
  final String description;
  final List<String> _capabilities;
  @override
  @JsonKey()
  List<String> get capabilities {
    if (_capabilities is EqualUnmodifiableListView) return _capabilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_capabilities);
  }

  @override
  String toString() {
    return 'PluginManifest(id: $id, name: $name, version: $version, type: $type, author: $author, description: $description, capabilities: $capabilities)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PluginManifest &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._capabilities, _capabilities));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, version, type, author,
      description, const DeepCollectionEquality().hash(_capabilities));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PluginManifestCopyWith<_$_PluginManifest> get copyWith =>
      __$$_PluginManifestCopyWithImpl<_$_PluginManifest>(this, _$identity);
}

abstract class _PluginManifest implements PluginManifest {
  const factory _PluginManifest(
      {required final String id,
      required final String name,
      required final String version,
      required final PluginType type,
      final String author,
      final String description,
      final List<String> capabilities}) = _$_PluginManifest;

  @override
  String get id;
  @override
  String get name;
  @override
  String get version;
  @override
  PluginType get type;
  @override
  String get author;
  @override
  String get description;
  @override
  List<String> get capabilities;
  @override
  @JsonKey(ignore: true)
  _$$_PluginManifestCopyWith<_$_PluginManifest> get copyWith =>
      throw _privateConstructorUsedError;
}
