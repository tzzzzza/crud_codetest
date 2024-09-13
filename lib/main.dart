import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolist_crud_test/providers/providers.dart';
import 'package:todolist_crud_test/models/task.dart';
import 'package:todolist_crud_test/widgets/todo_list.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _task = TextEditingController();

  // adding task
  Future<void> addTasks() async {
    try {
      showDialog(context: context,barrierDismissible: false, builder: (context){
        return Center(
          child: Column( 
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator()
            ],
          ),
        );
      });
      var tasksList = ref.read(tasksListProvider.notifier);
      await tasksList.addTasks(
        Task(
            id: (tasksList.getLength + 1).toString(),
            title: _task.text,
            completed: false),
      );
      _task.clear();
      Navigator.of(context).pop();
    } catch (e) {
      print("Failed");
      Navigator.of(context).pop();
    }
  }

  Future<void> getTasks() async{ 
    try{
      await ref.read(tasksListProvider.notifier).getTasks();
    }catch (e){
      print(e);
    }
  }

  @override
  void initState() {
    getTasks();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Todos",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _task,
              decoration: const InputDecoration(
                hintText: "Add Tasks",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.maxFinite, 40),
                  backgroundColor: Colors.green),
              onPressed: () {
                addTasks();
                ref.read(tasksListProvider.notifier).getTasks();
              },
              child: const Text(
                "Add Task",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const TodoListWidget()
          ],
        ),
      ),
    );
  }
}
