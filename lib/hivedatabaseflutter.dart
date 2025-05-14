import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class HiveDatabaseFlutter extends StatefulWidget {
  const HiveDatabaseFlutter({super.key});

  @override
  State<HiveDatabaseFlutter> createState() => _HiveDatabaseFlutterState();
}

class _HiveDatabaseFlutterState extends State<HiveDatabaseFlutter> {
  late Box peopleBox;

  //var peopleBox = Hive.box("MyBox");
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    peopleBox = Hive.box("myBox"); // ✅ Safely assign after initialization
  }

  //function for add and update

  void addOrUpdate({String? key}) {
    if (key != null) {
      final person = peopleBox.get(key);
      if (person != null) {
        nameController.text = person['name'] ?? "";
        emailController.text = person['email'] ?? "";
      }
    } else {
      nameController.clear();
      emailController.clear();
    }
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 15,
              right: 15,
              top: 15,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Name",
                  ),
                ),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter the email",
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text;
                    final email = emailController.text;

                    //validate the fields
                    if (name.isEmpty || email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter all the fields")),
                      );
                    }
                    if (key != null) {
                      peopleBox.put(key, {"name": name, "email": email});
                    } else {
                      final newKey =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      peopleBox.put(newKey, {"name": name, "email": email});
                    }
                    nameController.clear();
                    emailController.clear();
                    Navigator.pop(context);
                  },
                  child: Text(key != null ? "Update" : "Add"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //delete operation
  void deleteOperation(String key) {
    peopleBox.delete(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text("Crud Using Flutter"),
      ),
      body: ValueListenableBuilder(
        valueListenable: peopleBox.listenable(),
        builder: (context, box, widget) {
          if (box.isEmpty) {
            return Center(child: Text("No Item Added Yet!!"));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index).toString();
              final items = box.get(key);

              if (items == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.all(10),
                child: Material(
                  color: Colors.white,
                  elevation: 2,
                  child: ListTile(
                    title: Text(items?["name"] ?? "Unknown"),
                    subtitle: Text(items?["email"] ?? "Unknown"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => addOrUpdate(key: key),
                          icon: Icon(Icons.edit, color: Colors.green,),
                        ),
                        IconButton(
                          onPressed: () => deleteOperation(key),
                          icon: Icon(Icons.delete, color: Colors.red,),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => addOrUpdate(),
        child: Icon(Icons.add),
      ),
    );
  }
}
