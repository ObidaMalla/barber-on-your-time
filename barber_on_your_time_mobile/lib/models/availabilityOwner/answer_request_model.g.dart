// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnswerRequestBody _$AnswerRequestBodyFromJson(Map<String, dynamic> json) =>
    AnswerRequestBody(decision: json['decision'] as String);

Map<String, dynamic> _$AnswerRequestBodyToJson(AnswerRequestBody instance) =>
    <String, dynamic>{'decision': instance.decision};

AnswerRequestModel _$AnswerRequestModelFromJson(Map<String, dynamic> json) =>
    AnswerRequestModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : OwnerPendingRequestData.fromJson(
              json['data'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AnswerRequestModelToJson(AnswerRequestModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };
