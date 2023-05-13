import 'package:flutter/material.dart';

class ListDropDownButton extends StatefulWidget {
  final List<String> list;
  final Function onChanged;
  double? width;
   ListDropDownButton({super.key, required this.list, required this.onChanged, this.width});

  @override
  State<ListDropDownButton> createState() => _DropDownButtonState();
}

class _DropDownButtonState extends State<ListDropDownButton> {
  String? dropdownValue ;
  @override
  Widget build(BuildContext context) {
    dropdownValue =  widget.list.first;
    return Container(
      width: widget.width?? MediaQuery.of(context).size.width/3,
      constraints: BoxConstraints(maxHeight: 30,minHeight: 20,maxWidth: 200,minWidth: 50),
      alignment: Alignment.center,
      child: Theme(
  data: ThemeData(
      canvasColor: Colors.white,
      primaryColor: Colors.black,
      dividerColor: Colors.black,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(3.5),
        ),
      ),
  ),
  child: DropdownButtonFormField<String>(
      
      value: dropdownValue,
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue;
        });
        widget.onChanged(newValue);
      },
      items: widget.list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        hintText: 'Select an item',
      ),
  ),
),
    );

  }
}
