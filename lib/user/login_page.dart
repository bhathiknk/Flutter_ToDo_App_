import 'package:flutter/material.dart';
import 'package:flutter_todo_app/components/my_button.dart';
import 'package:flutter_todo_app/components/my_textfeild.dart';
import 'package:flutter_todo_app/components/square_title.dart';


class LoginPage extends StatelessWidget {
   LoginPage({super.key});
   
   //txt editing controller
   final usernameController = TextEditingController();
   final passwordController = TextEditingController();

   //user sign in method
   void signUserIn() {
     
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
               const SizedBox(height: 50),

              //logo
               const Icon(
                Icons.account_circle,
                size: 100,
              ),

               const SizedBox(height: 50),

          
              //welcome back you have been missed!

              Text('Welcome back you\'ve been missed!',
               style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
              ),

               const SizedBox(height: 25),
          
              //username text field
              MyTextFeild(
                controller: usernameController,
                hintText: 'Username',
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
          
              //forgot password
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
              //signin button
                MyButton(
                  onTap: signUserIn,
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
              Row(
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
              //not a member ? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Text('Not a member?',
                  style: TextStyle(
                    color: Colors.grey[700],
                    ),
                    ),
                  const SizedBox(width: 4),
                  Text('Register now',
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