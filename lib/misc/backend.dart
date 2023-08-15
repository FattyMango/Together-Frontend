
String domain = "localhost";
String apiUrl = "http:{domain}".replaceFirst("{domain}", domain);

String websocketUrl = "ws:{domain}".replaceFirst("{domain}", domain);