class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? role;
  final String? phone;
  final String? dateOfBirth;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? imageUrl;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.role,
    this.phone,
    this.dateOfBirth,
    this.address,
    this.city,
    this.postalCode,
    this.imageUrl,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? dateOfBirth,
    String? address,
    String? city,
    String? postalCode,
    String? imageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'] ?? json['dateOfBirth'],
      address: json['address'],
      city: json['city'],
      postalCode: json['postal_code'] ?? json['postalCode'],
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (phone != null) 'phone': phone,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (postalCode != null) 'postal_code': postalCode,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }
}
