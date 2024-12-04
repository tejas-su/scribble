import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';

class SecretsCubit extends Cubit<SecretsCubitState> {
  SecretsCubit() : super(SecretsCubitState());

  Future<Box> openPasswordBox() async {
    Box box = await Hive.openBox('password');
    box.add(null);
    return box;
  }

  void createPassword({required Box box, required String password}) {
    box.add(password);
  }

  void updatePassword({required Box box, required String password}) {
    box.putAt(0, password);
  }

  String retrievePassword({required Box box}) {
    String password = box.getAt(0);
    return password;
  }

  void resetPassword({required Box box}) {
    box.delete(0);
  }

  void onToggle(bool showPassword) {
    emit(SecretsCubitState(obscureText: showPassword ? false : true));
  }

  void onValidate(String password, BuildContext context) {
    if (password.isEmpty) {
      emit(SecretsCubitState(
          showErrorText: true, errortext: 'Password cannot be empty'));
    } else if (password != '12345') {
      emit(SecretsCubitState(
          showErrorText: true,
          errortext: 'Incorrect Password. Please try again.'));
    }
  }
}

class SecretsCubitState extends Equatable {
  final bool obscureText;
  final String? errortext;
  final bool showErrorText;
  const SecretsCubitState({
    this.obscureText = true,
    this.showErrorText = false,
    this.errortext,
  });
  @override
  List<Object?> get props => [obscureText, showErrorText, errortext];
}
