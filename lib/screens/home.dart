import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simple_polls/models/poll_models.dart';
import 'package:simple_polls/widgets/polls_widget.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<String> entries = <String>['A', 'B', 'C', 'D', 'E', 'F'];
  final List<int> colorCodes = <int>[600, 500, 100];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("All_Polls").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
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
                  onSelection:
                      (PollFrameModel model, PollOptions selectedOptionModel) {
                    print(
                        'Now total polls are : ' + model.totalPolls.toString());
                    print('Selected option has label : ' +
                        selectedOptionModel.label);
                  },
                  onReset: (PollFrameModel model) {
                    print(
                        'Poll has been reset, this happens only in case of editable polls');
                  },
                  optionsBorderShape: const StadiumBorder(),
                  model: PollFrameModel(
                    title: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        snapshot.data!.docs[index]["Question"],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    totalPolls: snapshot.data!.docs[index]["totalPolls"],
                    endTime: DateTime.now().toUtc().add(Duration(
                        days: snapshot.data!.docs[index]["daysRemaining"])),
                    hasVoted: snapshot.data!.docs[index]["hasVoted"],
                    editablePoll: snapshot.data!.docs[index]["editablePoll"],
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
    );
  }
}
