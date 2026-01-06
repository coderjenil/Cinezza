// To parse this JSON data, do
//
//     final remoteConfigModel = remoteConfigModelFromJson(jsonString);

import 'dart:convert';

RemoteConfigModel remoteConfigModelFromJson(String str) =>
    RemoteConfigModel.fromJson(json.decode(str));

String remoteConfigModelToJson(RemoteConfigModel data) =>
    json.encode(data.toJson());

class RemoteConfigModel {
  bool success;
  String message;
  Config config;

  RemoteConfigModel({
    required this.success,
    required this.message,
    required this.config,
  });

  factory RemoteConfigModel.fromJson(Map<String, dynamic> json) =>
      RemoteConfigModel(
        success: json["success"],
        message: json["message"],
        config: Config.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": config.toJson(),
  };
}

class Config {
  int defaultTrialCount;
  int defaultReelsUsageLimit;
  String appVersion;
  bool maintenanceMode;
  Reels reels;
  AdIds adIds;
  String contactUs;
  String telegramUrl;
  String instagramUrl;
  String facebookUrl;
  String privacyPolicyUrl;
  String webUrl;
  String minAppVersion;
  bool isAdsEnable;
  String apkDownloadUrl;
  bool forceUpdate;
  int reelIncreaseTime;
  bool showMature;
  String rzpId;
  int adDelayCount;

  Config({
    required this.defaultTrialCount,
    required this.defaultReelsUsageLimit,

    required this.appVersion,
    required this.maintenanceMode,
    required this.reels,
    required this.adIds,
    required this.contactUs,
    required this.telegramUrl,
    required this.instagramUrl,
    required this.facebookUrl,
    required this.privacyPolicyUrl,
    required this.webUrl,
    required this.minAppVersion,
    required this.isAdsEnable,
    required this.apkDownloadUrl,
    required this.forceUpdate,
    required this.reelIncreaseTime,
    required this.showMature,
    required this.rzpId,
    required this.adDelayCount,
  });

  factory Config.fromJson(Map<String, dynamic> json) => Config(
    defaultTrialCount: json["default_trial_count"],
    defaultReelsUsageLimit: json["default_reels_usage_limit"],

    appVersion: json["app_version"],
    maintenanceMode: json["maintenance_mode"],
    reels: Reels.fromJson(json["Reels"]),
    adIds: AdIds.fromJson(json["ad_ids"]),
    contactUs: json["contact_us"],
    telegramUrl: json["telegram_url"],
    instagramUrl: json["instagram_url"],
    facebookUrl: json["facebook_url"],
    privacyPolicyUrl: json["privacy_policy_url"],
    webUrl: json["web_url"],
    minAppVersion: json["min_app_version"],
    isAdsEnable: json["is_ads_enable"],
    apkDownloadUrl: json["apk_download_url"],
    forceUpdate: json["force_update"],
    reelIncreaseTime: json["reel_view_increase_time"],
    showMature: json["show_mature_content"],
    rzpId: json["rzp_id"],
    adDelayCount: json["ad_delay_count"],
  );

  Map<String, dynamic> toJson() => {
    "default_trial_count": defaultTrialCount,
    "default_reels_usage_limit": defaultReelsUsageLimit,

    "app_version": appVersion,
    "maintenance_mode": maintenanceMode,
    "Reels": reels.toJson(),
    "ad_ids": adIds.toJson(),
    "contact_us": contactUs,
    "telegram_url": telegramUrl,
    "instagram_url": instagramUrl,
    "facebook_url": facebookUrl,
    "privacy_policy_url": privacyPolicyUrl,
    "web_url": webUrl,
    "min_app_version": minAppVersion,
    "is_ads_enable": isAdsEnable,
    "apk_download_url": apkDownloadUrl,
    "force_update": forceUpdate,
    "reel_view_increase_time": reelIncreaseTime,
    "show_mature_content": showMature,
    "rzp_id": rzpId,
    "ad_delay_count": adDelayCount,
  };
}

class AdIds {
  String appOpen;
  String banner;
  String interstitial;
  String native;
  String rewarded;
  String rewardedInterstitial;

  AdIds({
    required this.appOpen,
    required this.banner,
    required this.interstitial,
    required this.native,
    required this.rewarded,
    required this.rewardedInterstitial,
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
