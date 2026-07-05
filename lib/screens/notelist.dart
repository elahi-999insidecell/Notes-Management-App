// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_management_app/models/note.dart';
import 'package:notes_management_app/screens/addnote.dart';
import 'package:notes_management_app/services/firestore_services.dart';

class Notelist extends StatefulWidget {
  const Notelist({super.key});

  @override
  State<Notelist> createState() => NotelistState();
}

class NotelistState extends State<Notelist> {
  //firestore service instance
  final FirestoreService firestoreService = FirestoreService();

  Future<void> _openAddNote() async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const Addnote()),
  );
}
 

  Future<void> _editNote(Note note) async {
    final TextEditingController titleController =
        TextEditingController(text: note.title);
    final TextEditingController descriptionController =
        TextEditingController(text: note.description);

    final Note? updatedNote = await showDialog<Note>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 12,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              
              onPressed: () => Navigator.pop(dialogContext),
              child:  Text('Cancel', style: TextStyle(color: Color.fromARGB(255, 189, 106, 75)),),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color.fromARGB(255, 189, 106, 75)),
              onPressed: () {
                final String newTitle = titleController.text.trim();
                final String newDescription =
                    descriptionController.text.trim();
                Navigator.pop(
                  dialogContext,
                  Note(
                    id: note.id,
                    title: newTitle.isEmpty ? 'Untitled' : newTitle,
                    description: newDescription,
                  ),
                );
              },
            
              child:  Text('Save'),
            ),
          ],
        );
      },
    );

    if (updatedNote != null) {
      
        await firestoreService.updateNote(updatedNote);
     
    }
  }

  void _deleteNote(String id) async {
  await firestoreService.deleteNote(id);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Note deleted')),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes Management App'),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 189, 106, 75),
      ),
      body: StreamBuilder<QuerySnapshot>(
  stream: firestoreService.getNotes(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
  return Center(
    child: Text('Error: ${snapshot.error}'),
  );
}

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(
        child: Text('No notes yet. Tap + to add one.'),
      );
    }

    final docs = snapshot.data!.docs;

    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];

        final note = Note(
          id: doc.id,
          title: doc['title'],
          description: doc['description'],
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(
              note.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              note.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green),
                  onPressed: () => _editNote(note),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteNote(note.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  },
),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddNote,
        backgroundColor: const Color.fromARGB(255, 189, 106, 75),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}