import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_management_app/models/note.dart';

class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  Future<void> addNote(Note note) {
    return notes.add({
      'title': note.title,
      'description': note.description,
    });
  }

  Stream<QuerySnapshot> getNotes() {
    return notes.snapshots();
  }

  Future<void> updateNote(Note note) {
    return notes.doc(note.id).update({
      'title': note.title,
      'description': note.description,
    });
  }

  Future<void> deleteNote(String id) {
    return notes.doc(id).delete();
  }
}