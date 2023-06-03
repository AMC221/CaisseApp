import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import 'package:get/get.dart';
import 'package:youmazgestion/Models/users.dart';

class UserController extends GetxController {
  final _username = ''.obs;
  final _email = ''.obs;
  final _role = ''.obs;
  final _name = ''.obs;
  final _lastname = ''.obs;
  final _password = ''.obs;


  String get username => _username.value;
  String get email => _email.value;
  String get role => _role.value;
  String get name => _name.value;
  String get lastname => _lastname.value;
  String get password => _password.value;

  void setUser(Users user) {
    _username.value = user.username;
    print(_username.value);
    _email.value = user.email;
    print(_email.value);
    _role.value = user.role;
    print(_role.value);
    _name.value = user.name;
    print(_name.value);
    _lastname.value = user.lastName;
    print(_lastname.value);
    _password.value = user.password;
    print(_password.value);

  }
}
