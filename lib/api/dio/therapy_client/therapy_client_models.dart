class TherapyClientDto {
  const TherapyClientDto({
    required this.clientId,
    required this.name,
    required this.gender,
    required this.age,
    required this.phone,
    this.avatar,
  });

  final int clientId;
  final String name;
  final String gender;
  final int? age;
  final String phone;
  final String? avatar;

  factory TherapyClientDto.fromJson(Map<String, dynamic> json) {
    return TherapyClientDto(
      clientId: int.tryParse(json['clientId']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      age: int.tryParse(json['age']?.toString() ?? ''),
      phone: json['phone']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
    );
  }
}

class TherapyClientRequestDto {
  const TherapyClientRequestDto({
    required this.name,
    required this.gender,
    required this.age,
    required this.phone,
    this.avatar,
  });

  final String name;
  final String gender;
  final int? age;
  final String phone;
  final String? avatar;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'name': name,
      'gender': gender,
      'age': age,
      'phone': phone,
      'avatar': avatar,
    };
  }
}
