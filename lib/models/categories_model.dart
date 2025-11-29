// To parse this JSON data, do
//
//     final categoriesModel = categoriesModelFromJson(jsonString);

import 'dart:convert';

CategoriesModel categoriesModelFromJson(String str) =>
    CategoriesModel.fromJson(json.decode(str));

String categoriesModelToJson(CategoriesModel data) =>
    json.encode(data.toJson());

class CategoriesModel {
  bool? success;
  String? message;
  List<CategoryModel>? data;

  CategoriesModel({this.success, this.message, this.data});

  factory CategoriesModel.fromJson(Map<String, dynamic> json) =>
      CategoriesModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<CategoryModel>.from(
                json["data"]!.map((x) => CategoryModel.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class CategoryModel {
  String? id;
  String? categoryId;
  String? name;
  String? description;
  int? index;
  bool? isActive;
  bool? isAdult;
  bool? isLandScape;
  String? iconUrl;
  String? color;
  String? createdAt;
  String? updatedAt;

  CategoryModel({
    this.id,
    this.categoryId,
    this.name,
    this.description,
    this.index,
    this.isActive,
    this.isAdult,
    this.isLandScape,
    this.iconUrl,
    this.color,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json["_id"],
    categoryId: json["id"],
    name: json["name"],
    description: json["description"],
    index: json["index"],
    isActive: json["isActive"],
    isAdult: json["isAdult"],
    isLandScape: json["isLandScape"],
    iconUrl: json["icon_url"],
    color: json["color"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "id": categoryId,
    "name": name,
    "description": description,
    "index": index,
    "isActive": isActive,
    "isAdult": isAdult,
    "isLandScape": isLandScape,
    "icon_url": iconUrl,
    "color": color,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
