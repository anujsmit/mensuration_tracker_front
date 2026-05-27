class ProfileModel {

  final String id;

  final String? fullName;

  final String? avatarUrl;

  const ProfileModel({

    required this.id,

    this.fullName,

    this.avatarUrl,
  });

  factory ProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return ProfileModel(

      id: json['id'],

      fullName:
          json['full_name'],

      avatarUrl:
          json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'full_name': fullName,

      'photo_url': avatarUrl,
    };
  }

  ProfileModel copyWith({

    String? fullName,

    String? avatarUrl,

  }) {

    return ProfileModel(

      id: id,

      fullName:
          fullName ?? this.fullName,

      avatarUrl:
          avatarUrl ?? this.avatarUrl,
    );
  }
}