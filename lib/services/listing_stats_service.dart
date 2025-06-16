import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/listing_stats.dart';

class ListingStatsService extends GetxService {
  static ListingStatsService get to => Get.find();

  final _firestore = FirebaseFirestore.instance;
  final _statsCollection = 'listingStats';

  // Görüntüləmə əlavə et
  Future<void> addView(String listingId, String userId) async {
    if (listingId.isEmpty) {
      print('ListingStatsService: Cannot add view for empty listing ID');
      return;
    }

    try {
      final statsRef = _firestore.collection('listing_stats').doc(listingId);
      final statsDoc = await statsRef.get();

      if (!statsDoc.exists) {
        // Create new stats document
        await statsRef.set({
          'viewCount': 1,
          'viewedBy': [userId],
          'favoriteCount': 0,
          'favoritedBy': [],
        });
      } else {
        final data = statsDoc.data()!;
        final viewedBy = List<String>.from(data['viewedBy'] ?? []);

        if (!viewedBy.contains(userId)) {
          viewedBy.add(userId);
          await statsRef.update({
            'viewCount': FieldValue.increment(1),
            'viewedBy': viewedBy,
          });
        }
      }
    } catch (e) {
      print('ListingStatsService: Error adding view: $e');
    }
  }

  // Favorit əlavə/silmə
  Future<void> toggleFavorite(String listingId, String userId) async {
    final ref = _firestore.collection(_statsCollection).doc(listingId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);

      if (!doc.exists) {
        transaction.set(ref, {
          'favoriteCount': 1,
          'favoritedBy': [userId],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final favoritedBy = List<String>.from(doc.data()?['favoritedBy'] ?? []);
        if (favoritedBy.contains(userId)) {
          favoritedBy.remove(userId);
          transaction.update(ref, {
            'favoriteCount': FieldValue.increment(-1),
            'favoritedBy': favoritedBy,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          favoritedBy.add(userId);
          transaction.update(ref, {
            'favoriteCount': FieldValue.increment(1),
            'favoritedBy': favoritedBy,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    });
  }

  // Statistikanı al
  Stream<ListingStats> getStats(String listingId) {
    return _firestore
        .collection(_statsCollection)
        .doc(listingId)
        .snapshots()
        .map((doc) => doc.exists
            ? ListingStats.fromFirestore(doc)
            : ListingStats(listingId: listingId));
  }

  // İstifadəçinin favorit edib-etmədiyini yoxla
  Future<bool> isFavorited(String listingId, String userId) async {
    final doc =
        await _firestore.collection(_statsCollection).doc(listingId).get();

    if (!doc.exists) return false;

    final favoritedBy = List<String>.from(doc.data()?['favoritedBy'] ?? []);
    return favoritedBy.contains(userId);
  }
}
