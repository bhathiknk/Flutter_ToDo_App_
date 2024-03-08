import 'package:flutter/material.dart';
import 'package:flutter_todo_app/Screens/home_screen.dart';
import 'package:flutter_todo_app/components/my_button.dart';
import 'package:flutter_todo_app/components/my_textfeild.dart';
import 'package:flutter_todo_app/components/square_title.dart';
import 'package:flutter_todo_app/user/login_page.dart';
import 'package:http/http.dart' as http;


class RegisterPage extends StatelessWidget {


  RegisterPage({Key? key}) : super(key: key);

  //txt editing controller
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> signUserUp(BuildContext context) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/users/register');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
      },
      body: {
        'username': usernameController.text,
        'password': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      // User registered successfully
      print('User registered successfully');

      // Navigate to the LoginPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } else if (response.statusCode == 400) {
      // Username is already taken
      print('Username is already taken');

      // Show an error popup
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Username is already taken'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Clear the text fields
                  usernameController.clear();
                  passwordController.clear();
                  confirmPasswordController.clear();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Handle other response codes or errors
      print('Error: ${response.statusCode}');
    }
  }



  @override

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [
              const SizedBox(height: 25),

              //logo
              const Icon(
                Icons.badge_rounded,
                size: 50,
              ),

              const SizedBox(height: 25),


              //welcome back you have been missed!

              Text('Let\'s create and account for you !',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              //username text field
              MyTextFeild(
                controller: usernameController,
                hintText: 'UserName',
                obscureText: false,
              ),

              const SizedBox(height: 10),


              //password text field
              MyTextFeild(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              //password text field
              MyTextFeild(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),


              const SizedBox(height: 25),
              //signin button
            MyButton(
              text: 'Sign Up',
              onTap: () => signUserUp(context),
            ),

              const SizedBox(height: 50),
              //or continue with
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              //google or microsoft sign in button
              Row (
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [

                  //google button
                  SquareTitle(imagePath: 'images/google.png'),

                  const SizedBox(width: 25),

                  //microsoft button
                  SquareTitle(imagePath: 'images/microsoft.png')

                ],
              ),

              const SizedBox(height: 50),
              //already ahve an account ? Login now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account ?',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 4),

                  Text('Login now',
                    style: TextStyle(
                      color: Color(0xFF674AEF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],)

            ],
          ),
        ),
      ),
    );
  }

}