import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String city;
  final double price;
  final List<String> images;
  final String phone;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? userName;
  final double? latitude;
  final double? longitude;

  ListingModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.city,
    required this.price,
    required this.images,
    required this.phone,
    required this.createdAt,
    this.updatedAt,
    this.userName,
    this.latitude,
    this.longitude,
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
      price: (data['price'] ?? 0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      phone: data['phone'] ?? '',
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
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'city': city,
      'price': price,
      'images': images,
      'phone': phone,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
      'userName': userName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  ListingModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    String? city,
    double? price,
    List<String>? images,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    double? latitude,
    double? longitude,
  }) {
    return ListingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      city: city ?? this.city,
      price: price ?? this.price,
      images: images ?? this.images,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
