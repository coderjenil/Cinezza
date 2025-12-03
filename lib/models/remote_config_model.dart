// remote_config_model.dart

import 'dart:convert';

RemoteConfigModel remoteConfigModelFromJson(String str) =>
    RemoteConfigModel.fromJson(json.decode(str));

String remoteConfigModelToJson(RemoteConfigModel data) =>
    json.encode(data.toJson());

class RemoteConfigModel {
  bool? success;
  String? message;
  Config? config;

  RemoteConfigModel({this.success, this.message, this.config});

  factory RemoteConfigModel.fromJson(Map<String, dynamic> json) =>
      RemoteConfigModel(
        success: json["success"],
        message: json["message"],
        config: json["data"] == null ? null : Config.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": config?.toJson(),
  };
}

class Config {
  int? defaultTrialCount;
  int? defaultReelsUsageLimit;
  bool? enableTrial;
  bool? isAdEnable;
  String? appVersion;
  bool? maintenanceMode;
  Reels? reels;
  AdIds? adIds;

  Config({
    this.defaultTrialCount,
    this.defaultReelsUsageLimit,
    this.enableTrial,
    this.isAdEnable,
    this.appVersion,
    this.maintenanceMode,
    this.reels,
    this.adIds,
  });

  factory Config.fromJson(Map<String, dynamic> json) => Config(
    defaultTrialCount: json["default_trial_count"],
    defaultReelsUsageLimit: json["default_reels_usage_limit"],
    isAdEnable: json["is_ads_enable"],
    enableTrial: json["enable_trial"],
    appVersion: json["app_version"],
    maintenanceMode: json["maintenance_mode"],
    reels: json["Reels"] == null ? null : Reels.fromJson(json["Reels"]),
    adIds: json["ad_ids"] == null ? null : AdIds.fromJson(json["ad_ids"]),
  );

  Map<String, dynamic> toJson() => {
    "default_trial_count": defaultTrialCount,
    "default_reels_usage_limit": defaultReelsUsageLimit,
    "is_ads_enable": isAdEnable,
    "enable_trial": enableTrial,
    "app_version": appVersion,
    "maintenance_mode": maintenanceMode,
    "Reels": reels?.toJson(),
    "ad_ids": adIds?.toJson(),
  };
}

class AdIds {
  String? appOpen;
  String? banner;
  String? interstitial;
  String? native;
  String? rewarded;
  String? rewardedInterstitial;

  AdIds({
    this.appOpen,
    this.banner,
    this.interstitial,
    this.native,
    this.rewarded,
    this.rewardedInterstitial,
  });

  factory AdIds.fromJson(Map<String, dynamic> json) => AdIds(
    appOpen: json["app_open"],
    banner: json["banner"],
    interstitial: json["interstitial"],
    native: json["native"],
    rewarded: json["rewarded"],
    rewardedInterstitial: json["rewarded_interstitial"],
  );

  Map<String, dynamic> toJson() => {
    "app_open": appOpen,
    "banner": banner,
    "interstitial": interstitial,
    "native": native,
    "rewarded": rewarded,
    "rewarded_interstitial": rewardedInterstitial,
  };
}

// DYNAMIC REELS MODEL
class Reels {
  Map<String, String> categories;

  Reels({required this.categories});

  factory Reels.fromJson(Map<String, dynamic> json) {
    final Map<String, String> categories = {};

    json.forEach((key, value) {
      if (value != null && value is String && value.isNotEmpty) {
        categories[key] = value;
      }
    });

    return Reels(categories: categories);
  }

  Map<String, dynamic> toJson() => categories;

  // Helper method to get categories list for UI
  List<Map<String, String>> toCategoriesList() {
    return categories.entries.map((entry) {
      return {
        'name': _formatDisplayName(entry.key),
        'url': entry.value,
        'key': entry.key,
      };
    }).toList();
  }

  String _formatDisplayName(String key) {
    // Special cases
    const specialCases = {
      "18+": "18+",
      "3D": "3D",
      "BBC": "BBC",
      "BBW": "BBW",
      "MILF": "MILF",
    };

    if (specialCases.containsKey(key)) {
      return specialCases[key]!;
    }

    // Convert camelCase to Title Case with spaces
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim();
  }

  // Get specific category URL
  String? getCategoryUrl(String categoryKey) {
    return categories[categoryKey];
  }

  // Check if category exists
  bool hasCategory(String categoryKey) {
    return categories.containsKey(categoryKey);
  }

  // Get total categories count
  int get categoriesCount => categories.length;
}
