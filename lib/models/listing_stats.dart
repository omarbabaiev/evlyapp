import 'package:cloud_firestore/cloud_firestore.dart';

class ListingStats {
  final String listingId;
  final int viewCount;
  final int favoriteCount;
  final List<String> viewedBy;
  final List<String> favoritedBy;

  ListingStats({
    required this.listingId,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.viewedBy = const [],
    this.favoritedBy = const [],
  });

  factory ListingStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListingStats(
      listingId: doc.id,
      viewCount: data['viewCount'] ?? 0,
      favoriteCount: data['favoriteCount'] ?? 0,
      viewedBy: List<String>.from(data['viewedBy'] ?? []),
      favoritedBy: List<String>.from(data['favoritedBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'viewedBy': viewedBy,
      'favoritedBy': favoritedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
