/// 位置信息
class Location {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? district;

  Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.district,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'],
      city: json['city'],
      district: json['district'],
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (district != null) 'district': district,
      };
}

/// 健身房信息
class Gym {
  final String id;
  final String name;
  final String address;
  final Location location;
  final double distance; // 距离（米）
  final String? phone;
  final double? rating;
  final List<String>? photos;
  final List<String>? tags;
  final String? openHours;

  Gym({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    this.distance = 0,
    this.phone,
    this.rating,
    this.photos,
    this.tags,
    this.openHours,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      distance: (json['distance'] ?? 0.0).toDouble(),
      phone: json['phone'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      openHours: json['open_hours'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'location': location.toJson(),
        'distance': distance,
        if (phone != null) 'phone': phone,
        if (rating != null) 'rating': rating,
        if (photos != null) 'photos': photos,
        if (tags != null) 'tags': tags,
        if (openHours != null) 'open_hours': openHours,
      };

  /// 获取格式化的距离
  String get formattedDistance {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}米';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}公里';
    }
  }
}

/// 距离计算结果
class DistanceResult {
  final double distance; // 米
  final int duration; // 秒
  final String route; // 路线描述

  DistanceResult({
    required this.distance,
    required this.duration,
    required this.route,
  });

  factory DistanceResult.fromJson(Map<String, dynamic> json) {
    return DistanceResult(
      distance: (json['distance'] ?? 0.0).toDouble(),
      duration: json['duration'] ?? 0,
      route: json['route'] ?? '',
    );
  }

  /// 获取格式化的距离
  String get formattedDistance {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}米';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}公里';
    }
  }

  /// 获取格式化的时间
  String get formattedDuration {
    final minutes = duration ~/ 60;
    if (minutes < 60) {
      return '$minutes分钟';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours小时$remainingMinutes分钟';
    }
  }
}

