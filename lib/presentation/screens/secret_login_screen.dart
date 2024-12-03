import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:scribble/presentation/widgets/message_field.dart';

import '../../cubit/secrets_cubit.dart';

class SecretLoginScreen extends StatelessWidget {
  const SecretLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Theme.of(context).appBarTheme.surfaceTintColor,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'secrets',
          style: GoogleFonts.inter(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Lottie.asset('assets/lottie/lock.json'),
              BlocBuilder<SecretsCubit, bool>(
                builder: (context, state) {
                  return MessageField(
                      //TODO: Handle on submitted
                      onComplete: (p0) => debugPrint(p0),
                      padding: 8,
                      maxLines: 1,
                      minLines: 1,
                      keyboardType: TextInputType.numberWithOptions(),
                      obscureText: state,
                      controller: passwordController,
                      onSubmitted: () {
                        context.read<SecretsCubit>().onToggle(state);
                      },
                      icon:
                          state ? Icons.lock_rounded : Icons.lock_open_rounded,
                      iconSize: 24,
                      prompt: 'Enter password');
                },
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
