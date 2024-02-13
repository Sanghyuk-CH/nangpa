class UserModel {
  final int? id;
  final String nickname;
  final String phoneNumber;
  final String? profileImgUrl;
  final bool marketing;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    required this.nickname,
    required this.phoneNumber,
    this.profileImgUrl,
    required this.marketing,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nickname: json['nickname'],
      phoneNumber: json['phone_number'],
      profileImgUrl: json['profile_img_url'],
      marketing: json['marketing'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'phone_number': phoneNumber,
      'profile_img_url': profileImgUrl,
      'marketing': marketing,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
