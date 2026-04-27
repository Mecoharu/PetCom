import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus { pending, approved, rejected }

class AdoptionApplication {
  final String id;
  final String postId;
  final String petName;
  final String applicantId;
  final String applicantName;
  final String applicantEmail;
  final String applicantPhone;
  final String reason;
  final String housingType;
  final bool hasPetsAlready;
  final String? additionalInfo;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime updatedAt;

  AdoptionApplication({
    required this.id,
    required this.postId,
    required this.petName,
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    required this.applicantPhone,
    required this.reason,
    required this.housingType,
    required this.hasPetsAlready,
    this.additionalInfo,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
  });

  String get statusLabel {
    switch (status) {
      case ApplicationStatus.pending: return 'Waiting';
      case ApplicationStatus.approved: return 'Accepted';
      case ApplicationStatus.rejected: return 'Rejected';
    }
  }

  factory AdoptionApplication.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AdoptionApplication(
      id: doc.id,
      postId: d['postId'] ?? '',
      petName: d['petName'] ?? '',
      applicantId: d['applicantId'] ?? '',
      applicantName: d['applicantName'] ?? '',
      applicantEmail: d['applicantEmail'] ?? '',
      applicantPhone: d['applicantPhone'] ?? '',
      reason: d['reason'] ?? '',
      housingType: d['housingType'] ?? '',
      hasPetsAlready: d['hasPetsAlready'] ?? false,
      additionalInfo: d['additionalInfo'],
      status: ApplicationStatus.values.firstWhere(
          (e) => e.name == d['status'],
          orElse: () => ApplicationStatus.pending),
      appliedAt: (d['appliedAt'] as Timestamp).toDate(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'postId': postId,
        'petName': petName,
        'applicantId': applicantId,
        'applicantName': applicantName,
        'applicantEmail': applicantEmail,
        'applicantPhone': applicantPhone,
        'reason': reason,
        'housingType': housingType,
        'hasPetsAlready': hasPetsAlready,
        'additionalInfo': additionalInfo,
        'status': status.name,
        'appliedAt': Timestamp.fromDate(appliedAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
