// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polling/screens/qrCode.dart';
import 'package:polling/utils/snackBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_polls/models/poll_models.dart';
import 'package:simple_polls/widgets/polls_widget.dart';

class MyPollsScreen extends StatefulWidget {
  MyPollsScreen({super.key});

  @override
  State<MyPollsScreen> createState() => _MyPollsScreenState();
}

class _MyPollsScreenState extends State<MyPollsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> entries = <String>['A', 'B', 'C'];

  final List<int> colorCodes = <int>[600, 500, 100];

  int? _selectedOption = 1;

  bool? isUser;

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isUser = prefs.getBool('user')!;
    return isUser;
  }

  @override
  Widget build(BuildContext context) {
    final quesEdit = TextEditingController();
    final op1Edit = TextEditingController();
    final op2Edit = TextEditingController();
    final op3Edit = TextEditingController();
    final op4Edit = TextEditingController();
    final daysEdit = TextEditingController();

    return Scaffold(
      body: FutureBuilder(
        future: getUser(),
        builder: (context, snapshot) {
          if (snapshot.data == false) {
            return userLoggedOut();
          } else {
            return userLoggedIn(context, quesEdit, op1Edit, op2Edit, op3Edit,
                op4Edit, daysEdit);
          }
        },
        // child: getUser()
        //     ? userLoggedIn(
        //         context, quesEdit, op1Edit, op2Edit, op3Edit, op4Edit, daysEdit)
        //     : userLoggedOut(),
      ),
    );
  }

  Widget userLoggedOut() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        registerWithEmailAndPassword(
                          emailController.text,
                          passwordController.text,
                        );
                      },
                      child: Text('Register'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        signInWithEmailAndPassword(
                          emailController.text,
                          passwordController.text,
                        );
                      },
                      child: Text('Login'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      // Login successful, you can now handle the authenticated user.

      setState(() {
        isUser = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user', true);
    } catch (e) {
      CustomSnackBar(
          context,
          Text(
            'Error : ${e.toString()}',
            style: TextStyle(color: Colors.white),
          ));
    }
  }

  Future<void> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      // Registration successful, you can now handle the new user or proceed to login.

      setState(() {
        isUser = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user', true);
    } catch (e) {
      CustomSnackBar(
          context,
          Text(
            'Error : ${e.toString()}',
            style: TextStyle(color: Colors.white),
          ));
    }
  }

  Widget userLoggedIn(
      BuildContext context,
      TextEditingController quesEdit,
      TextEditingController op1Edit,
      TextEditingController op2Edit,
      TextEditingController op3Edit,
      TextEditingController op4Edit,
      TextEditingController daysEdit) {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
        appBar: AppBar(
          title: Text('My Polls'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                _auth.currentUser != null ? Icons.logout : null,
                color: Colors.blue,
              ),
              onPressed: () async {
                _auth.signOut();
                setState(() {
                  isUser = false;
                });

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('user', false);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (_auth.currentUser == null) {
              _auth.signOut();
              setState(() {
                isUser = false;
              });

              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('user', false);
            } else {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
                  final TextEditingController quesEdit =
                      TextEditingController();
                  final TextEditingController op1Edit = TextEditingController();
                  final TextEditingController op2Edit = TextEditingController();
                  final TextEditingController op3Edit = TextEditingController();
                  final TextEditingController op4Edit = TextEditingController();
                  final TextEditingController daysEdit =
                      TextEditingController();
                  int _selectedOption = 1;

                  return AlertDialog(
                    title: const Text('Create a Poll'),
                    content: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    controller: quesEdit,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Question',
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter a question';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    controller: op1Edit,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: '1st Choice',
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter the first choice';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    controller: op2Edit,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: '2nd Choice',
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter the second choice';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    controller: op3Edit,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: '3rd Choice',
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter the third choice';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    controller: op4Edit,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: '4th Choice',
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter the fourth choice';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: TextFormField(
                                    controller: daysEdit,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Days',
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter the number of days';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                RadioListTile(
                                  title: Text('Poll \'Editable\''),
                                  value: 1,
                                  groupValue: _selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption = value!;
                                    });
                                  },
                                ),
                                RadioListTile(
                                  title: Text('Poll \'Non Editable\''),
                                  value: 2,
                                  groupValue: _selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption = value!;
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Save'),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final collectionReference = FirebaseFirestore
                                .instance
                                .collection('All_Polls');
                            final documentReference = collectionReference.doc();

                            int days = int.parse(daysEdit.text);

                            bool? isEdi;
                            if (_selectedOption == 1) {
                              isEdi = true;
                            } else if (_selectedOption == 2) {
                              isEdi = false;
                            }

                            documentReference
                                .set({
                                  'myUID': _auth.currentUser!.uid,
                                  'Question': quesEdit.text,
                                  'op1': op1Edit.text,
                                  'op2': op2Edit.text,
                                  'op3': op3Edit.text,
                                  'op4': op4Edit.text,
                                  'daysRemaining': days,
                                  'editablePoll': isEdi,
                                  'hasVoted': false,
                                  'totalPolls': 0
                                })
                                .then((value) =>
                                    print('String pushed to Firebase'))
                                .catchError((error) =>
                                    print('Failed to push string: $error'));

                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('All_Polls')
                .where('myUID', isEqualTo: uid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return new Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Loading...",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        height: 50.0,
                      ),
                      CircularProgressIndicator()
                    ],
                  ),
                );
              } else {
                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data!.size,
                  itemBuilder: (BuildContext context, int index) {
                    return SimplePollsWidget(
                      onSelection: (PollFrameModel model,
                          PollOptions selectedOptionModel) {
                        print('Now total polls are : ' +
                            model.totalPolls.toString());
                        print('Selected option has label : ' +
                            selectedOptionModel.label);
                      },
                      onReset: (PollFrameModel model) {
                        print(
                            'Poll has been reset, this happens only in case of editable polls');
                      },
                      optionsBorderShape: StadiumBorder(),
                      model: PollFrameModel(
                        title: Container(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                snapshot.data!.docs[index]["Question"],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              InkWell(
                                  onTap: (){

                                    Navigator.of(context).push(
                                        CupertinoPageRoute(builder: (BuildContext context)=>
                                            CreateQrCode(textQrCode: snapshot.data!.docs[index]["Question"],nextString: snapshot.data!.docs[index]["op1"],)));
                                  },
                                  child: Icon(Icons.share))
                            ],
                          ),
                        ),
                        totalPolls: snapshot.data!.docs[index]["totalPolls"],
                        endTime: DateTime.now().toUtc().add(Duration(
                            days: snapshot.data!.docs[index]["daysRemaining"])),
                        hasVoted: snapshot.data!.docs[index]["hasVoted"],
                        editablePoll: snapshot.data!.docs[index]
                            ["editablePoll"],
                        options: <PollOptions>[
                          PollOptions(
                            label: snapshot.data!.docs[index]["op1"],
                            pollsCount: 0,
                            isSelected: false,
                            id: 1,
                          ),
                          PollOptions(
                            label: snapshot.data!.docs[index]["op2"],
                            pollsCount: 0,
                            isSelected: false,
                            id: 2,
                          ),
                          PollOptions(
                            label: snapshot.data!.docs[index]["op3"],
                            pollsCount: 0,
                            isSelected: false,
                            id: 3,
                          ),
                          PollOptions(
                            label: snapshot.data!.docs[index]["op4"],
                            pollsCount: 0,
                            isSelected: false,
                            id: 3,
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                );
              }
            },
          ),
        ));
  }
}
