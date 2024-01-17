import 'package:fcm_atoz/components/button.dart';
import 'package:fcm_atoz/components/text_field.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controllers
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();

  //sign up user
  void signUp() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 50),

            // register email account
            const Text(
              "Register account here",
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            //email
            MyTextField(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),

            const SizedBox(height: 10),

            //pass
            MyTextField(
              controller: passController,
              hintText: 'Password',
              obscureText: true,
            ),

            const SizedBox(height: 10),

            //confirm pass
            MyTextField(
              controller: confirmPassController,
              hintText: 'Confirm Password',
              obscureText: true,
            ),

            const SizedBox(height: 25),

            //sign up
            MyButton(onTap: () {}, text: "Sign up"),

            const SizedBox(height: 25),

            //register
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                onTap: widget.onTap,
                child: const Text(
                  'Login here',
                ),
              )
            ])
          ]),
        ),
      ),
    ));
  }
}
