import 'package:flutter/material.dart';
import 'package:together/pages/theme_container.dart';

import '../../../deserializers/user.dart';
import '../../buttons/send_request.dart';
import '../../classes/request.dart';

class SetConstraints extends StatefulWidget {
  final Function submit_request;
  final UserDeserializer user;
  final Request request;
  const SetConstraints(
      {super.key,
      required this.submit_request,
      required this.user,
      required this.request});

  @override
  State<SetConstraints> createState() => _SetConstraintsState();
}

class _SetConstraintsState extends State<SetConstraints> {
  String gender_constraint = "N";

  late String description;
  @override
  void initState() {
    // TODO: implement initState
    description= "";
    super.initState();
  }

  // Widget get GenderField => Padding(
  //       padding: const EdgeInsets.only(top: 0, bottom: 10, left: 20),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Checkbox(
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(3.5)),
  //             activeColor: Colors.greenAccent.shade700,
  //             checkColor: Colors.white,
  //             value: gender_constraint,
  //             onChanged: (bool? value) {
  //               setState(() {
  //                 gender_constraint = value!;
  //               });
  //             },
  //           ),
  //           Text(
  //               "${gender_constraint ? "Yes i need a ${widget.user.gender == "M" ? "male" : "female"}" : "No it does not matter"} ",
  //               style: TextStyle(
  //                   color: Colors.black,
  //                   fontSize: 20,
  //                   decoration: TextDecoration.none)),
  //         ],
  //       ),
  //     );

  Widget get DescriptionField => Padding(
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
        child: SizedBox(
          height: 60,
          child: TextFormField(
            onChanged: (value) {
              setState(() {
                description = value;
              });
            },
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              filled: true,
              hintText: 'I need to go to my class...',
            ),
          ),
        ),
      );

  Widget get SubmitButton => Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Container(
            child: SendRequestButton(submit_request: () {
              widget.request.gender = gender_constraint;
              widget.request.description = description;
              return widget.submit_request(widget.request);
            }),
          ),
        ),
      );
  Widget HeaderText({required String text,double size=30}) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(text,
              style: TextStyle(
                color: Colors.blueGrey.shade800,
                fontSize: size,
                fontWeight: FontWeight.w700,
              )),
        ],
      );
  Widget get CoverImage => Image.asset(
        "assets/images/volunteer.png",
        alignment: Alignment.center,
        fit: BoxFit.cover,
      );
  @override
  Widget build(BuildContext context) {
    return ThemeContainer(children: [
      Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              verticalDirection: VerticalDirection.down,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HeaderText(
                    text: "Do you have a gender constraint?",size: 24),
                Column(
                  children: [
                    ListTile(
                      title: const Text('Male'),
                      leading: Radio<String>(
                        value: "M",
                        groupValue: gender_constraint,
                        onChanged: (String? value) {
                          setState(() {
                            print("here");
                            gender_constraint = "M";
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Female'),
                      leading: Radio<String>(
                        value: "F",
                        groupValue: gender_constraint,
                        onChanged: (String? value) {
                          setState(() {
                            print("here2");
                            gender_constraint = "F";
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('None'),
                      leading: Radio<String>(
                        value: "N",
                        groupValue: gender_constraint,
                        onChanged: (String? value) {
                          setState(() {
                            print("here3");
                            gender_constraint = "N";
                          });
                        },
                      ),
                    )
                  ],
                ),
                // GenderField,
                SizedBox(
                  height: 20,
                ),
                HeaderText(
                    text:"What is your need?"),
                DescriptionField,
                SizedBox(
                  height: 20,
                ),
                CoverImage,
                SubmitButton
              ])),
    ]);
  }
}
