import 'package:cloud_firestore/cloud_firestore.dart';

enum PetType { dog, cat, bird, reptile, other }
enum PetGender { male, female }
enum PostStatus { open, inReview, adopted, closed }

class AdoptionPost {
  final String id;
  final String ownerId;
  final String ownerName;
  final String ownerPhotoUrl;
  final String petName;
  final PetType petType;
  final String breed;
  final int ageMonths;
  final PetGender gender;
  final String description;
  final List<String> photoUrls;
  final bool isVaccinated;
  final bool isNeutered;
  final String location;
  final PostStatus status;
  final List<String> applicantIds;
  final String? adoptedById;
  final String? adoptedByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdoptionPost({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhotoUrl,
    required this.petName,
    required this.petType,
    required this.breed,
    required this.ageMonths,
    required this.gender,
    required this.description,
    required this.photoUrls,
    required this.isVaccinated,
    required this.isNeutered,
    required this.location,
    required this.status,
    required this.applicantIds,
    this.adoptedById,
    this.adoptedByName,
    required this.createdAt,
    required this.updatedAt,
  });

  String get typeEmoji {
    switch (petType) {
      case PetType.dog: return '🐕';
      case PetType.cat: return '🐈';
      case PetType.bird: return '🦜';
      case PetType.reptile: return '🦎';
      case PetType.other: return '🐾';
    }
  }

  String get typeLabel {
    switch (petType) {
      case PetType.dog: return 'Dog';
      case PetType.cat: return 'Cat';
      case PetType.bird: return 'Bird';
      case PetType.reptile: return 'Reptil';
      default:return 'other';
    }
  }

  String get genderLabel => gender == PetGender.male ? 'Male' : 'Female';
  String get genderEmoji => gender == PetGender.male ? '♂' : '♀';



  String get ageLabel {
    if (ageMonths < 12) return '$ageMonths bulan';
    final y = ageMonths ~/ 12;
    final m = ageMonths % 12;
    if (m == 0) return '$y tahun';
    return '$y thn $m bln';
  }

  String get statusLabel {
    switch (status) {
      case PostStatus.open: return 'Available';
      case PostStatus.inReview: return 'Processing';
      case PostStatus.adopted: return 'Adopted';
      case PostStatus.closed: return 'Closed';
    }
  }

  bool get isAvailable => status == PostStatus.open;

  factory AdoptionPost.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AdoptionPost(
      id: doc.id,
      ownerId: d['ownerId'] ?? '',
      ownerName: d['ownerName'] ?? '',
      ownerPhotoUrl: d['ownerPhotoUrl'] ?? '',
      petName: d['petName'] ?? '',
      petType: PetType.values.firstWhere(
          (e) => e.name == d['petType'], orElse: () => PetType.other),
      breed: d['breed'] ?? '',
      ageMonths: d['ageMonths'] ?? 0,
      gender: PetGender.values.firstWhere(
          (e) => e.name == d['gender'], orElse: () => PetGender.male),
      description: d['description'] ?? '',
      photoUrls: List<String>.from(d['photoUrls'] ?? []),
      isVaccinated: d['isVaccinated'] ?? false,
      isNeutered: d['isNeutered'] ?? false,
      location: d['location'] ?? '',
      status: PostStatus.values.firstWhere(
          (e) => e.name == d['status'], orElse: () => PostStatus.open),
      applicantIds: List<String>.from(d['applicantIds'] ?? []),
      adoptedById: d['adoptedById'],
      adoptedByName: d['adoptedByName'],
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'ownerId': ownerId,
        'ownerName': ownerName,
        'ownerPhotoUrl': ownerPhotoUrl,
        'petName': petName,
        'petType': petType.name,
        'breed': breed,
        'ageMonths': ageMonths,
        'gender': gender.name,
        'description': description,
        'photoUrls': photoUrls,
        'isVaccinated': isVaccinated,
        'isNeutered': isNeutered,
        'location': location,
        'status': status.name,
        'applicantIds': applicantIds,
        'adoptedById': adoptedById,
        'adoptedByName': adoptedByName,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  AdoptionPost copyWith({
    String? petName,
    PetType? petType,
    String? breed,
    int? ageMonths,
    PetGender? gender,
    String? description,
    List<String>? photoUrls,
    bool? isVaccinated,
    bool? isNeutered,
    String? location,
    PostStatus? status,
    List<String>? applicantIds,
    String? adoptedById,
    String? adoptedByName,
  }) =>
      AdoptionPost(
        id: id,
        ownerId: ownerId,
        ownerName: ownerName,
        ownerPhotoUrl: ownerPhotoUrl,
        petName: petName ?? this.petName,
        petType: petType ?? this.petType,
        breed: breed ?? this.breed,
        ageMonths: ageMonths ?? this.ageMonths,
        gender: gender ?? this.gender,
        description: description ?? this.description,
        photoUrls: photoUrls ?? this.photoUrls,
        isVaccinated: isVaccinated ?? this.isVaccinated,
        isNeutered: isNeutered ?? this.isNeutered,
        location: location ?? this.location,
        status: status ?? this.status,
        applicantIds: applicantIds ?? this.applicantIds,
        adoptedById: adoptedById ?? this.adoptedById,
        adoptedByName: adoptedByName ?? this.adoptedByName,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
