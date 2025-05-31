import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String role;
  final String status;

  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.role,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      nama: json['nama'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      nama: data['nama'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'Operator',
      status: data['status'] ?? 'Nonaktif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nama': nama,
      'email': email,
      'role': role,
      'status': status,
    };
  }

  bool get isAdmin => role == 'Admin';
  bool get isProduksi => role == 'Produksi' || isAdmin;
  bool get isGudang => role == 'Gudang' || isAdmin;
  bool get isActive => status == 'Aktif';

  UserModel copyWith({
    String? uid,
    String? nama,
    String? email,
    String? role,
    String? status,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}
