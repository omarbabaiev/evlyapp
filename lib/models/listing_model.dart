import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String city;
  final String? district;
  final double price;
  final List<String> images;
  final String phone;
  final String? ownerName;
  final String? ownerEmail;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? userName;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? details;

  ListingModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.city,
    this.district,
    required this.price,
    required this.images,
    required this.phone,
    this.ownerName,
    this.ownerEmail,
    required this.createdAt,
    this.updatedAt,
    this.userName,
    this.latitude,
    this.longitude,
    this.details,
  }) {
    // Temporarily allow empty ID for creation
    // if (id.isEmpty) {
    //   throw ArgumentError('Listing ID cannot be empty');
    // }
    // Temporarily allow empty userId to handle existing data
    // if (userId.isEmpty) {
    //   throw ArgumentError('User ID cannot be empty');
    // }
  }

  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    if (doc.id.isEmpty) {
      throw Exception('Document ID cannot be empty');
    }

    return ListingModel(
      id: doc.id,
      userId: data['userId'] ?? 'unknown',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      city: data['city'] ?? '',
      district: data['district'],
      price: (data['price'] ?? 0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      phone: data['phone'] ?? '',
      ownerName: data['ownerName'],
      ownerEmail: data['ownerEmail'],
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] is Timestamp
              ? (data['updatedAt'] as Timestamp).toDate()
              : DateTime.fromMillisecondsSinceEpoch(data['updatedAt']))
          : null,
      userName: data['userName'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      details: data['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'city': city,
      'district': district,
      'price': price,
      'images': images,
      'phone': phone,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
      'userName': userName,
      'latitude': latitude,
      'longitude': longitude,
      'details': details,
    };
  }

  ListingModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    String? city,
    String? district,
    double? price,
    List<String>? images,
    String? phone,
    String? ownerName,
    String? ownerEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? details,
  }) {
    return ListingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      city: city ?? this.city,
      district: district ?? this.district,
      price: price ?? this.price,
      images: images ?? this.images,
      phone: phone ?? this.phone,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      details: details ?? this.details,
    );
  }
}
