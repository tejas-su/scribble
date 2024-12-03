import 'package:flutter_bloc/flutter_bloc.dart';

class SecretsCubit extends Cubit<bool> {
  SecretsCubit() : super(true);

  void onToggle(bool showPassword) {
    emit(showPassword ? false : true);
  }
}
