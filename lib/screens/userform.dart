import 'dart:convert';
import 'dart:js_interop';
import 'package:crud/models/config.dart';
import 'package:crud/models/users.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formkey = GlobalKey<FormState>();
  // Users users = Users();
  late Users users;
//updatedata
  Future<void> updateData(user) async {
    var url = Uri.http(Configure.server, "users/${user.id}");
    var resp = await http.put(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()));
    var rs = usersFromJson("[${resp.body}]");
    if (rs.length == 1) {
      Navigator.pop(context, "refresh");
    }
  }

//addnewUser
  Future<void> addNewUser(user) async {
    var url = Uri.http(Configure.server, "users");
    var resp = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(user.toJson()));
    var rs = usersFromJson("[${resp.body}]");

    if (rs.length == 1) {
      Navigator.pop(context, "refresh");
    }
    return;
  }

//1
  Widget fnameInputField() {
    return TextFormField(
      initialValue: users.fullname,
      decoration:
          InputDecoration(labelText: "Fullname:", icon: Icon(Icons.person)),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => users.fullname = newValue,
    );
  }

// email
  Widget emailInputField() {
    return TextFormField(
      initialValue: users.email,
      decoration: InputDecoration(labelText: "Email", icon: Icon(Icons.email)),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        if (!EmailValidator.validate(value)) {
          return "It is not email format";
        }
        return null;
      },
      onSaved: (newValue) => users.email = newValue!,
    );
  }

// pasasword
  Widget passwordInputField() {
    return TextFormField(
      initialValue: users.password,
      decoration:
          InputDecoration(labelText: "password", icon: Icon(Icons.lock)),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => users.password = newValue!,
    );
  }

  // button
  Widget submitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formkey.currentState!.validate()) {
          _formkey.currentState!.save();
          print(users.toJson().toString());
          if (users.id == null) {
            addNewUser(users);
          } else {
            updateData(users);
          }
        }
      },
      child: Text("Save"),
    );
  }

  //gender
  Widget genderFormInput() {
    var initGen = "None";
    try {
      if (users.gender!.isNull) {
        initGen = users.gender!;
      }
    } catch (e) {
      initGen = "None";
    }

    return DropdownButtonFormField(
        decoration: InputDecoration(labelText: "Gender", icon: Icon(Icons.man)),
        value: 'None',
        items: Configure.gender.map((String val) {
          return DropdownMenuItem(
            value: val,
            child: Text(val),
          );
        }).toList(),
        onChanged: (value) {
          users.gender = value;
        },
        onSaved: (newValue) => users.gender);
  }

  @override
  Widget build(BuildContext context) {
    try {
      users = ModalRoute.of(context)!.settings.arguments as Users;
      print(users.fullname);
    } catch (e) {
      users = Users();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Form"),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              fnameInputField(),
              emailInputField(),
              passwordInputField(),
              genderFormInput(),
              SizedBox(
                height: 10,
              ),
              submitButton()
            ], //to do
          ),
        ),
      ),
    );
  }
}
