import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SecretsCubit extends Cubit<SecretsCubitState> {
  SecretsCubit() : super(SecretsCubitState());

  void onToggle(bool showPassword) {
    emit(SecretsCubitState(obscureText: showPassword ? false : true));
  }

  void onValidate(String password, BuildContext context, Widget screen) {
    if (password.isEmpty) {
      emit(SecretsCubitState(
          showErrorText: true, errortext: 'Password cannot be empty'));
    } else if (password != '12345') {
      emit(SecretsCubitState(
          showErrorText: true,
          errortext: 'Incorrect Password. Please try again.'));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => screen,
      ));
    }
  }
}

class SecretsCubitState extends Equatable {
  final bool obscureText;
  final String? errortext;
  final bool showErrorText;
  const SecretsCubitState(
      {this.obscureText = true, this.showErrorText = false, this.errortext});
  @override
  List<Object?> get props => [obscureText, showErrorText, errortext];
}
