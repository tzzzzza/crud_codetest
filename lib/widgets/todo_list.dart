import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolist_crud_test/providers/providers.dart';
import 'package:todolist_crud_test/models/task.dart';

class TodoListWidget extends ConsumerWidget {
  const TodoListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskLists = ref.watch(tasksListProvider);
    final filterTasks = ref.watch(filteredTasksProvider);

    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text("Total - ${filterTasks.length}"),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(tasksFilterProvider.notifier).state =
                          TodoFilter.all;
                    },
                    child: Text(
                      "All",
                      style: TextStyle(
                          color:
                              ref.watch(tasksFilterProvider) == TodoFilter.all
                                  ? Colors.blue
                                  : Colors.black),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      ref.read(tasksFilterProvider.notifier).state =
                          TodoFilter.completed;
                    },
                    child: Text(
                      "Completed",
                      style: TextStyle(
                          color: ref.watch(tasksFilterProvider) ==
                                  TodoFilter.completed
                              ? Colors.blue
                              : Colors.black),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      ref.read(tasksFilterProvider.notifier).state =
                          TodoFilter.active;
                    },
                    child: Text(
                      "Active",
                      style: TextStyle(
                          color:
                              ref.watch(tasksFilterProvider) == TodoFilter.active
                                  ? Colors.blue
                                  : Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(color: Colors.black),
          taskLists.length <= 0
              ? Text("There is no task")
              : Container(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  child: Column(
                    children: [
                      for (Task task in filterTasks)
                        taskListWidget(task, ref, context)
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

Widget taskListWidget(Task task, WidgetRef ref, BuildContext context) {
  var key = UniqueKey();
  return Dismissible(
    key: key,
    direction: DismissDirection.endToStart,
    background: Container(
      color: Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          SizedBox(width: 10),
        ],
      ),
    ),
    onDismissed: (direction) async {
      await ref.read(tasksListProvider.notifier).deleteTask(task);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    },
    child: Container(
      padding: EdgeInsets.only(top: 10, left: 5, right: 5),
      decoration: BoxDecoration(),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(task.title),
            GestureDetector(
              onTap: () async {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [CircularProgressIndicator()],
                        ),
                      );
                    });
                await ref.read(tasksListProvider.notifier).updateTask(task);
                Navigator.of(context).pop();
              },
              child: Icon(
                Icons.task_alt_rounded,
                color: task.completed ? Colors.green : Colors.grey,
              ),
            )
          ],
        ),
        Divider(
          height: 20,
          color: Colors.black,
        )
      ]),
    ),
  );
}
