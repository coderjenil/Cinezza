// To parse this JSON data, do
//
//     final premiumPlanModel = premiumPlanModelFromJson(jsonString);

import 'dart:convert';

PremiumPlanModel premiumPlanModelFromJson(String str) =>
    PremiumPlanModel.fromJson(json.decode(str));

String premiumPlanModelToJson(PremiumPlanModel data) =>
    json.encode(data.toJson());

class PremiumPlanModel {
  bool success;
  String message;
  List<PlanModel> plan;

  PremiumPlanModel({
    required this.success,
    required this.message,
    required this.plan,
  });

  factory PremiumPlanModel.fromJson(Map<String, dynamic> json) =>
      PremiumPlanModel(
        success: json["success"],
        message: json["message"],
        plan: List<PlanModel>.from(
          json["data"].map((x) => PlanModel.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(plan.map((x) => x.toJson())),
  };
}

class PlanModel {
  String id;
  String planId;
  String title;
  String description;
  int price;
  String currency;
  int durationInDays;
  bool isMostPopular;
  bool isActive;
  int displayOrder;
  List<dynamic> features;
  int discountPercent;
  dynamic originalPrice;
  String color;
  int totalPurchases;
  int revenue;
  DateTime createdAt;
  DateTime updatedAt;

  PlanModel({
    required this.id,
    required this.planId,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.durationInDays,
    required this.isMostPopular,
    required this.isActive,
    required this.displayOrder,
    required this.features,
    required this.discountPercent,
    required this.originalPrice,
    required this.color,
    required this.totalPurchases,
    required this.revenue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
    id: json["_id"],
    planId: json["id"],
    title: json["title"],
    description: json["description"],
    price: json["price"],
    currency: json["currency"],
    durationInDays: json["durationInDays"],
    isMostPopular: json["isMostPopular"],
    isActive: json["isActive"],
    displayOrder: json["displayOrder"],
    features: List<dynamic>.from(json["features"].map((x) => x)),
    discountPercent: json["discountPercent"],
    originalPrice: json["originalPrice"],
    color: json["color"],
    totalPurchases: json["totalPurchases"],
    revenue: json["revenue"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "id": planId,
    "title": title,
    "description": description,
    "price": price,
    "currency": currency,
    "durationInDays": durationInDays,
    "isMostPopular": isMostPopular,
    "isActive": isActive,
    "displayOrder": displayOrder,
    "features": List<dynamic>.from(features.map((x) => x)),
    "discountPercent": discountPercent,
    "originalPrice": originalPrice,
    "color": color,
    "totalPurchases": totalPurchases,
    "revenue": revenue,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
