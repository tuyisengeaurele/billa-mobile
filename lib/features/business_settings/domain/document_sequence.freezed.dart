// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_sequence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DocumentSequence _$DocumentSequenceFromJson(Map<String, dynamic> json) {
  return _DocumentSequence.fromJson(json);
}

/// @nodoc
mixin _$DocumentSequence {
  @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
  DocumentType get type => throw _privateConstructorUsedError;
  String get prefix => throw _privateConstructorUsedError;
  int get nextNumber => throw _privateConstructorUsedError;
  bool get resetYearly => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentSequenceCopyWith<DocumentSequence> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentSequenceCopyWith<$Res> {
  factory $DocumentSequenceCopyWith(
          DocumentSequence value, $Res Function(DocumentSequence) then) =
      _$DocumentSequenceCopyWithImpl<$Res, DocumentSequence>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      DocumentType type,
      String prefix,
      int nextNumber,
      bool resetYearly});
}

/// @nodoc
class _$DocumentSequenceCopyWithImpl<$Res, $Val extends DocumentSequence>
    implements $DocumentSequenceCopyWith<$Res> {
  _$DocumentSequenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? prefix = null,
    Object? nextNumber = null,
    Object? resetYearly = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DocumentType,
      prefix: null == prefix
          ? _value.prefix
          : prefix // ignore: cast_nullable_to_non_nullable
              as String,
      nextNumber: null == nextNumber
          ? _value.nextNumber
          : nextNumber // ignore: cast_nullable_to_non_nullable
              as int,
      resetYearly: null == resetYearly
          ? _value.resetYearly
          : resetYearly // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentSequenceImplCopyWith<$Res>
    implements $DocumentSequenceCopyWith<$Res> {
  factory _$$DocumentSequenceImplCopyWith(_$DocumentSequenceImpl value,
          $Res Function(_$DocumentSequenceImpl) then) =
      __$$DocumentSequenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      DocumentType type,
      String prefix,
      int nextNumber,
      bool resetYearly});
}

/// @nodoc
class __$$DocumentSequenceImplCopyWithImpl<$Res>
    extends _$DocumentSequenceCopyWithImpl<$Res, _$DocumentSequenceImpl>
    implements _$$DocumentSequenceImplCopyWith<$Res> {
  __$$DocumentSequenceImplCopyWithImpl(_$DocumentSequenceImpl _value,
      $Res Function(_$DocumentSequenceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? prefix = null,
    Object? nextNumber = null,
    Object? resetYearly = null,
  }) {
    return _then(_$DocumentSequenceImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DocumentType,
      prefix: null == prefix
          ? _value.prefix
          : prefix // ignore: cast_nullable_to_non_nullable
              as String,
      nextNumber: null == nextNumber
          ? _value.nextNumber
          : nextNumber // ignore: cast_nullable_to_non_nullable
              as int,
      resetYearly: null == resetYearly
          ? _value.resetYearly
          : resetYearly // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentSequenceImpl implements _DocumentSequence {
  const _$DocumentSequenceImpl(
      {@JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      required this.type,
      required this.prefix,
      required this.nextNumber,
      required this.resetYearly});

  factory _$DocumentSequenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentSequenceImplFromJson(json);

  @override
  @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
  final DocumentType type;
  @override
  final String prefix;
  @override
  final int nextNumber;
  @override
  final bool resetYearly;

  @override
  String toString() {
    return 'DocumentSequence(type: $type, prefix: $prefix, nextNumber: $nextNumber, resetYearly: $resetYearly)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentSequenceImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.prefix, prefix) || other.prefix == prefix) &&
            (identical(other.nextNumber, nextNumber) ||
                other.nextNumber == nextNumber) &&
            (identical(other.resetYearly, resetYearly) ||
                other.resetYearly == resetYearly));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, prefix, nextNumber, resetYearly);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentSequenceImplCopyWith<_$DocumentSequenceImpl> get copyWith =>
      __$$DocumentSequenceImplCopyWithImpl<_$DocumentSequenceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentSequenceImplToJson(
      this,
    );
  }
}

abstract class _DocumentSequence implements DocumentSequence {
  const factory _DocumentSequence(
      {@JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
      required final DocumentType type,
      required final String prefix,
      required final int nextNumber,
      required final bool resetYearly}) = _$DocumentSequenceImpl;

  factory _DocumentSequence.fromJson(Map<String, dynamic> json) =
      _$DocumentSequenceImpl.fromJson;

  @override
  @JsonKey(fromJson: documentTypeFromJson, toJson: documentTypeToJson)
  DocumentType get type;
  @override
  String get prefix;
  @override
  int get nextNumber;
  @override
  bool get resetYearly;
  @override
  @JsonKey(ignore: true)
  _$$DocumentSequenceImplCopyWith<_$DocumentSequenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
