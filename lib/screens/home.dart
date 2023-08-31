import 'package:crud/models/config.dart';
import 'package:crud/models/users.dart';
import 'package:crud/screens/login.dart';
import 'package:crud/screens/userform.dart';
import 'package:crud/screens/userinfo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HOME extends StatefulWidget {
  static const routeName = '/';
  const HOME({super.key});

  @override
  State<HOME> createState() => _HOMEState();
}

class _HOMEState extends State<HOME> {
  Widget mainBody = Container();

  // delete
  Future<void> removeUsers(user) async {
    var url = Uri.http(Configure.server, "users/${user.id}");
    var resp = await http.delete(url);
    print(resp.body);
    return;
  }

  List<Users> _userList = [];
  Future<void> getUsers() async {
    var url = Uri.http(Configure.server, "users");
    var resp = await http.get(url);
    setState(() {
      _userList = usersFromJson(resp.body);
      mainBody = showUsers();
    });
    return;
  }

// initstate
  @override
  void initState() {
    super.initState();
    Users user = Configure.login;
    if (user.id != null) {
      getUsers();
    }
  }

  // showUsers
  Widget showUsers() {
    return ListView.builder(
      itemCount: _userList.length,
      itemBuilder: (context, index) {
        Users users = _userList[index];
        return Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          child: Card(
            child: ListTile(
              title: Text("${users.fullname}"),
              subtitle: Text("${users.email}"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserInfo(),
                        settings: RouteSettings(arguments: users)));
              }, //to show info
              trailing: IconButton(
                onPressed: () async {
                  String result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserForm(),
                          settings: RouteSettings(arguments: users)));
                  if (result == "refresh") {
                    getUsers();
                  }
                }, // to edit
                icon: Icon(Icons.edit),
              ),
            ),
          ),
          onDismissed: (direction) {
            removeUsers(users);
          }, //to delete,
          background: Container(
            color: Colors.red,
            margin: EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

// mainWidget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: SideMenu(),
      body: mainBody,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String result = await Navigator.push(
              context, MaterialPageRoute(builder: (context) => UserForm()));
          if (result == "refresh") {
            getUsers();
          }
        }, //add new user
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}

// Less

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    String accountName = 'N/A';
    String accountEmail = 'N/A';
    String accountUrl =
        'https://instagram.furt3-1.fna.fbcdn.net/v/t51.2885-19/328970434_144791398442933_9145920708887023430_n.jpg?stp=dst-jpg_s150x150&_nc_ht=instagram.furt3-1.fna.fbcdn.net&_nc_cat=105&_nc_ohc=rI5GFrwOxjoAX-eBtr6&edm=ACWDqb8BAAAA&ccb=7-5&oh=00_AfDcYt011kwkQX4xeHa6-OfXrur6x02yMQ8wNk9UuL8a2Q&oe=64F19D0F&_nc_sid=ee9879';

    Users user = Configure.login;
    if (user.id != null) {
      accountName = user.fullname!;
      accountEmail = user.email!;
    }
    return Drawer(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(accountName),
              accountEmail: Text(accountEmail),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(accountUrl),
                backgroundColor: Colors.white,
              ),
            ),
            ListTile(
              title: Text("Home"),
              onTap: () {
                Navigator.pushNamed(context, HOME.routeName);
              },
            ),
            ListTile(
              title: Text("Login"),
              onTap: () {
                Navigator.pushNamed(context, Login.rountName);
              },
            ),
          ]),
    );
  }
}
