import 'package:json_annotation/json_annotation.dart';

part 'get_all_businesses_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GetAllBusinessesModel {
  bool? success;
  int? statusCode;
  String? message;
  List<BusinessData>? data;

  GetAllBusinessesModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory GetAllBusinessesModel.fromJson(Map<String, dynamic> json) =>
      _$GetAllBusinessesModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetAllBusinessesModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BusinessData {
  int? id;
  String? name;
  String? address;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? createdAt;

  BusinessOwner? owner;

  BusinessData({this.id, this.name, this.address, this.createdAt, this.owner});

  factory BusinessData.fromJson(Map<String, dynamic> json) =>
      _$BusinessDataFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessDataToJson(this);

  static DateTime? _dateTimeFromJson(String? date) =>
      date != null ? DateTime.tryParse(date) : null;

  static String? _dateTimeToJson(DateTime? date) => date?.toIso8601String();
}

@JsonSerializable()
class BusinessOwner {
  int? id;
  String? name;
  String? email;

  BusinessOwner({this.id, this.name, this.email});

  factory BusinessOwner.fromJson(Map<String, dynamic> json) =>
      _$BusinessOwnerFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessOwnerToJson(this);
}
