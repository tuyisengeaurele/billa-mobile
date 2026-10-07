// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notifications_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationsPage _$NotificationsPageFromJson(Map<String, dynamic> json) {
  return _NotificationsPage.fromJson(json);
}

/// @nodoc
mixin _$NotificationsPage {
  List<AppNotification> get results => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationsPageCopyWith<NotificationsPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationsPageCopyWith<$Res> {
  factory $NotificationsPageCopyWith(
          NotificationsPage value, $Res Function(NotificationsPage) then) =
      _$NotificationsPageCopyWithImpl<$Res, NotificationsPage>;
  @useResult
  $Res call({List<AppNotification> results, int unreadCount});
}

/// @nodoc
class _$NotificationsPageCopyWithImpl<$Res, $Val extends NotificationsPage>
    implements $NotificationsPageCopyWith<$Res> {
  _$NotificationsPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? results = null,
    Object? unreadCount = null,
  }) {
    return _then(_value.copyWith(
      results: null == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<AppNotification>,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationsPageImplCopyWith<$Res>
    implements $NotificationsPageCopyWith<$Res> {
  factory _$$NotificationsPageImplCopyWith(_$NotificationsPageImpl value,
          $Res Function(_$NotificationsPageImpl) then) =
      __$$NotificationsPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<AppNotification> results, int unreadCount});
}

/// @nodoc
class __$$NotificationsPageImplCopyWithImpl<$Res>
    extends _$NotificationsPageCopyWithImpl<$Res, _$NotificationsPageImpl>
    implements _$$NotificationsPageImplCopyWith<$Res> {
  __$$NotificationsPageImplCopyWithImpl(_$NotificationsPageImpl _value,
      $Res Function(_$NotificationsPageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? results = null,
    Object? unreadCount = null,
  }) {
    return _then(_$NotificationsPageImpl(
      results: null == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<AppNotification>,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationsPageImpl implements _NotificationsPage {
  const _$NotificationsPageImpl(
      {required final List<AppNotification> results, required this.unreadCount})
      : _results = results;

  factory _$NotificationsPageImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationsPageImplFromJson(json);

  final List<AppNotification> _results;
  @override
  List<AppNotification> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  final int unreadCount;

  @override
  String toString() {
    return 'NotificationsPage(results: $results, unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationsPageImpl &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_results), unreadCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationsPageImplCopyWith<_$NotificationsPageImpl> get copyWith =>
      __$$NotificationsPageImplCopyWithImpl<_$NotificationsPageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationsPageImplToJson(
      this,
    );
  }
}

abstract class _NotificationsPage implements NotificationsPage {
  const factory _NotificationsPage(
      {required final List<AppNotification> results,
      required final int unreadCount}) = _$NotificationsPageImpl;

  factory _NotificationsPage.fromJson(Map<String, dynamic> json) =
      _$NotificationsPageImpl.fromJson;

  @override
  List<AppNotification> get results;
  @override
  int get unreadCount;
  @override
  @JsonKey(ignore: true)
  _$$NotificationsPageImplCopyWith<_$NotificationsPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
