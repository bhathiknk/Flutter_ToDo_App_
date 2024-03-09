import 'package:flutter/material.dart';
import 'package:flutter_todo_app/Screens/home_screen.dart';
import 'package:flutter_todo_app/components/my_button.dart';
import 'package:flutter_todo_app/components/my_textfeild.dart';
import 'package:flutter_todo_app/components/square_title.dart';
import 'package:flutter_todo_app/user/register_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key});

  // txt editing controller
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signUserIn(BuildContext context) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/users/login');

    final response = await http.post(
      url,
      body: {
        'username': usernameController.text,
        'password': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      // User logged in successfully
      print('User logged in successfully');


      // Save user ID
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('userId', int.parse(response.body));


      // Navigate to the HomePage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else if (response.statusCode == 401) {
      // Invalid credentials
      print('Invalid credentials');

      // Show error popup message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login Failed'),
            content: Text('Invalid username or password. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Clear the text fields
                  usernameController.clear();
                  passwordController.clear();

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
            children: [
              const SizedBox(height: 50),

              // logo
              const Icon(
                Icons.account_circle,
                size: 100,
              ),

              const SizedBox(height: 50),

              // welcome back you have been missed!

              Text(
                'Welcome back you\'ve been missed!',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              // username text field
              MyTextFeild(
                controller: usernameController,
                hintText: 'Username',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // password text field
              MyTextFeild(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              // forgot password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Forgot password?',
                        style: TextStyle(
                          color: Colors.grey[600],
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // signin button
              MyButton(
                text: 'Sign In',
                onTap: () => signUserIn(context),
              ),

              const SizedBox(height: 50),

              // or continue with
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

              // google or microsoft sign in button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [

                  // google button
                  SquareTitle(imagePath: 'images/google.png'),

                  const SizedBox(width: 25),

                  // microsoft button
                  SquareTitle(imagePath: 'images/microsoft.png')

                ],
              ),

              const SizedBox(height: 50),

              // not a member ? register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member?',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 4),

                  GestureDetector(
                    onTap: () {
                      // Navigate to the RegisterPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      'Register now',
                      style: TextStyle(
                        color: Color(0xFF674AEF),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )

                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
