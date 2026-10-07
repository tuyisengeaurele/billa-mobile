// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ActivityActor _$ActivityActorFromJson(Map<String, dynamic> json) {
  return _ActivityActor.fromJson(json);
}

/// @nodoc
mixin _$ActivityActor {
  String? get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ActivityActorCopyWith<ActivityActor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityActorCopyWith<$Res> {
  factory $ActivityActorCopyWith(
          ActivityActor value, $Res Function(ActivityActor) then) =
      _$ActivityActorCopyWithImpl<$Res, ActivityActor>;
  @useResult
  $Res call({String? name, String? email});
}

/// @nodoc
class _$ActivityActorCopyWithImpl<$Res, $Val extends ActivityActor>
    implements $ActivityActorCopyWith<$Res> {
  _$ActivityActorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? email = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityActorImplCopyWith<$Res>
    implements $ActivityActorCopyWith<$Res> {
  factory _$$ActivityActorImplCopyWith(
          _$ActivityActorImpl value, $Res Function(_$ActivityActorImpl) then) =
      __$$ActivityActorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? name, String? email});
}

/// @nodoc
class __$$ActivityActorImplCopyWithImpl<$Res>
    extends _$ActivityActorCopyWithImpl<$Res, _$ActivityActorImpl>
    implements _$$ActivityActorImplCopyWith<$Res> {
  __$$ActivityActorImplCopyWithImpl(
      _$ActivityActorImpl _value, $Res Function(_$ActivityActorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? email = freezed,
  }) {
    return _then(_$ActivityActorImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityActorImpl implements _ActivityActor {
  const _$ActivityActorImpl({this.name, this.email});

  factory _$ActivityActorImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityActorImplFromJson(json);

  @override
  final String? name;
  @override
  final String? email;

  @override
  String toString() {
    return 'ActivityActor(name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityActorImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, email);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityActorImplCopyWith<_$ActivityActorImpl> get copyWith =>
      __$$ActivityActorImplCopyWithImpl<_$ActivityActorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityActorImplToJson(
      this,
    );
  }
}

abstract class _ActivityActor implements ActivityActor {
  const factory _ActivityActor({final String? name, final String? email}) =
      _$ActivityActorImpl;

  factory _ActivityActor.fromJson(Map<String, dynamic> json) =
      _$ActivityActorImpl.fromJson;

  @override
  String? get name;
  @override
  String? get email;
  @override
  @JsonKey(ignore: true)
  _$$ActivityActorImplCopyWith<_$ActivityActorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActivityEntry _$ActivityEntryFromJson(Map<String, dynamic> json) {
  return _ActivityEntry.fromJson(json);
}

/// @nodoc
mixin _$ActivityEntry {
  String get id => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;
  String? get entityType => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  ActivityActor? get actor => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ActivityEntryCopyWith<ActivityEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityEntryCopyWith<$Res> {
  factory $ActivityEntryCopyWith(
          ActivityEntry value, $Res Function(ActivityEntry) then) =
      _$ActivityEntryCopyWithImpl<$Res, ActivityEntry>;
  @useResult
  $Res call(
      {String id,
      String action,
      String? entityType,
      Map<String, dynamic>? metadata,
      String createdAt,
      ActivityActor? actor});

  $ActivityActorCopyWith<$Res>? get actor;
}

/// @nodoc
class _$ActivityEntryCopyWithImpl<$Res, $Val extends ActivityEntry>
    implements $ActivityEntryCopyWith<$Res> {
  _$ActivityEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? action = null,
    Object? entityType = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? actor = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      entityType: freezed == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      actor: freezed == actor
          ? _value.actor
          : actor // ignore: cast_nullable_to_non_nullable
              as ActivityActor?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ActivityActorCopyWith<$Res>? get actor {
    if (_value.actor == null) {
      return null;
    }

    return $ActivityActorCopyWith<$Res>(_value.actor!, (value) {
      return _then(_value.copyWith(actor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ActivityEntryImplCopyWith<$Res>
    implements $ActivityEntryCopyWith<$Res> {
  factory _$$ActivityEntryImplCopyWith(
          _$ActivityEntryImpl value, $Res Function(_$ActivityEntryImpl) then) =
      __$$ActivityEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String action,
      String? entityType,
      Map<String, dynamic>? metadata,
      String createdAt,
      ActivityActor? actor});

  @override
  $ActivityActorCopyWith<$Res>? get actor;
}

/// @nodoc
class __$$ActivityEntryImplCopyWithImpl<$Res>
    extends _$ActivityEntryCopyWithImpl<$Res, _$ActivityEntryImpl>
    implements _$$ActivityEntryImplCopyWith<$Res> {
  __$$ActivityEntryImplCopyWithImpl(
      _$ActivityEntryImpl _value, $Res Function(_$ActivityEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? action = null,
    Object? entityType = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? actor = freezed,
  }) {
    return _then(_$ActivityEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      entityType: freezed == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      actor: freezed == actor
          ? _value.actor
          : actor // ignore: cast_nullable_to_non_nullable
              as ActivityActor?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityEntryImpl implements _ActivityEntry {
  const _$ActivityEntryImpl(
      {required this.id,
      required this.action,
      this.entityType,
      final Map<String, dynamic>? metadata,
      required this.createdAt,
      this.actor})
      : _metadata = metadata;

  factory _$ActivityEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String action;
  @override
  final String? entityType;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String createdAt;
  @override
  final ActivityActor? actor;

  @override
  String toString() {
    return 'ActivityEntry(id: $id, action: $action, entityType: $entityType, metadata: $metadata, createdAt: $createdAt, actor: $actor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.entityType, entityType) ||
                other.entityType == entityType) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.actor, actor) || other.actor == actor));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, action, entityType,
      const DeepCollectionEquality().hash(_metadata), createdAt, actor);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityEntryImplCopyWith<_$ActivityEntryImpl> get copyWith =>
      __$$ActivityEntryImplCopyWithImpl<_$ActivityEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityEntryImplToJson(
      this,
    );
  }
}

abstract class _ActivityEntry implements ActivityEntry {
  const factory _ActivityEntry(
      {required final String id,
      required final String action,
      final String? entityType,
      final Map<String, dynamic>? metadata,
      required final String createdAt,
      final ActivityActor? actor}) = _$ActivityEntryImpl;

  factory _ActivityEntry.fromJson(Map<String, dynamic> json) =
      _$ActivityEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get action;
  @override
  String? get entityType;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String get createdAt;
  @override
  ActivityActor? get actor;
  @override
  @JsonKey(ignore: true)
  _$$ActivityEntryImplCopyWith<_$ActivityEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
