import 'package:flutter/material.dart';

/// Neutral icons for custom services without a catalog mark. Stored as brandId `generic:<key>`.
const genericPrefix = 'generic:';
const genericIcons = <String, IconData>{
  'subscription': Icons.autorenew_rounded,
  'music': Icons.music_note_rounded,
  'video': Icons.movie_outlined,
  'tv': Icons.live_tv_rounded,
  'games': Icons.sports_esports_outlined,
  'cloud': Icons.cloud_outlined,
  'storage': Icons.inventory_2_outlined,
  'software': Icons.apps_rounded,
  'code': Icons.code_rounded,
  'ai': Icons.auto_awesome_outlined,
  'news': Icons.newspaper_rounded,
  'books': Icons.menu_book_rounded,
  'education': Icons.school_outlined,
  'fitness': Icons.fitness_center_rounded,
  'health': Icons.favorite_border_rounded,
  'food': Icons.restaurant_rounded,
  'shopping': Icons.shopping_bag_outlined,
  'phone': Icons.smartphone_rounded,
  'internet': Icons.wifi_rounded,
  'home': Icons.home_outlined,
  'car': Icons.directions_car_outlined,
  'travel': Icons.flight_takeoff_rounded,
  'work': Icons.work_outline_rounded,
  'finance': Icons.account_balance_outlined,
  'security': Icons.shield_outlined,
  'pets': Icons.pets_rounded,
  'photo': Icons.photo_camera_outlined,
  'gift': Icons.card_giftcard_rounded,
};

bool isGeneric(String? brandId) => brandId != null && brandId.startsWith(genericPrefix);
IconData? genericIconFor(String? brandId) => isGeneric(brandId) ? genericIcons[brandId!.substring(genericPrefix.length)] : null;
