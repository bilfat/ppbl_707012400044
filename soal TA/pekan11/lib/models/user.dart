// ============================================================
// MODEL USER
// ============================================================
// Contoh JSON dari API:
// { "id": 1, "name": "Budi", "email": "budi@mail.com" }
class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
