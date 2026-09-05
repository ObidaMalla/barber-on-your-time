import 'package:json_annotation/json_annotation.dart';

part 'delete_staff_model.g.dart';

@JsonSerializable()
class DeleteStaffModel {
  bool? success;
  int? statusCode;
  String? message;

  DeleteStaffModel({this.success, this.statusCode, this.message});

  factory DeleteStaffModel.fromJson(Map<String, dynamic> json) =>
      _$DeleteStaffModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteStaffModelToJson(this);
}
