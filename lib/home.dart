import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

TextEditingController taskController = TextEditingController();

TextEditingController taskeditcontroller = TextEditingController();
addData() async {
  await FirebaseFirestore.instance.collection("task").add({
    'task': taskController.text,
    'date':
        '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}-${DateTime.now().timeZoneName}'
  });
  taskController.clear();
}

class _HomeState extends State<Home> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection("task").snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: StreamBuilder(
              stream: _usersStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['task']),
                      subtitle: Text(data['date']),
                      trailing: Wrap(
                        spacing: 1,
                        children: [
                          IconButton(onPressed: (){
                            document.reference.delete();
                          }, icon: Icon(Icons.delete) ),
                          IconButton(onPressed: (){
                            showDialog(context: context, 
                            builder: (context){
                              return AlertDialog(
                                title: Text("update task"),
                                content: Column(
                                  children: [
                                    TextField(
                                      controller: taskeditcontroller,
                                    ),
                                    ElevatedButton(onPressed: (){
                                      document.reference.update({});
                                    }, child: Text("update"))
                                  ],
                                ),
                              );
                            }
                            );
                          }, icon: Icon(Icons.update))
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),
        ),
        Center(
          child: Column(
            children: [
              Container(
                width: 204,
                child: Card(
                  child: TextField(
                    controller: taskController,
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    addData();
                  },
                  child: const Text("Add"))
            ],
          ),
        ),
      ]),
    );
  }
}
