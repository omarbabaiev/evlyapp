import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/listing_model.dart';

class ListingController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final Rx<ListingModel?> _listing = Rx<ListingModel?>(null);

  ListingModel? get listing => _listing.value;
  bool get isOwner => _auth.currentUser?.uid == listing?.userId;

  void setListing(ListingModel listing) {
    _listing.value = listing;
  }

  void editListing() {
    if (!isOwner) return;
    // Edit listing logic...
  }
}
