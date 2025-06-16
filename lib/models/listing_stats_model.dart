import 'package:cloud_firestore/cloud_firestore.dart';

class ListingStatsModel {
  final String listingId;
  final int views;
  final int favorites;
  final int contacts;
  final int shares;
  final Map<String, int> dailyViews;
  final Map<String, int> weeklyViews;
  final Map<String, int> monthlyViews;
  final DateTime lastUpdated;
  final List<String> viewerIds;
  final List<String> favoriteUserIds;
  final double averageViewDuration;
  final Map<String, dynamic> demographics;

  ListingStatsModel({
    required this.listingId,
    this.views = 0,
    this.favorites = 0,
    this.contacts = 0,
    this.shares = 0,
    this.dailyViews = const {},
    this.weeklyViews = const {},
    this.monthlyViews = const {},
    required this.lastUpdated,
    this.viewerIds = const [],
    this.favoriteUserIds = const [],
    this.averageViewDuration = 0.0,
    this.demographics = const {},
  });

  factory ListingStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListingStatsModel(
      listingId: doc.id,
      views: data['views'] ?? 0,
      favorites: data['favorites'] ?? 0,
      contacts: data['contacts'] ?? 0,
      shares: data['shares'] ?? 0,
      dailyViews: Map<String, int>.from(data['dailyViews'] ?? {}),
      weeklyViews: Map<String, int>.from(data['weeklyViews'] ?? {}),
      monthlyViews: Map<String, int>.from(data['monthlyViews'] ?? {}),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      viewerIds: List<String>.from(data['viewerIds'] ?? []),
      favoriteUserIds: List<String>.from(data['favoriteUserIds'] ?? []),
      averageViewDuration: (data['averageViewDuration'] ?? 0.0).toDouble(),
      demographics: Map<String, dynamic>.from(data['demographics'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'views': views,
      'favorites': favorites,
      'contacts': contacts,
      'shares': shares,
      'dailyViews': dailyViews,
      'weeklyViews': weeklyViews,
      'monthlyViews': monthlyViews,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'viewerIds': viewerIds,
      'favoriteUserIds': favoriteUserIds,
      'averageViewDuration': averageViewDuration,
      'demographics': demographics,
    };
  }

  ListingStatsModel copyWith({
    String? listingId,
    int? views,
    int? favorites,
    int? contacts,
    int? shares,
    Map<String, int>? dailyViews,
    Map<String, int>? weeklyViews,
    Map<String, int>? monthlyViews,
    DateTime? lastUpdated,
    List<String>? viewerIds,
    List<String>? favoriteUserIds,
    double? averageViewDuration,
    Map<String, dynamic>? demographics,
  }) {
    return ListingStatsModel(
      listingId: listingId ?? this.listingId,
      views: views ?? this.views,
      favorites: favorites ?? this.favorites,
      contacts: contacts ?? this.contacts,
      shares: shares ?? this.shares,
      dailyViews: dailyViews ?? this.dailyViews,
      weeklyViews: weeklyViews ?? this.weeklyViews,
      monthlyViews: monthlyViews ?? this.monthlyViews,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      viewerIds: viewerIds ?? this.viewerIds,
      favoriteUserIds: favoriteUserIds ?? this.favoriteUserIds,
      averageViewDuration: averageViewDuration ?? this.averageViewDuration,
      demographics: demographics ?? this.demographics,
    );
  }

  // Helper methods for analytics
  int getTotalViewsLast7Days() {
    final now = DateTime.now();
    int total = 0;

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      total += dailyViews[dateKey] ?? 0;
    }

    return total;
  }

  int getTotalViewsLast30Days() {
    final now = DateTime.now();
    int total = 0;

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      total += dailyViews[dateKey] ?? 0;
    }

    return total;
  }

  double getViewsGrowthRate() {
    final last7Days = getTotalViewsLast7Days();
    final previous7Days = _getPrevious7DaysViews();

    if (previous7Days == 0) return 0.0;
    return ((last7Days - previous7Days) / previous7Days) * 100;
  }

  int _getPrevious7DaysViews() {
    final now = DateTime.now();
    int total = 0;

    for (int i = 7; i < 14; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      total += dailyViews[dateKey] ?? 0;
    }

    return total;
  }

  List<MapEntry<String, int>> getTopViewDays({int limit = 5}) {
    final entries = dailyViews.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  double getEngagementRate() {
    if (views == 0) return 0.0;
    return ((contacts + favorites + shares) / views) * 100;
  }

  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'totalViews': views,
      'viewsLast7Days': getTotalViewsLast7Days(),
      'viewsLast30Days': getTotalViewsLast30Days(),
      'growthRate': getViewsGrowthRate(),
      'engagementRate': getEngagementRate(),
      'averageViewDuration': averageViewDuration,
      'conversionRate': views > 0 ? (contacts / views) * 100 : 0.0,
      'favoriteRate': views > 0 ? (favorites / views) * 100 : 0.0,
      'shareRate': views > 0 ? (shares / views) * 100 : 0.0,
    };
  }
}
