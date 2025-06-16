import 'package:get/get.dart';
import '../models/listing_model.dart';
import '../services/firestore_service.dart';

class FilterController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // Property Type
  final RxString selectedPropertyType = ''.obs;

  // Price Range
  final RxInt minPrice = 0.obs;
  final RxInt maxPrice = 1000000.obs;

  // Area Range
  final RxInt minArea = 0.obs;
  final RxInt maxArea = 1000.obs;

  // Rooms
  final RxInt selectedRooms = 0.obs;

  // Floor (for apartments)
  final RxInt minFloor = 0.obs;
  final RxInt maxFloor = 100.obs;

  // Features
  final RxList<String> selectedFeatures = <String>[].obs;

  // Sub Type (for land and commercial)
  final RxString selectedSubType = ''.obs;

  // Results
  final RxList<ListingModel> filteredResults = <ListingModel>[].obs;
  final RxBool isLoading = false.obs;

  void selectPropertyType(String type) {
    selectedPropertyType.value = type;
    // Clear type-specific filters when changing property type
    selectedFeatures.clear();
    selectedSubType.value = '';
    selectedRooms.value = 0;
    minFloor.value = 0;
    maxFloor.value = 100;
  }

  void selectRooms(int rooms) {
    selectedRooms.value = selectedRooms.value == rooms ? 0 : rooms;
  }

  void selectSubType(String subType) {
    selectedSubType.value = selectedSubType.value == subType ? '' : subType;
  }

  void clearFilters() {
    selectedPropertyType.value = '';
    minPrice.value = 0;
    maxPrice.value = 1000000;
    minArea.value = 0;
    maxArea.value = 1000;
    selectedRooms.value = 0;
    minFloor.value = 0;
    maxFloor.value = 100;
    selectedFeatures.clear();
    selectedSubType.value = '';
    filteredResults.clear();
  }

  Future<void> applyFilters() async {
    if (selectedPropertyType.value.isEmpty) {
      Get.snackbar(
        'Xəta',
        'Zəhmət olmasa əmlak növü seçin',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      final filters = _buildFilterMap();
      final results = await _firestoreService.getFilteredListings(filters);
      filteredResults.value = results;

      // Navigate to search results with filters applied
      Get.toNamed('/search', arguments: {
        'filters': filters,
        'results': results,
      });
    } catch (e) {
      print('Filter error: $e');
      Get.snackbar(
        'Xəta',
        'Filter tətbiq edilərkən xəta baş verdi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _buildFilterMap() {
    final filters = <String, dynamic>{
      'propertyType': selectedPropertyType.value,
      'minPrice': minPrice.value,
      'maxPrice': maxPrice.value,
      'minArea': minArea.value,
      'maxArea': maxArea.value,
    };

    if (selectedRooms.value > 0) {
      filters['rooms'] = selectedRooms.value;
    }

    if (selectedPropertyType.value == 'apartment') {
      filters['minFloor'] = minFloor.value;
      filters['maxFloor'] = maxFloor.value;
    }

    if (selectedFeatures.isNotEmpty) {
      filters['features'] = selectedFeatures.toList();
    }

    if (selectedSubType.value.isNotEmpty) {
      filters['subType'] = selectedSubType.value;
    }

    return filters;
  }
}
