import 'package:get/get.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          // Navigation
          'nav_home': 'Home',
          'nav_favorites': 'Favorites',
          'nav_messages': 'Messages',
          'nav_profile': 'Profile',

          // Home Screen
          'home_title': 'Discover',
          'home_search_hint': 'Search properties...',
          'home_categories': 'Categories',
          'home_featured': 'Featured',
          'home_recent': 'Recent Listings',

          // Property Types
          'type_apartment': 'Apartment',
          'type_house': 'House',
          'type_villa': 'Villa',
          'type_office': 'Office',
          'type_land': 'Land',

          // Common
          'btn_add_listing': 'Add Listing',
          'btn_save': 'Save',
          'btn_cancel': 'Cancel',
          'btn_edit': 'Edit',
          'btn_delete': 'Delete',
          'btn_share': 'Share',

          // Messages
          'msg_exit_app': 'Press back again to exit',
          'msg_no_results': 'No results found',
          'msg_loading': 'Loading...',
        },
        'az_AZ': {
          // Navigation
          'nav_home': 'Ana Səhifə',
          'nav_favorites': 'Sevimlilər',
          'nav_messages': 'Mesajlar',
          'nav_profile': 'Profil',

          // Home Screen
          'home_title': 'Kəşf et',
          'home_search_hint': 'Əmlak axtar...',
          'home_categories': 'Kateqoriyalar',
          'home_featured': 'Seçilmişlər',
          'home_recent': 'Son Elanlar',

          // Property Types
          'type_apartment': 'Mənzil',
          'type_house': 'Ev',
          'type_villa': 'Villa',
          'type_office': 'Ofis',
          'type_land': 'Torpaq',

          // Common
          'btn_add_listing': 'Elan Əlavə Et',
          'btn_save': 'Yadda Saxla',
          'btn_cancel': 'Ləğv Et',
          'btn_edit': 'Düzəliş Et',
          'btn_delete': 'Sil',
          'btn_share': 'Paylaş',

          // Messages
          'msg_exit_app': 'Çıxmaq üçün təkrar basın',
          'msg_no_results': 'Nəticə tapılmadı',
          'msg_loading': 'Yüklənir...',
        },
      };
}
