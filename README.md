# evlyapp

# Evly - Əmlak Alqı-Satqı Platforması

Flutter və Firebase əsaslı əmlak alqı-satqı mobil applikasiyası.

## Xüsusiyyətlər

- **Firebase Authentication**: Google Sign-In ilə authentication
- **Cloud Firestore**: Real-time database
- **GetX State Management**: Reactive state management
- **Native Splash Screen**: Branding üçün native splash screen
- **Responsive UI**: Modern və responsive istifadəçi interfeysi

## Arxitektura

- **Clean Architecture**: Ayrılmış layer struktur
- **MVC Pattern**: Model-View-Controller pattern
- **Service Layer**: API və business logic üçün ayrı servis layer
- **Dependency Injection**: GetX ilə dependency injection

## Quraşdırma

1. Flutter SDK yükləyin
2. Firebase layihəsi yaradın və konfiqurasiya edin
3. Dependencies yükləyin:
   ```bash
   flutter pub get
   ```
4. Native splash screen generate edin:
   ```bash
   dart run flutter_native_splash:create
   ```
5. Applikasiyani işə salın:
   ```bash
   flutter run
   ```

## Struktur

```
lib/
├── config/          # Konfiqurasiya faylları
├── controllers/     # GetX controllers
├── models/          # Data modellər
├── screens/         # UI screens
├── services/        # API və business logic
└── widgets/         # Reusable UI components
```

## Əsas Ekranlar

1. **Login Screen**: Google Sign-In authentication
2. **Home Screen**: Elan axtar və kateqoriya filtrləri
3. **Favorite Screen**: Sevimli elanlar
4. **Profile Screen**: İstifadəçi profili və parametrlər

## Firebase Konfiqurasiyası

1. Firebase Console-da yeni layihə yaradın
2. Authentication aktiv edin (Google provider)
3. Firestore Database yaradın
4. Android/iOS app əlavə edin
5. `google-services.json` və `GoogleService-Info.plist` faylları əlavə edin

## İstifadə Edilən Paketlər

- `get`: State management və routing
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `google_sign_in`: Google authentication
- `carousel_slider`: Image carousel
- `get_storage`: Local storage
- `flutter_native_splash`: Native splash screen

## Məlumat Strukturu

### User Model
- uid, email, displayName
- photoURL, createdAt
- favoriteListings

### Listing Model
- title, description, price
- category, images
- ownerId, location
- createdAt, isActive
