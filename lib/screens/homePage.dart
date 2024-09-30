import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'registration.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 79, 149, 240),

      appBar: AppBar(
        title: Center(
          child: Text(
            'Welcome!',
            style: TextStyle(
              fontSize: 42,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor:
          Color.fromARGB(255, 79, 149, 240),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Login Button
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 118, 174, 249),
                  side: BorderSide(color: Color.fromARGB(255, 35, 99, 150), width: 1),
                  textStyle: TextStyle(fontSize: 28),
                  foregroundColor: Color.fromARGB(255, 25, 73, 113),
                ),
                child: Text('Login'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ),
            SizedBox(height: 30),
            
            // Sign up Button
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 118, 174, 249),
                  side: BorderSide(color: Color.fromARGB(255, 35, 99, 150), width: 1),
                  textStyle: TextStyle(fontSize: 28),
                  foregroundColor: Color.fromARGB(255, 25, 73, 113),
                ),
                child: Text('Sign up'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}