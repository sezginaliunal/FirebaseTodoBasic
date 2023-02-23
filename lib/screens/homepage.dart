import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo/screens/todo_add.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionReference todoCollection =
      FirebaseFirestore.instance.collection('Todos');

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> todoStream = todoCollection.snapshots();
    return Scaffold(
      appBar: AppBar(
        title: Text("My Todos"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: todoStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("No Data"),
                ],
              ),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['todoName']),
                subtitle: Text(data['todoDescription']),
                trailing: IconButton(
                  onPressed: () {
                    _deleteDialog(context, document);
                  },
                  icon: Icon(Icons.delete),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddTodoPage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<dynamic> _deleteDialog(
      BuildContext context, DocumentSnapshot<Object?> document) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure do you want delete this ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('Todos')
                    .doc(document.id)
                    .delete();
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
