class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
    );
  }
}
