import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/project_model.dart';
import '../view_model/project_view_model.dart';

class ApiEndpoint {
  ApiEndpoint._(); // Không cho khởi tạo instance

  static const String login         = '/oauth/token';
  static const String projects      = '/v4/cases/';
  static const String profile       = '/v4/users/profile/';
  static const String clearSession  = '/v4/users/session/clear_session/';
  static const String languages     = '/masters/languages';
  static const String forgotPassword = '/dbconnections/change_password';

// Thêm endpoint mới vào đây
}



