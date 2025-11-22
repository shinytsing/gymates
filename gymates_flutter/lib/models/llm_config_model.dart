/// LLM配置模型
library;

class LLMConfig {
  final String provider;
  final String name;
  final String displayName;
  final String description;
  final String icon;
  final bool isAvailable;
  final bool isFree;
  final bool requiresMembership;
  final List<String> features;
  final LLMPricing pricing;

  LLMConfig({
    required this.provider,
    required this.name,
    required this.displayName,
    required this.description,
    required this.icon,
    required this.isAvailable,
    this.isFree = false,
    this.requiresMembership = false,
    required this.features,
    required this.pricing,
  });

  factory LLMConfig.fromJson(Map<String, dynamic> json) {
    return LLMConfig(
      provider: json['provider'] ?? '',
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🤖',
      isAvailable: json['is_available'] ?? false,
      isFree: json['is_free'] ?? false,
      requiresMembership: json['requires_membership'] ?? false,
      features: List<String>.from(json['features'] ?? []),
      pricing: LLMPricing.fromJson(json['pricing'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'name': name,
      'display_name': displayName,
      'description': description,
      'icon': icon,
      'is_available': isAvailable,
      'is_free': isFree,
      'requires_membership': requiresMembership,
      'features': features,
      'pricing': pricing.toJson(),
    };
  }
}

class LLMPricing {
  final String inputPrice;
  final String outputPrice;
  final String currency;
  final String avgCost;

  LLMPricing({
    required this.inputPrice,
    required this.outputPrice,
    required this.currency,
    required this.avgCost,
  });

  factory LLMPricing.fromJson(Map<String, dynamic> json) {
    return LLMPricing(
      inputPrice: json['input_price'] ?? '',
      outputPrice: json['output_price'] ?? '',
      currency: json['currency'] ?? '',
      avgCost: json['avg_cost'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'input_price': inputPrice,
      'output_price': outputPrice,
      'currency': currency,
      'avg_cost': avgCost,
    };
  }
}

class LLMConfigsResponse {
  final List<LLMConfig> configs;
  final String currentProvider;
  final String recommendedProvider;
  final bool hasVIPAccess;

  LLMConfigsResponse({
    required this.configs,
    required this.currentProvider,
    required this.recommendedProvider,
    this.hasVIPAccess = false,
  });

  factory LLMConfigsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return LLMConfigsResponse(
      configs: (data['configs'] as List?)
              ?.map((e) => LLMConfig.fromJson(e))
              .toList() ??
          [],
      currentProvider: data['current_provider'] ?? 'tencent',
      recommendedProvider: data['recommended_provider'] ?? 'tencent',
      hasVIPAccess: data['has_vip_access'] ?? false,
    );
  }
}

