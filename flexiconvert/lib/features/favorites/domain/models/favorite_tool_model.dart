import 'package:equatable/equatable.dart';

class FavoriteToolItem extends Equatable {
  final String toolId;
  final String title;
  final String subtitle;
  final int iconCodePoint;
  final int colorValue;
  final String route;

  const FavoriteToolItem({
    required this.toolId,
    required this.title,
    required this.subtitle,
    required this.iconCodePoint,
    required this.colorValue,
    required this.route,
  });

  factory FavoriteToolItem.fromJson(Map<String, dynamic> json) {
    return FavoriteToolItem(
      toolId: json['toolId'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      iconCodePoint: json['iconCodePoint'] as int,
      colorValue: json['colorValue'] as int,
      route: json['route'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'toolId': toolId,
      'title': title,
      'subtitle': subtitle,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'route': route,
    };
  }

  @override
  List<Object?> get props => [toolId, title, subtitle, iconCodePoint, colorValue, route];
}
