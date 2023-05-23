import 'package:shared_preferences/shared_preferences.dart';


mixin PrefsMixin {
   
  late SharedPreferences prefs;
@override
void initState() {
  set_prefs();
  
}  
  @override
  set_prefs()async{
   prefs = await SharedPreferences.getInstance();
 }

}
