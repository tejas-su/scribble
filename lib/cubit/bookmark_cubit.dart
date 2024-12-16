import 'package:flutter_bloc/flutter_bloc.dart';

class BookmarkCubit extends Cubit<bool> {
  BookmarkCubit() : super(false);

  void toggleBookmark({required bool isBookMarked}) {
    emit(isBookMarked ? false : true);
  }
}
