import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/add_listing_controller.dart';
import '../core/theme/app_colors.dart';
import '../widgets/custom_text_field.dart';

class AddListingScreen extends StatelessWidget {
  const AddListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddListingController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yeni Elan'),
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Sıfırla',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Satıram / Kirayə verirəm seçimi
              _buildSectionTitle('Əməliyyat növü'),
              const SizedBox(height: 12),
              _buildListingTypeSelector(controller),

              const SizedBox(height: 32),

              // Əmlakın növü
              _buildSectionTitle('Əmlakın növü'),
              const SizedBox(height: 12),
              _buildPropertyTypeSelector(controller),

              const SizedBox(height: 32),

              // Yerləşmə
              if (controller.propertyType.value.isNotEmpty) ...[
                _buildSectionTitle('Yerləşmə'),
                const SizedBox(height: 12),
                _buildLocationSection(controller),
                const SizedBox(height: 32),
              ],

              // Əmlak haqqında məlumatlar (əmlak növü seçildikdən sonra göstər)
              if (controller.propertyType.value.isNotEmpty) ...[
                _buildSectionTitle('Əmlak haqqında'),
                const SizedBox(height: 12),
                _buildPropertyDetailsSection(controller),
                const SizedBox(height: 32),
              ],

              // Şəkillər
              if (controller.propertyType.value.isNotEmpty) ...[
                _buildSectionTitle('Şəkillər',
                    subtitle:
                        'Minimum ${AddListingController.minImages} şəkil, maksimum ${AddListingController.maxImages} şəkil'),
                const SizedBox(height: 16),
                _buildImageSection(controller),
                const SizedBox(height: 32),
              ],

              // Qiymət
              if (controller.propertyType.value.isNotEmpty) ...[
                _buildSectionTitle('Qiymət'),
                const SizedBox(height: 12),
                _buildPriceSection(controller),
                const SizedBox(height: 32),
              ],

              // Əlaqə məlumatları
              if (controller.propertyType.value.isNotEmpty) ...[
                _buildSectionTitle('Əlaqə məlumatları'),
                const SizedBox(height: 12),
                _buildContactSection(controller),
                const SizedBox(height: 32),
              ],

              // Elanın sahibi
              if (controller.propertyType.value.isNotEmpty) ...[
                _buildSectionTitle('Elanın sahibi'),
                const SizedBox(height: 12),
                _buildOwnerTypeSelector(controller),
                const SizedBox(height: 32),
              ],

              // Əlavə məlumatlar
              if (controller.propertyType.value.isNotEmpty) ...[
                _buildSectionTitle('Başlıq'),
                const SizedBox(height: 12),
                _buildTextInputField(
                  'Elanın başlığı',
                  'Elanın başlığını daxil edin',
                  TextInputType.text,
                  (value) => controller.setTitle(value),
                ),
                const SizedBox(height: 32),
                _buildSectionTitle('Əlavə məlumat'),
                const SizedBox(height: 12),
                _buildDescriptionSection(controller),
                const SizedBox(height: 40),
              ],

              // Submit Button
              if (controller.propertyType.value.isNotEmpty)
                _buildSubmitButton(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildListingTypeSelector(AddListingController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildSelectionButton(
            'Satıram',
            controller.listingType.value == 'Satıram',
            () => controller.setListingType('Satıram'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSelectionButton(
            'Kirayə verirəm',
            controller.listingType.value == 'Kirayə verirəm',
            () => controller.setListingType('Kirayə verirəm'),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyTypeSelector(AddListingController controller) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: controller.propertyTypes.length,
      itemBuilder: (context, index) {
        final type = controller.propertyTypes[index];
        final isSelected = controller.propertyType.value == type;

        return _buildPropertyTypeCard(
          type,
          _getPropertyTypeIcon(type),
          isSelected,
          () => controller.setPropertyType(type),
        );
      },
    );
  }

  Widget _buildPropertyTypeCard(
      String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(AddListingController controller) {
    return Column(
      children: [
        // Şəhər seçimi
        _buildDropdownField(
          'Şəhər',
          controller.city.value.isEmpty ? 'Şəhər seçin' : controller.city.value,
          controller.cities,
          (value) => controller.setCity(value!),
        ),
        const SizedBox(height: 16),
        // Rayon seçimi
        if (controller.city.value.isNotEmpty)
          _buildDropdownField(
            'Rayon',
            controller.district.value.isEmpty
                ? 'Rayon seçin'
                : controller.district.value,
            controller.districts[controller.city.value] ?? [],
            (value) => controller.setDistrict(value!),
          ),
      ],
    );
  }

  Widget _buildPropertyDetailsSection(AddListingController controller) {
    return Column(
      children: [
        // Otaq sayı (mənzil, ev, ofis üçün)
        if (controller.requiresRoomCount()) ...[
          _buildNumberSelector(
            'Otaq sayı',
            controller.roomCount.value,
            (value) => controller.setRoomCount(value),
            max: 10,
          ),
          const SizedBox(height: 16),
        ],

        // Sahə
        _buildTextInputField(
          'Sahə, m²',
          'Sahə daxil edin',
          TextInputType.number,
          (value) => controller.setArea(double.tryParse(value) ?? 0),
        ),
        const SizedBox(height: 16),

        // Mərtəbə (mənzil, ofis, obyekt üçün)
        if (controller.requiresFloor()) ...[
          Row(
            children: [
              Expanded(
                child: _buildTextInputField(
                  'Mərtəbə',
                  'Mərtəbə',
                  TextInputType.number,
                  (value) => controller.setFloor(int.tryParse(value) ?? 0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextInputField(
                  'Mərtəbələrin sayı',
                  'Cəmi mərtəbə',
                  TextInputType.number,
                  (value) =>
                      controller.setTotalFloors(int.tryParse(value) ?? 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Yeni tikili / Köhnə tikili (mənzil, ofis üçün)
        if (controller.requiresBuildingType()) ...[
          Text(
            'Bina növü',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSelectionButton(
                  'Yeni tikili',
                  controller.isNewBuilding.value,
                  () => controller.setIsNewBuilding(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSelectionButton(
                  'Köhnə tikili',
                  !controller.isNewBuilding.value,
                  () => controller.setIsNewBuilding(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Təmir vəziyyəti
        if (controller.requiresRepairStatus()) ...[
          Text(
            'Təmir vəziyyəti',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSelectionButton(
                  'Təmirli',
                  controller.hasRepair.value,
                  () => controller.setHasRepair(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSelectionButton(
                  'Təmirsiz',
                  !controller.hasRepair.value,
                  () => controller.setHasRepair(false),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildImageSection(AddListingController controller) {
    return Column(
      children: [
        if (controller.selectedImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.selectedImages.length +
                  (controller.selectedImages.length <
                          AddListingController.maxImages
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                if (index == controller.selectedImages.length) {
                  return _buildAddImageButton(controller);
                }
                return _buildImageItem(controller, index);
              },
            ),
          )
        else
          _buildEmptyImageSection(controller),
      ],
    );
  }

  Widget _buildEmptyImageSection(AddListingController controller) {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.gray300,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.primary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Şəkil əlavə etmək',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection(AddListingController controller) {
    return _buildTextInputField(
      controller.listingType.value == 'Satıram'
          ? 'Qiymət, ₼'
          : 'Aylıq kirayə, ₼',
      'Qiymət daxil edin',
      TextInputType.number,
      (value) => controller.setPrice(double.tryParse(value) ?? 0),
    );
  }

  Widget _buildContactSection(AddListingController controller) {
    return Column(
      children: [
        _buildTextInputField(
          'Ad',
          'Adınızı daxil edin',
          TextInputType.text,
          (value) => controller.setOwnerName(value),
        ),
        const SizedBox(height: 16),
        _buildTextInputField(
          'E-mail',
          'E-mail ünvanınızı daxil edin',
          TextInputType.emailAddress,
          (value) => controller.setOwnerEmail(value),
        ),
        const SizedBox(height: 16),
        _buildTextInputField(
          'Telefon nömrəsi',
          'Telefon nömrənizi daxil edin',
          TextInputType.phone,
          (value) => controller.setPhone(value),
        ),
      ],
    );
  }

  Widget _buildOwnerTypeSelector(AddListingController controller) {
    return Row(
      children: [
        Expanded(
          child: Obx(() => _buildSelectionButton(
                'Elanın sahibi',
                controller.isOwner.value,
                () => controller.setIsOwner(true),
              )),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() => _buildSelectionButton(
                'Mən vasitəçiyəm',
                !controller.isOwner.value,
                () => controller.setIsOwner(false),
              )),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(AddListingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          hint:
              'Daşınmaz əmlak barədə ətraflı məlumatı qeyd edin. Telefon nömrənizi, e-mail və şirkət şərtlərini qeyd etməyin.',
          onChanged: controller.setDescription,
          maxLines: 8,
          maxLength: AddListingController.maxDescriptionLength,
          initialValue: controller.description.value,
        ),
        Obx(() => Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${controller.description.value.length}/${AddListingController.maxDescriptionLength} simvol qalıb',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSubmitButton(AddListingController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.createListing,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Davam etmək',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // Helper widgets
  Widget _buildSelectionButton(
      String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray200),
          ),
          child: DropdownButton<String>(
            value: items.contains(value) ? value : null,
            hint: Text(value),
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberSelector(
      String label, int value, ValueChanged<int> onChanged,
      {int max = 20}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: max + 1,
            itemBuilder: (context, index) {
              final isSelected = value == index;
              return GestureDetector(
                onTap: () => onChanged(index),
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.gray300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      index == 0
                          ? (label.contains('Otaq') ? 'Hamısı' : '0')
                          : '$index',
                      style: GoogleFonts.poppins(
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextInputField(String label, String hint,
      TextInputType keyboardType, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          hint: hint,
          keyboardType: keyboardType,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAddImageButton(AddListingController controller) {
    return Container(
      width: 120,
      height: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray300),
      ),
      child: InkWell(
        onTap: controller.pickImage,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Şəkil əlavə et',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(AddListingController controller, int index) {
    return Container(
      width: 120,
      height: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(controller.selectedImages[index]),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => controller.removeImage(index),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPropertyTypeIcon(String type) {
    switch (type) {
      case 'Mənzil':
        return Icons.apartment;
      case 'Həyət evi/Bağ evi':
        return Icons.home;
      case 'Ofis':
        return Icons.business;
      case 'Obyekt':
        return Icons.store;
      case 'Torpaq':
        return Icons.landscape;
      case 'Qaraj':
        return Icons.garage;
      default:
        return Icons.home;
    }
  }
}
