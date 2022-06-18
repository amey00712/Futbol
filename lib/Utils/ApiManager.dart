import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

final hostName = "https://futbolfirst.net/admin/API/";

class ApiManager {
  ApiManager() {}

  Future<dynamic> get(String url) async {
    url = hostName + url + "/format/json";
    print("URL: $url");

    http.Response response = await http.get(Uri.parse(url));

    log("API Response: ${response.body}");
    return jsonDecode(response.body);
  }

  Future<dynamic> post(String url, dynamic param) async {
    url = hostName + url;

    http.Response response = await http.post(Uri.parse(url),

        body: param);

   // print("URL: $url");
    print("Body: $param");
   // log("API Response: ${response.body}");

    return json.decode(response.body);
  }
}
