// ======================================================
// FILE:
// lib/features/profile/models/profile_model.dart
// ======================================================

class ProfileModel {

  final String id;

  final String? username;

  final String? fullName;

  final String? email;

  final String? phoneNumber;

  final String? photoUrl;

  final int? age;

  final double? weight;

  final double? height;

  final String? bio;

  final DateTime? createdAt;

  ProfileModel({

    required this.id,

    this.username,

    this.fullName,

    this.email,

    this.phoneNumber,

    this.photoUrl,

    this.age,

    this.weight,

    this.height,

    this.bio,

    this.createdAt,

  });

  // ======================================================
  // FROM JSON
  // ======================================================

  factory ProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return ProfileModel(

      id: json['id'] ?? '',

      username:
          json['username'],

      fullName:
          json['full_name'],

      email:
          json['email'],

      phoneNumber:
          json['phone_number'],

      photoUrl:
          json['photo_url'],

      age:
          json['age'],

      weight:
          json['weight'] != null

              ? double.tryParse(
                  json['weight']
                      .toString(),
                )

              : null,

      height:
          json['height'] != null

              ? double.tryParse(
                  json['height']
                      .toString(),
                )

              : null,

      bio:
          json['bio'],

      createdAt:
          json['created_at'] != null

              ? DateTime.parse(
                  json['created_at'],
                )

              : null,

    );

  }

  // ======================================================
  // TO JSON
  // ======================================================

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'username': username,

      'full_name': fullName,

      'email': email,

      'phone_number':
          phoneNumber,

      'photo_url':
          photoUrl,

      'age': age,

      'weight': weight,

      'height': height,

      'bio': bio,

      'created_at':
          createdAt
              ?.toIso8601String(),

    };

  }

}