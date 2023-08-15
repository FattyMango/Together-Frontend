import 'package:flutter/material.dart';
import 'package:together/deserializers/user.dart';
import 'package:together/request/requests.dart';

import '../../../misc/backend.dart';

class SetOnlineButton extends StatefulWidget {
  final UserDeserializer user;
  final bool is_online;
  final Function set_is_online;
  const SetOnlineButton({super.key, required this.user, required this.set_is_online, required this.is_online});

  @override
  State<SetOnlineButton> createState() => _SetOnlineButtonState();
}

class _SetOnlineButtonState extends State<SetOnlineButton> {
  set_online() async {
      Map<String, dynamic> res = await put_request(url: apiUrl+"/user/api/volunteer/setonline/", body: {"is_online":(!widget.is_online).toString()},headers: {"Authorization":"Token "+widget.user.token});
      if(res["response"]=="Error") return;
      widget.set_is_online(res);
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
      child: ElevatedButton(
        onPressed: () async => { await set_online()},
        child: Text(widget.is_online?"Online":"Offline",style: TextStyle(fontSize: 50),),
        style: ElevatedButton.styleFrom(fixedSize: Size(200, 200),backgroundColor: widget.is_online?Colors.green:Colors.grey),
      ),
    );
  }
}
