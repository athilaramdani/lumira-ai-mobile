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
  });

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
    };
  }
}
