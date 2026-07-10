import 'package:flutter_test/flutter_test.dart';
import 'package:scribble/src/features/home/presentation/bloc/page_view_cubit.dart';

void main() {
  group('PageViewCubit', () {
    test('initial state is 0', () {
      expect(PageViewCubit().state, 0);
    });

    test('togglePage emits the new page value', () {
      final cubit = PageViewCubit();
      addTearDown(cubit.close);

      cubit.togglePage(1);

      expect(cubit.state, 1);
    });

    test('togglePage back to 0 works after toggling to 1', () {
      final cubit = PageViewCubit()
        ..togglePage(1)
        ..togglePage(0);
      addTearDown(cubit.close);

      expect(cubit.state, 0);
    });

    test('togglePage with the same value still emits (no distinct check)', () async {
      final cubit = PageViewCubit();
      addTearDown(cubit.close);

      final emitted = <int>[];
      final sub = cubit.stream.listen(emitted.add);
      addTearDown(sub.cancel);

      cubit.togglePage(0);
      await Future<void>.delayed(Duration.zero);

      expect(emitted, [0]);
    });
  });
}
