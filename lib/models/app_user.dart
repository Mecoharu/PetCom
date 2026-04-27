import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? photoUrl;
  final String? bio;
  final String? location;
  final String? fcmToken;
  final int totalPosts;
  final int totalAdoptions;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.photoUrl,
    this.bio,
    this.location,
    this.fcmToken,
    required this.totalPosts,
    required this.totalAdoptions,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: d['email'] ?? '',
      fullName: d['fullName'] ?? '',
      phoneNumber: d['phoneNumber'],
      photoUrl: d['photoUrl'],
      bio: d['bio'],
      location: d['location'],
      fcmToken: d['fcmToken'],
      totalPosts: d['totalPosts'] ?? 0,
      totalAdoptions: d['totalAdoptions'] ?? 0,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'photoUrl': photoUrl,
        'bio': bio,
        'location': location,
        'fcmToken': fcmToken,
        'totalPosts': totalPosts,
        'totalAdoptions': totalAdoptions,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
