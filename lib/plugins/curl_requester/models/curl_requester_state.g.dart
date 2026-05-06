// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curl_requester_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurlRequesterState _$CurlRequesterStateFromJson(Map<String, dynamic> json) =>
    _CurlRequesterState(
      currentCommand: json['currentCommand'] == null
          ? const CurlCommand()
          : CurlCommand.fromJson(
              json['currentCommand'] as Map<String, dynamic>,
            ),
      history:
          (json['history'] as List<dynamic>?)
              ?.map((e) => CurlTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isLoading: json['isLoading'] as bool? ?? false,
      lastError: json['lastError'] as String?,
    );

Map<String, dynamic> _$CurlRequesterStateToJson(_CurlRequesterState instance) =>
    <String, dynamic>{
      'currentCommand': instance.currentCommand,
      'history': instance.history,
      'isLoading': instance.isLoading,
      'lastError': instance.lastError,
    };
