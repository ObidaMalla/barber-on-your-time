// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_completion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestCompletionModel _$RequestCompletionModelFromJson(
  Map<String, dynamic> json,
) => RequestCompletionModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'],
);

Map<String, dynamic> _$RequestCompletionModelToJson(
  RequestCompletionModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};
