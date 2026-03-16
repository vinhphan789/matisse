// profile_model.dart
//
// 🍎 Swift: struct Profile: Codable { ... }
// 🐦 Flutter: class + fromJson/toJson — không có Codable tự động,
//             phải viết tay hoặc dùng json_serializable package

class ProfileModel {
  final int user;
  final String name;
  final String address1;
  final String address2;
  final String city;
  final int country;
  final String postalCode;
  final String vat;
  final String serialNumber;
  final String source;
  final List<SubscriptionModel> subscriptions;
  final bool fromSmileline;
  final String createdTs;
  final String language;
  final String signupState;
  final bool eligibleForTrial;

  ProfileModel({
    required this.user,
    required this.name,
    required this.address1,
    required this.address2,
    required this.city,
    required this.country,
    required this.postalCode,
    required this.vat,
    required this.serialNumber,
    required this.source,
    required this.subscriptions,
    required this.fromSmileline,
    required this.createdTs,
    required this.language,
    required this.signupState,
    required this.eligibleForTrial,
  });

  // 🍎 Swift: init(from decoder: Decoder) — Codable tự generate
  // 🐦 Flutter: phải tự viết fromJson
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      user: json['user'] ?? 0,
      name: json['name'] ?? '',
      address1: json['address1'] ?? '',
      address2: json['address2'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? 0,
      postalCode: json['postal_code'] ?? '',
      vat: json['vat'] ?? '',
      serialNumber: json['serial_number'] ?? '',
      source: json['source'] ?? '',
      subscriptions: (json['subscriptions'] as List<dynamic>? ?? [])
          .map((e) => SubscriptionModel.fromJson(e))
          .toList(),
      fromSmileline: json['from_smileline'] ?? false,
      createdTs: json['created_ts'] ?? '',
      language: json['language'] ?? '',
      signupState: json['signup_state'] ?? '',
      eligibleForTrial: json['eligible_for_trial'] ?? false,
    );
  }

  // 🍎 Swift: func encode(to encoder: Encoder) — Codable tự generate
  // 🐦 Flutter: phải tự viết toJson để lưu xuống SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'name': name,
      'address1': address1,
      'address2': address2,
      'city': city,
      'country': country,
      'postal_code': postalCode,
      'vat': vat,
      'serial_number': serialNumber,
      'source': source,
      'subscriptions': subscriptions.map((e) => e.toJson()).toList(),
      'from_smileline': fromSmileline,
      'created_ts': createdTs,
      'language': language,
      'signup_state': signupState,
      'eligible_for_trial': eligibleForTrial,
    };
  }
}

// ─────────────────────────────────────────

class SubscriptionModel {
  final int id;
  final String stripeSubscription;
  final PlanModel plan;
  final int trialDays;
  final String package;
  final int remainingTrialDays;
  final String isLegacy;
  final List<FeatureWrapperModel> features;
  final List<WorkflowWrapperModel> workflows;
  final bool isTrialPeriod;
  final bool isInIntroOfferPeriod;

  SubscriptionModel({
    required this.id,
    required this.stripeSubscription,
    required this.plan,
    required this.trialDays,
    required this.package,
    required this.remainingTrialDays,
    required this.isLegacy,
    required this.features,
    required this.workflows,
    required this.isTrialPeriod,
    required this.isInIntroOfferPeriod,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? 0,
      stripeSubscription: json['stripe_subscription'] ?? '',
      plan: PlanModel.fromJson(json['plan'] ?? {}),
      trialDays: json['trial_days'] ?? 0,
      package: json['package'] ?? '',
      remainingTrialDays: json['remaining_trial_days'] ?? 0,
      isLegacy: json['is_legacy'] ?? '',
      features: (json['features'] as List<dynamic>? ?? [])
          .map((e) => FeatureWrapperModel.fromJson(e))
          .toList(),
      workflows: (json['workflows'] as List<dynamic>? ?? [])
          .map((e) => WorkflowWrapperModel.fromJson(e))
          .toList(),
      isTrialPeriod: json['is_trial_period'] ?? false,
      isInIntroOfferPeriod: json['is_in_intro_offer_period'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'stripe_subscription': stripeSubscription,
    'plan': plan.toJson(),
    'trial_days': trialDays,
    'package': package,
    'remaining_trial_days': remainingTrialDays,
    'is_legacy': isLegacy,
    'features': features.map((e) => e.toJson()).toList(),
    'workflows': workflows.map((e) => e.toJson()).toList(),
    'is_trial_period': isTrialPeriod,
    'is_in_intro_offer_period': isInIntroOfferPeriod,
  };
}

// ─────────────────────────────────────────

class PlanModel {
  final int id;
  final String stripePrice;
  final String interval;
  final int intervalCount;
  final double amount;
  final String currency;
  final String? appleProductId;

  PlanModel({
    required this.id,
    required this.stripePrice,
    required this.interval,
    required this.intervalCount,
    required this.amount,
    required this.currency,
    this.appleProductId,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] ?? 0,
      stripePrice: json['stripe_price'] ?? '',
      interval: json['interval'] ?? '',
      intervalCount: json['interval_count'] ?? 0,
      // 🍎 Swift: json["amount"] as? Double ?? 0
      // 🐦 Flutter: num có thể là int hoặc double, dùng toDouble() để an toàn
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? '',
      appleProductId: json['apple_product_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'stripe_price': stripePrice,
    'interval': interval,
    'interval_count': intervalCount,
    'amount': amount,
    'currency': currency,
    'apple_product_id': appleProductId,
  };
}

// ─────────────────────────────────────────

class FeatureWrapperModel {
  final int sequence;
  final FeatureModel feature;

  FeatureWrapperModel({required this.sequence, required this.feature});

  factory FeatureWrapperModel.fromJson(Map<String, dynamic> json) =>
      FeatureWrapperModel(
        sequence: json['sequence'] ?? 0,
        feature: FeatureModel.fromJson(json['feature'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    'sequence': sequence,
    'feature': feature.toJson(),
  };
}

class FeatureModel {
  final int id;
  final String displayName;
  final String key;
  final bool isMenuItem;
  final bool showInPlan;
  final String icon;

  FeatureModel({
    required this.id,
    required this.displayName,
    required this.key,
    required this.isMenuItem,
    required this.showInPlan,
    required this.icon,
  });

  factory FeatureModel.fromJson(Map<String, dynamic> json) => FeatureModel(
    id: json['id'] ?? 0,
    displayName: json['display_name'] ?? '',
    key: json['key'] ?? '',
    isMenuItem: json['is_menu_item'] ?? false,
    showInPlan: json['show_in_plan'] ?? false,
    icon: json['icon'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
    'key': key,
    'is_menu_item': isMenuItem,
    'show_in_plan': showInPlan,
    'icon': icon,
  };
}

// ─────────────────────────────────────────

class WorkflowWrapperModel {
  final int sequence;
  final WorkflowModel workflow;

  WorkflowWrapperModel({required this.sequence, required this.workflow});

  factory WorkflowWrapperModel.fromJson(Map<String, dynamic> json) =>
      WorkflowWrapperModel(
        sequence: json['sequence'] ?? 0,
        workflow: WorkflowModel.fromJson(json['workflow'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    'sequence': sequence,
    'workflow': workflow.toJson(),
  };
}

class WorkflowModel {
  final int id;
  final String displayName;
  final String key;

  WorkflowModel({
    required this.id,
    required this.displayName,
    required this.key,
  });

  factory WorkflowModel.fromJson(Map<String, dynamic> json) => WorkflowModel(
    id: json['id'] ?? 0,
    displayName: json['display_name'] ?? '',
    key: json['key'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
    'key': key,
  };
}