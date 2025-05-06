import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDatabase {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? _chatsCollection;

  FirestoreDatabase() {
    _setupCollectionsReferences();
  }

  void _setupCollectionsReferences() {
    _chatsCollection = _firebaseFirestore.collection("chats");
  }

  Stream<QuerySnapshot> getChatMessages(String participantsKey) async* {
    final snapshot =
        await _chatsCollection!
            .where('participantsKey', isEqualTo: participantsKey)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final chatId = snapshot.docs.first.id;

      yield* _chatsCollection!
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      yield* const Stream.empty();
    }
  }
}
