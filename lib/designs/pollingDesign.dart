import 'package:flutter/material.dart';
import 'package:simple_polls/models/poll_models.dart';
import 'package:simple_polls/widgets/polls_widget.dart';

class PollingDesign extends StatelessWidget {
  const PollingDesign({super.key});

  @override
  Widget build(BuildContext context) {
    return SimplePollsWidget(
      onSelection: (PollFrameModel model, PollOptions selectedOptionModel) {
        print('Now total polls are : ' + model.totalPolls.toString());
        print('Selected option has label : ' + selectedOptionModel.label);
      },
      onReset: (PollFrameModel model) {
        print(
            'Poll has been reset, this happens only in case of editable polls');
      },
      optionsBorderShape:
          StadiumBorder(), //Its Default so its not necessary to write this line
      model: PollFrameModel(
        title: Container(
          alignment: Alignment.centerLeft,
          child: Text(
            'This is the title of poll. This is the title of poll. This is the title of poll.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        totalPolls: 100,
        endTime: DateTime.now().toUtc().add(Duration(days: 10)),
        hasVoted: false,
        editablePoll: true,
        options: <PollOptions>[
          PollOptions(
            label: "Option 1",
            pollsCount: 40,
            isSelected: false,
            id: 1,
          ),
          PollOptions(
            label: "Option 2",
            pollsCount: 25,
            isSelected: false,
            id: 2,
          ),
          PollOptions(
            label: "Option 3",
            pollsCount: 35,
            isSelected: false,
            id: 3,
          ),
        ],
      ),
    );
  }
}
