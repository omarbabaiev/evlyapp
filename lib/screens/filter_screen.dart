import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../controllers/filter_controller.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FilterController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Filter',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.clearFilters,
            child: Text(
              'Təmizlə',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Type Selection
                  _buildSectionTitle('Əmlak Növü'),
                  const SizedBox(height: 12),
                  _buildPropertyTypeSelection(controller),
                  const SizedBox(height: 24),

                  // Dynamic Filters based on selected type
                  Obx(() => _buildDynamicFilters(controller)),
                ],
              ),
            ),
          ),

          // Search Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Axtar',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPropertyTypeSelection(FilterController controller) {
    return Obx(() => Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildPropertyTypeCard(
                    controller,
                    'Ev',
                    Icons.home,
                    'house',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPropertyTypeCard(
                    controller,
                    'Torpaq',
                    Icons.landscape,
                    'land',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPropertyTypeCard(
                    controller,
                    'Mənzil',
                    Icons.apartment,
                    'apartment',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPropertyTypeCard(
                    controller,
                    'Mağaza',
                    Icons.store,
                    'commercial',
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _buildPropertyTypeCard(
    FilterController controller,
    String title,
    IconData icon,
    String type,
  ) {
    final isSelected = controller.selectedPropertyType.value == type;

    return GestureDetector(
      onTap: () => controller.selectPropertyType(type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.gray400,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicFilters(FilterController controller) {
    if (controller.selectedPropertyType.value.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (controller.selectedPropertyType.value) {
      case 'house':
        return _buildHouseFilters(controller);
      case 'apartment':
        return _buildApartmentFilters(controller);
      case 'land':
        return _buildLandFilters(controller);
      case 'commercial':
        return _buildCommercialFilters(controller);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHouseFilters(FilterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ev Filtərləri'),
        const SizedBox(height: 16),

        // Price Range
        _buildPriceRange(controller),
        const SizedBox(height: 20),

        // Rooms
        _buildRoomSelection(controller),
        const SizedBox(height: 20),

        // Area
        _buildAreaRange(controller),
        const SizedBox(height: 20),

        // Features
        _buildHouseFeatures(controller),
      ],
    );
  }

  Widget _buildApartmentFilters(FilterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Mənzil Filtərləri'),
        const SizedBox(height: 16),

        // Price Range
        _buildPriceRange(controller),
        const SizedBox(height: 20),

        // Rooms
        _buildRoomSelection(controller),
        const SizedBox(height: 20),

        // Floor
        _buildFloorSelection(controller),
        const SizedBox(height: 20),

        // Area
        _buildAreaRange(controller),
        const SizedBox(height: 20),

        // Features
        _buildApartmentFeatures(controller),
      ],
    );
  }

  Widget _buildLandFilters(FilterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Torpaq Filtərləri'),
        const SizedBox(height: 16),

        // Price Range
        _buildPriceRange(controller),
        const SizedBox(height: 20),

        // Area
        _buildAreaRange(controller),
        const SizedBox(height: 20),

        // Land Type
        _buildLandTypeSelection(controller),
      ],
    );
  }

  Widget _buildCommercialFilters(FilterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Mağaza Filtərləri'),
        const SizedBox(height: 16),

        // Price Range
        _buildPriceRange(controller),
        const SizedBox(height: 20),

        // Area
        _buildAreaRange(controller),
        const SizedBox(height: 20),

        // Commercial Type
        _buildCommercialTypeSelection(controller),
      ],
    );
  }

  Widget _buildPriceRange(FilterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qiymət Aralığı',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => RangeSlider(
              values: RangeValues(
                controller.minPrice.value.toDouble(),
                controller.maxPrice.value.toDouble(),
              ),
              min: 0,
              max: 1000000,
              divisions: 100,
              labels: RangeLabels(
                '${controller.minPrice.value} ₼',
                '${controller.maxPrice.value} ₼',
              ),
              onChanged: (values) {
                controller.minPrice.value = values.start.toInt();
                controller.maxPrice.value = values.end.toInt();
              },
            )),
      ],
    );
  }

  Widget _buildRoomSelection(FilterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Otaq Sayı',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 8,
              children: [1, 2, 3, 4, 5].map((rooms) {
                final isSelected = controller.selectedRooms.value == rooms;
                return GestureDetector(
                  onTap: () => controller.selectRooms(rooms),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.gray300,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      rooms == 5 ? '5+' : '$rooms',
                      style: GoogleFonts.poppins(
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildAreaRange(FilterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sahə (m²)',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => RangeSlider(
              values: RangeValues(
                controller.minArea.value.toDouble(),
                controller.maxArea.value.toDouble(),
              ),
              min: 0,
              max: 1000,
              divisions: 100,
              labels: RangeLabels(
                '${controller.minArea.value} m²',
                '${controller.maxArea.value} m²',
              ),
              onChanged: (values) {
                controller.minArea.value = values.start.toInt();
                controller.maxArea.value = values.end.toInt();
              },
            )),
      ],
    );
  }

  Widget _buildFloorSelection(FilterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mərtəbə',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Min mərtəbə',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  controller.minFloor.value = int.tryParse(value) ?? 0;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Max mərtəbə',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  controller.maxFloor.value = int.tryParse(value) ?? 100;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHouseFeatures(FilterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xüsusiyyətlər',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: [
                _buildFeatureCheckbox(controller, 'Həyət', 'yard'),
                _buildFeatureCheckbox(controller, 'Qaraj', 'garage'),
                _buildFeatureCheckbox(controller, 'Hovuz', 'pool'),
                _buildFeatureCheckbox(controller, 'Bağ', 'garden'),
              ],
            )),
      ],
    );
  }

  Widget _buildApartmentFeatures(FilterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xüsusiyyətlər',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: [
                _buildFeatureCheckbox(controller, 'Lift', 'elevator'),
                _buildFeatureCheckbox(controller, 'Balkon', 'balcony'),
                _buildFeatureCheckbox(controller, 'Təmirli', 'renovated'),
                _buildFeatureCheckbox(controller, 'Mebelli', 'furnished'),
              ],
            )),
      ],
    );
  }

  Widget _buildLandTypeSelection(FilterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Torpaq Növü',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: [
                _buildRadioOption(controller, 'Tikinti üçün', 'construction'),
                _buildRadioOption(
                    controller, 'Kənd təsərrüfatı', 'agricultural'),
                _buildRadioOption(controller, 'Kommersiya', 'commercial_land'),
              ],
            )),
      ],
    );
  }

  Widget _buildCommercialTypeSelection(FilterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mağaza Növü',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: [
                _buildRadioOption(controller, 'Mağaza', 'shop'),
                _buildRadioOption(controller, 'Ofis', 'office'),
                _buildRadioOption(controller, 'Anbar', 'warehouse'),
                _buildRadioOption(controller, 'Restoran', 'restaurant'),
              ],
            )),
      ],
    );
  }

  Widget _buildFeatureCheckbox(
      FilterController controller, String title, String key) {
    return CheckboxListTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
      ),
      value: controller.selectedFeatures.contains(key),
      onChanged: (value) {
        if (value == true) {
          controller.selectedFeatures.add(key);
        } else {
          controller.selectedFeatures.remove(key);
        }
      },
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildRadioOption(
      FilterController controller, String title, String value) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
      ),
      value: value,
      groupValue: controller.selectedSubType.value,
      onChanged: (value) => controller.selectSubType(value ?? ''),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}
