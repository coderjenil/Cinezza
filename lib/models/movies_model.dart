// To parse this JSON data, do
//
//     final moviesModel = moviesModelFromJson(jsonString);

import 'dart:convert';

MoviesModel moviesModelFromJson(String str) =>
    MoviesModel.fromJson(json.decode(str));

String moviesModelToJson(MoviesModel data) => json.encode(data.toJson());

class MoviesModel {
  bool? success;
  String? message;
  List<Movie>? data;
  Pagination? pagination;

  MoviesModel({this.success, this.message, this.data, this.pagination});

  factory MoviesModel.fromJson(Map<String, dynamic> json) => MoviesModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null
        ? []
        : List<Movie>.from(json["data"]!.map((x) => Movie.fromJson(x))),
    pagination: json["pagination"] == null
        ? null
        : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Movie {
  String? id;
  String? uniqueId;
  String? movieName;
  String? description;
  List<String>? categories;
  String? category;
  int? subscription;
  String? thumbUrl;
  String? thumbUrl2;
  String? videoUrl;
  List<Season>? seasons;
  int? duration;
  int? rating;
  int? views;
  int? likes;
  bool? isActive;
  bool? isFeatured;
  String? createdAt;
  String? updatedAt;

  Movie({
    this.id,
    this.uniqueId,
    this.movieName,
    this.description,
    this.categories,
    this.category,
    this.subscription,
    this.thumbUrl,
    this.thumbUrl2,
    this.videoUrl,
    this.seasons,
    this.duration,
    this.rating,
    this.views,
    this.likes,
    this.isActive,
    this.isFeatured,
    this.createdAt,
    this.updatedAt,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
    id: json["_id"],
    uniqueId: json["unique_id"],
    movieName: json["movie_name"],
    description: json["description"],
    categories: json["categories"] == null
        ? []
        : List<String>.from(json["categories"]!.map((x) => x)),
    category: json["category"],
    subscription: json["subscription"],
    thumbUrl: json["thumb_url"],
    thumbUrl2: json["thumb_url2"],
    videoUrl: json["video_url"],
    seasons: json["seasons"] == null
        ? []
        : List<Season>.from(json["seasons"]!.map((x) => Season.fromJson(x))),
    duration: json["duration"],
    rating: json["rating"],
    views: json["views"],
    likes: json["likes"],
    isActive: json["is_active"],
    isFeatured: json["is_featured"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "unique_id": uniqueId,
    "movie_name": movieName,
    "description": description,
    "categories": categories == null
        ? []
        : List<dynamic>.from(categories!.map((x) => x)),
    "category": category,
    "subscription": subscription,
    "thumb_url": thumbUrl,
    "thumb_url2": thumbUrl2,
    "video_url": videoUrl,
    "seasons": seasons == null
        ? []
        : List<dynamic>.from(seasons!.map((x) => x.toJson())),
    "duration": duration,
    "rating": rating,
    "views": views,
    "likes": likes,
    "is_active": isActive,
    "is_featured": isFeatured,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class Season {
  int? seasonNo;
  String? seasonName;
  String? thumbUrl;
  List<Episode>? episodes;

  Season({this.seasonNo, this.seasonName, this.thumbUrl, this.episodes});

  factory Season.fromJson(Map<String, dynamic> json) => Season(
    seasonNo: json["season_no"],
    seasonName: json["season_name"],
    thumbUrl: json["thumb_url"],
    episodes: json["episodes"] == null
        ? []
        : List<Episode>.from(json["episodes"]!.map((x) => Episode.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "season_no": seasonNo,
    "season_name": seasonName,
    "thumb_url": thumbUrl,
    "episodes": episodes == null
        ? []
        : List<dynamic>.from(episodes!.map((x) => x.toJson())),
  };
}

class Episode {
  int? episodeNo;
  String? episodeName;
  int? subscription;
  String? thumbUrl;
  String? videoUrl;
  int? duration;
  int? views;

  Episode({
    this.episodeNo,
    this.episodeName,
    this.subscription,
    this.thumbUrl,
    this.videoUrl,
    this.duration,
    this.views,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
    episodeNo: json["episode_no"],
    episodeName: json["episode_name"],
    subscription: json["subscription"],
    thumbUrl: json["thumb_url"],
    videoUrl: json["video_url"],
    duration: json["duration"],
    views: json["views"],
  );

  Map<String, dynamic> toJson() => {
    "episode_no": episodeNo,
    "episode_name": episodeName,
    "subscription": subscription,
    "thumb_url": thumbUrl,
    "video_url": videoUrl,
    "duration": duration,
    "views": views,
  };
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalItems;
  int? itemsPerPage;
  bool? hasNextPage;
  bool? hasPreviousPage;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalItems,
    this.itemsPerPage,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["currentPage"],
    totalPages: json["totalPages"],
    totalItems: json["totalItems"],
    itemsPerPage: json["itemsPerPage"],
    hasNextPage: json["hasNextPage"],
    hasPreviousPage: json["hasPreviousPage"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "totalPages": totalPages,
    "totalItems": totalItems,
    "itemsPerPage": itemsPerPage,
    "hasNextPage": hasNextPage,
    "hasPreviousPage": hasPreviousPage,
  };
}
