import 'dart:io';

import 'package:chat_app/widgets/pickers/user_image_picker.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  AuthForm(
    this.submitFn,
    this.isLoading,
  );

  final bool isLoading;

  final void Function(
    String email,
    String password,
    String username,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>(); //formState
  var _isLogin = true;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  //this File will be use to store image parsed by and save it to firebase_storage
  File _userImageFile;

  //File image input below is from the user_image_picker.dart
  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();

    FocusScope.of(context).unfocus(); //unFocus/close Keyboard

    //check if image is null and should not be in login mode
    if (_userImageFile == null && !_isLogin) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Please pick an image.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState.save();

      // Use those values to send our auth request
      widget.submitFn(
        _userEmail.trim(),
        _userPassword.trim(),
        _userName.trim(),
        _userImageFile,
        _isLogin,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            child: Image.asset('assets/devhk.png'),
          ),
          // Image.network(src),
          Center(
            child: Card(
              margin: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isLogin)
                          UserImagePicker(
                              _pickedImage), //only pass "pointer" of the function and not to run it
                        TextFormField(
                          key: ValueKey('email'),
                          validator: (value) {
                            if (value.isEmpty || !value.contains('@')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _userEmail = value;
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email address',
                          ),
                        ),
                        if (!_isLogin) //responsive login applied
                          TextFormField(
                            key: ValueKey('username'),
                            validator: (value) {
                              if (value.isEmpty || value.length < 4) {
                                return 'Please enter at least 4 characters.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _userName = value;
                            },
                            decoration: InputDecoration(
                              labelText: 'Username',
                            ),
                          ),
                        TextFormField(
                          key: ValueKey('password'),
                          validator: (value) {
                            if (value.isEmpty || value.length < 7) {
                              return 'Password must be at least 7 characters long.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _userPassword = value;
                          },
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                        ),
                        SizedBox(height: 12),
                        if (widget.isLoading) CircularProgressIndicator(),
                        if (!widget.isLoading)
                          ElevatedButton(
                            onPressed: _trySubmit,
                            child: Text(
                              _isLogin ? 'Login' : 'SignUp',
                            ),
                          ),
                        if (!widget.isLoading)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin //responsive login applied
                                  ? 'Create new account'
                                  : 'I already have an account',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
