import 'dart:convert';
import 'package:flutter/material.dart';
import 'album.dart';
import 'db_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Employee List',
        theme: ThemeData(
            primarySwatch: Colors.teal,
            primaryColor: Colors.teal,
            // iconTheme: const IconThemeData(color: Colors.white),
            textTheme: const TextTheme(
              bodyText2: TextStyle(
                color: Colors.white,
              ),
            ),
            cardColor: Colors.teal),
        home: const MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> employeeList = [];

  bool _isLoading = true;
  void getEmployeeList() async {
    final getData = await DbManager.getUsers();
    setState(() {
      employeeList = getData;
      employeeList =  employeeList.reversed.toList();
      print(employeeList);
      print(employeeList.length);
      _isLoading = false;
    });
  }



  @override
  void initState() {
    super.initState();
    getEmployeeList();
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController designationController = TextEditingController();

  _register() {
    var data = {
      'name' : nameController.text,
      'salary': salaryController.text,
      'designation': designationController};

    var res = CallApi().postData(data, 'syncapi.php');
    var body = json.decode(res.body);
    if(body['success']){
      print('Data successfully posted');
    }
  }



  void selectedUser(int? id) async {
    if (id != null) {
      final selectedId =
      employeeList.firstWhere((element) => element['id'] == id);
      nameController.text = selectedId['name'];
      salaryController.text = selectedId['salary'];
      designationController.text = selectedId['designation'];
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.only(top: 0, left: 0, right: 0),
            contentPadding: const EdgeInsets.only(top: 12, left: 0, bottom: 10),
            insetPadding: const EdgeInsets.symmetric(horizontal: 15),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            title: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    Row(
                      children: const [
                        Text(
                          "Add New User",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {

                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.close,
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15),
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(hintText: 'Name'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: designationController,
                      decoration:
                          const InputDecoration(hintText: 'Designation'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: salaryController,
                      decoration: const InputDecoration(hintText: 'Salary'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await addNewUser();
                        }
                        if (id != null) {
                          await updateUser(id);
                        }
                        nameController.clear();
                        salaryController.clear();
                        designationController.clear();
                        Navigator.of(context).pop();
                        _register();
                        print(_register());
                        print('button pressed');
                      },
                      child: Text(id == null ? 'Create' : 'Update'),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> addNewUser() async {
    await DbManager.createUser(
        nameController.text, designationController.text, salaryController.text);
    getEmployeeList();
  }

  Future<void> updateUser(int id) async {
    await DbManager.updateUser(id, nameController.text,
        designationController.text, salaryController.text);
    getEmployeeList();
  }

  void deleteUser(int id) async {
    await DbManager.deleteUser(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted the user!'),
    ));
    getEmployeeList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee List'),
        actions: [
          GestureDetector(
            onTap: () {
              nameController.clear();
              salaryController.clear();
              designationController.clear();
              selectedUser(null);
            },
            child: Row(
              children: const [
                Text("Add New"),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.add,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: employeeList.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
                child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employeeList[index]['name'],
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          employeeList[index]['designation'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        const Text(
                          "Salary : ",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          employeeList[index]['salary'],
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.indigo,
                              ),
                              onPressed: () =>
                                  selectedUser(employeeList[index]['id']),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    deleteUser(employeeList[index]['id']),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
    );
  }
}
