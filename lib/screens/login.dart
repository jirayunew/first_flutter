import 'package:crud/models/config.dart';
import 'package:crud/models/users.dart';
import 'package:crud/screens/home.dart';
import 'package:crud/screens/userform.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  static const rountName = "/login";
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

// login
class _LoginState extends State<Login> {
  final _formkey = GlobalKey<FormState>();
  Users user = Users();

  Future<void> login(Users user) async {
    var params = {"email": user.email, "password": user.password};
    var url = Uri.http(Configure.server, "users", params);
    var resp = await http.get(url);
    print(resp.body);
    List<Users> login_result = usersFromJson(resp.body);
    print(login_result.length);
    if (login_result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("username or password invalid")));
    } else {
      Configure.login = login_result[0];
      Navigator.pushNamed(context, HOME.routeName);
    }
    return;
  }

  // email
  Widget emailInputField() {
    return TextFormField(
      initialValue: "jirayu@gmail.com",
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
      onSaved: (newValue) => user.email = newValue!,
    );
  }

// pasasword
  Widget passwordInputField() {
    return TextFormField(
      initialValue: "1q2w3e4r",
      decoration:
          InputDecoration(labelText: "password", icon: Icon(Icons.lock)),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => user.password = newValue!,
    );
  }

  // button
  Widget submitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formkey.currentState!.validate()) {
          _formkey.currentState!.save();
          print(user.toJson().toString());
          login(user);
        }
      },
      child: Text("Login"),
    );
  }

// back
  Widget BackButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(
            context,
            MaterialPageRoute(
              builder: (context) => HOME(),
            ));
      },
      child: Text("Back"),
    );
  }

// link
  Widget registerLink() {
    return InkWell(
      child: const Text("Sign up"),
      onTap: () async {
        String result = await Navigator.push(
            context, MaterialPageRoute(builder: (context) => UserForm()));
      },
    );
  }

  Widget textHeader() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        "Login",
        style: TextStyle(fontSize: 40.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textHeader(),
              emailInputField(),
              passwordInputField(),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  submitButton(),
                  SizedBox(
                    width: 10.0,
                  ),
                  BackButton(),
                  SizedBox(
                    width: 10.0,
                  ),
                  registerLink()
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
