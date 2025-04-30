import 'package:energymanagement/components/models/UserModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends StateNotifier<UserModel?>{
  AuthNotifier() : super(null);

  void setCurrentUser(UserModel currentUser){
    state = currentUser;
  }

  void removeCurrentUser(){
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref){
  return AuthNotifier();
});