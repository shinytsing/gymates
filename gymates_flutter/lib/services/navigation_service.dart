import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

/// 导航服务 - 支持多个地图应用
class NavigationService {
  /// 导航到指定位置
  static Future<void> navigateTo({
    required BuildContext context,
    required double latitude,
    required double longitude,
    String? destinationName,
  }) async {
    // 显示地图选择对话框
    final mapApp = await _showMapSelectionDialog(context);
    if (mapApp == null) return;

    try {
      switch (mapApp) {
        case MapApp.appleMaps:
          await _launchAppleMaps(latitude, longitude, destinationName);
          break;
        case MapApp.googleMaps:
          await _launchGoogleMaps(latitude, longitude, destinationName);
          break;
        case MapApp.baiduMaps:
          await _launchBaiduMaps(latitude, longitude, destinationName);
          break;
        case MapApp.gaodeMaps:
          await _launchGaodeMaps(latitude, longitude, destinationName);
          break;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开地图失败: $e')),
        );
      }
    }
  }

  /// 显示地图选择对话框
  static Future<MapApp?> _showMapSelectionDialog(BuildContext context) {
    final availableMaps = _getAvailableMaps();

    return showModalBottomSheet<MapApp>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '选择导航应用',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              ...availableMaps.map((map) => ListTile(
                    leading: Icon(map.icon, color: map.color),
                    title: Text(
                      map.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () => Navigator.pop(context, map),
                  )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取可用的地图应用
  static List<MapApp> _getAvailableMaps() {
    if (Platform.isIOS) {
      return [
        MapApp.appleMaps,
        MapApp.googleMaps,
        MapApp.baiduMaps,
        MapApp.gaodeMaps,
      ];
    } else if (Platform.isAndroid) {
      return [
        MapApp.googleMaps,
        MapApp.baiduMaps,
        MapApp.gaodeMaps,
      ];
    } else {
      return [MapApp.googleMaps];
    }
  }

  /// 启动Apple地图
  static Future<void> _launchAppleMaps(
    double latitude,
    double longitude,
    String? name,
  ) async {
    final url = 'http://maps.apple.com/?daddr=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Apple Maps';
    }
  }

  /// 启动Google地图
  static Future<void> _launchGoogleMaps(
    double latitude,
    double longitude,
    String? name,
  ) async {
    final url = Platform.isIOS
        ? 'comgooglemaps://?daddr=$latitude,$longitude&directionsmode=driving'
        : 'google.navigation:q=$latitude,$longitude';

    final fallbackUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      await launchUrl(Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication);
    }
  }

  /// 启动百度地图
  static Future<void> _launchBaiduMaps(
    double latitude,
    double longitude,
    String? name,
  ) async {
    // 百度地图需要BD-09坐标系，这里简化处理
    final url =
        'baidumap://map/direction?destination=latlng:$latitude,$longitude|name:${name ?? "目的地"}&mode=driving';
    final fallbackUrl =
        'https://api.map.baidu.com/marker?location=$latitude,$longitude&title=${name ?? "目的地"}&content=目的地&output=html';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      await launchUrl(Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication);
    }
  }

  /// 启动高德地图
  static Future<void> _launchGaodeMaps(
    double latitude,
    double longitude,
    String? name,
  ) async {
    final url =
        'amapuri://route/plan/?dlat=$latitude&dlon=$longitude&dname=${name ?? "目的地"}&dev=0&t=0';
    final fallbackUrl =
        'https://uri.amap.com/marker?position=$longitude,$latitude&name=${name ?? "目的地"}';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      await launchUrl(Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication);
    }
  }

  /// 拨打电话
  static Future<void> makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}

/// 地图应用枚举
class MapApp {
  final String name;
  final IconData icon;
  final Color color;

  const MapApp._(this.name, this.icon, this.color);

  static const appleMaps = MapApp._('Apple 地图', Icons.map, Colors.blue);
  static const googleMaps = MapApp._('Google 地图', Icons.map, Colors.green);
  static const baiduMaps = MapApp._('百度地图', Icons.map, Colors.blue);
  static const gaodeMaps = MapApp._('高德地图', Icons.map, Colors.orange);
}

