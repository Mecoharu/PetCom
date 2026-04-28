import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/adoption_post.dart';
import '../models/adoption_application.dart';
import 'auth_service.dart';
import 'notification_service.dart';


final adoptionServiceProvider = Provider<AdoptionService>((ref) {
  final user = ref.watch(currentUserProvider);
  return AdoptionService(currentUserId: user?.uid ?? '');
});

final allPostsProvider = StreamProvider<List<AdoptionPost>>((ref) {
  return FirebaseFirestore.instance
      .collection('adoption_posts')
      .where('status', isEqualTo: PostStatus.open.name)
      .snapshots()
      .map((s) {
        final list = s.docs.map((d) => AdoptionPost.fromFirestore(d)).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });
});

final myPostsProvider = StreamProvider<List<AdoptionPost>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('adoption_posts')
      .where('ownerId', isEqualTo: uid)
      .snapshots()
      .map((s) {
        final list = s.docs.map((d) => AdoptionPost.fromFirestore(d)).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });
});

final myApplicationsProvider = StreamProvider<List<AdoptionApplication>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('applications')
      .where('applicantId', isEqualTo: uid)
      .snapshots()
      .map((s) {
        final list =
            s.docs.map((d) => AdoptionApplication.fromFirestore(d)).toList();
        list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
        return list;
      });
});

final postApplicationsProvider =
    StreamProvider.family<List<AdoptionApplication>, String>((ref, postId) {
  return FirebaseFirestore.instance
      .collection('applications')
      .where('postId', isEqualTo: postId)
      .snapshots()
      .map((s) {
        final list =
            s.docs.map((d) => AdoptionApplication.fromFirestore(d)).toList();
        list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
        return list;
      });
});

class AdoptionService {
  final _db = FirebaseFirestore.instance;
  
  final String currentUserId;
  final _uuid = const Uuid();

  AdoptionService({required this.currentUserId});

  // CREATE Post
  Future<String> createPost({
    required AdoptionPost post,
  }) async {
    // Just save the post directly to Firestore Database
    await _db
        .collection('adoption_posts')
        .doc(post.id)
        .set(post.toFirestore());

    await _db.collection('users').doc(currentUserId).set(
      {'totalPosts': FieldValue.increment(1)},
      SetOptions(merge: true),
    );

    return post.id;
  }

  Future<AdoptionPost?> getPost(String id) async {
    final doc = await _db.collection('adoption_posts').doc(id).get();
    if (!doc.exists) return null;
    return AdoptionPost.fromFirestore(doc);
  }

  // UPDATE Post
  Future<void> updatePost(AdoptionPost post) async {
    await _db
        .collection('adoption_posts')
        .doc(post.id)
        .update(post.toFirestore());
  }

  // DELETE Post
  Future<void> deletePost(AdoptionPost post) async {

    final apps = await _db
        .collection('applications')
        .where('postId', isEqualTo: post.id)
        .get();
    final batch = _db.batch();
    for (final d in apps.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_db.collection('adoption_posts').doc(post.id));
    await batch.commit();

    await _db.collection('users').doc(currentUserId).set(
      {'totalPosts': FieldValue.increment(-1)},
      SetOptions(merge: true),
    );
  }

  Future<String> applyToAdopt({
    required AdoptionApplication application,
    required String ownerFcmToken,
  }) async {
    final batch = _db.batch();

    batch.set(
      _db.collection('applications').doc(application.id),
      application.toFirestore(),
    );

    batch.update(_db.collection('adoption_posts').doc(application.postId), {
      'applicantIds': FieldValue.arrayUnion([application.applicantId]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    await batch.commit();

    await NotificationService.showLocalNotification(
      id: application.id.hashCode,
      title: '🐾 Adoption Request!',
      body:
          '${application.applicantName} want to adopt ${application.petName}',
    );

    return application.id;
  }

  Future<void> updateApplicationStatus({
    required AdoptionApplication application,
    required ApplicationStatus newStatus,
    required AdoptionPost post,
  }) async {
    final batch = _db.batch();

    batch.update(_db.collection('applications').doc(application.id), {
      'status': newStatus.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    if (newStatus == ApplicationStatus.approved) {
      batch.update(_db.collection('adoption_posts').doc(post.id), {
        'status': PostStatus.adopted.name,
        'adoptedById': application.applicantId,
        'adoptedByName': application.applicantName,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      batch.set(
        _db.collection('users').doc(application.applicantId),
        {'totalAdoptions': FieldValue.increment(1)},
        SetOptions(merge: true),
      );

      await NotificationService.showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'Adoption Approved!',
        body: 'Your adoption request for ${application.petName} has been approved!',
      );
    } else if (newStatus == ApplicationStatus.rejected) {
      await NotificationService.showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'Adoption Request',
        body: 'Sorry, your adoption request for ${application.petName} was not successful.',
      );
    }

    await batch.commit();
  }

  Future<void> changePostStatus(String postId, PostStatus status) async {
    await _db.collection('adoption_posts').doc(postId).update({
      'status': status.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
AdoptionPost buildPost({
    required String ownerName,
    required String ownerPhotoUrl,
    required String petName,
    required PetType petType,
    required String breed,
    required int ageMonths,
    required PetGender gender,
    required String description,
    required bool isVaccinated,
    required bool isNeutered,
    required String location,
  }) =>
      AdoptionPost(
        id: _uuid.v4(),
        ownerId: currentUserId,
        ownerName: ownerName,
        ownerPhotoUrl: ownerPhotoUrl,
        petName: petName,
        petType: petType,
        breed: breed,
        ageMonths: ageMonths,
        gender: gender,
        description: description,
        photoUrls: [], // Data gambar dikelola melalui Firestore
        isVaccinated: isVaccinated,
        isNeutered: isNeutered,
        location: location,
        status: PostStatus.open,
        applicantIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );


AdoptionApplication buildApplication({
  required String postId,
  required String petName,
  required String applicantName,
  required String applicantEmail,
  required String applicantPhone,
  required String reason,
  required String housingType,
  required bool hasPetsAlready,
  String? additionalInfo,
}) =>
    AdoptionApplication(
      id: _uuid.v4(),
      postId: postId,
      petName: petName,
      applicantId: currentUserId,
      applicantName: applicantName,
      applicantEmail: applicantEmail,
      applicantPhone: applicantPhone,
      reason: reason,
      housingType: housingType,
      hasPetsAlready: hasPetsAlready,
      additionalInfo: additionalInfo,
      status: ApplicationStatus.pending,
      appliedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
}