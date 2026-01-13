// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  bool success;
  String message;
  User user;

  UserModel({required this.success, required this.message, required this.user});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    success: json["success"],
    message: json["message"],
    user: User.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": user.toJson(),
  };
}

class User {
  String id;
  String deviceId;
  String userId;
  bool planActive;
  dynamic activePlan;
  String? planExpiryDate;
  int trialCount;
  int reelsUsage;
  DateTime lastActive;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.id,
    required this.deviceId,
    required this.userId,
    required this.planActive,
    required this.activePlan,
    required this.planExpiryDate,
    required this.trialCount,
    required this.reelsUsage,
    required this.lastActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    deviceId: json["device_id"],
    userId: json["user_id"],
    planActive: json["plan_active"],
    activePlan: json["active_plan"],
    planExpiryDate: json["plan_expiry_date"],
    trialCount: json["trial_count"],
    reelsUsage: json["reelsUsage"],
    lastActive: DateTime.parse(json["last_active"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "device_id": deviceId,
    "user_id": userId,
    "plan_active": planActive,
    "active_plan": activePlan,
    "plan_expiry_date": planExpiryDate,
    "trial_count": trialCount,
    "reelsUsage": reelsUsage,
    "last_active": lastActive.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
