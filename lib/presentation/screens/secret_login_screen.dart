import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:scribble/presentation/widgets/message_field.dart';
import '../../cubit/secrets_cubit.dart';
import 'secret_notes_screen.dart';

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
              SizedBox(height: 50),
              Lottie.asset('assets/lottie/lock.json'),
              Text(
                textAlign: TextAlign.center,
                'Access your private notes.',
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.w300),
              ),
              SizedBox(height: 20),
              BlocBuilder<SecretsCubit, SecretsCubitState>(
                builder: (context, state) {
                  return MessageField(
                    onComplete: (password) {
                      context
                          .read<SecretsCubit>()
                          .onValidate(password, context);
                    },
                    padding: 8,
                    maxLines: 1,
                    minLines: 1,
                    keyboardType: TextInputType.numberWithOptions(),
                    obscureText: state.obscureText,
                    controller: passwordController,
                    onSubmitted: () {
                      context.read<SecretsCubit>().onToggle(state.obscureText);
                    },
                    icon: state.obscureText
                        ? Icons.lock_rounded
                        : Icons.lock_open_rounded,
                    iconSize: 24,
                    prompt: 'Enter password',
                    errorText: state.showErrorText ? state.errortext : null,
                  );
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
