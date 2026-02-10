import 'package:dio/dio.dart';

class DioClient {
  static final Dio dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3001/api',
      headers: {'Content-Type': 'application/json'}));
}

class WebhookSiteClient {
  static final Dio dio = Dio(BaseOptions(
      baseUrl: 'https://webhook.site/d5116ffb-91cb-4221-8d23-e231d6ccee6c',
      headers: {'Content-Type': 'application/json'}));
}