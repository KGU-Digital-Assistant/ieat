import 'dart:convert';

import 'package:http_parser/http_parser.dart' as htpar;

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ieat/provider.dart';
import 'package:ieat/util.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'package:provider/src/provider.dart' as pcgpv;
import 'package:provider/src/provider.dart' as ppv;
import 'dart:io';
import 'package:http_parser/http_parser.dart' as htpr;
import 'package:mime/mime.dart' as mime;
import 'main.dart';
import 'moose.dart';

Future<void> runMoose(BuildContext context,String imagePath, bool save) async {
  String? tk = await getTk();
  final Map<String, String> headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $tk',
  };

  const String apiUrl = '$url/meal_hour/upload_temp';
// 앱(Android/iOS) 환경에서의 처리
  final File imageFile = File(imagePath);

  // 파일의 MIME 타입 가져오기
  final mimeType = mime.lookupMimeType(imageFile.path) ??
      'application/octet-stream'; // 기본값 설정

  var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
    ..headers.addAll(headers)
    ..files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: htpr.MediaType('image', 'jpeg'), // 파일의 MIME 타입 설정
    ));

  final response = await request.send();
  if (response.statusCode == 200) {
    print('이미지 업로드 성공');
    final responseData = await http.Response.fromStream(response);
    var utf8Res = utf8.decode(responseData.bodyBytes);
    Map<String, dynamic> formatdata = jsonDecode('$utf8Res');
    print('Response body: $formatdata');
    final dpv = ppv.Provider.of<OneFoodDetail>(context,listen: false);
    dpv.setInfo(formatdata);
    dpv.setMooseSuc(true);
    NvgToNxtPageSlide(context, MooseDetail(type: "영양소 분석",save: save,));
  } else {
    print('업로드 실패: ${response.statusCode}');
  }
}



