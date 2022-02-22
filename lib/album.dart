import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CallApi{

  final String _url = 'http://flutterapi.brotherdev.com/';
  postData(data, apiUrl) async{
    var fullUrl = _url + apiUrl;
    return await http.post(
      Uri.parse(fullUrl),
      body: json.encode(data),
      headers: _setHeaders(),
    );
  }

  _setHeaders() => {
    'Content-type': 'application/json',
    'Accept -type': 'application/json',
  };

}