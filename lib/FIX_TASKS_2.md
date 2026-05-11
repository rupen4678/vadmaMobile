// 1. In lib/features/auth/screens/login_screen.dart:
// - Fix the login method call in _submit: 
//   ref.read(authProvider.notifier).login(_usernameController.text, _passwordController.text);

// 2. In lib/features/chat/screens/chat_list_screen.dart:
// - Check currentUser data structure logic at line 46:
//   Use: (p) => p.username != currentUser['username'].toString() 
//   instead of currentUser?['username']

// 3. Keep investigating the 'MainScreen' constant errors. 
//    Wait, did removing the FloatingActionButton resolve all issues? 
//    Let's check the error logs again.
