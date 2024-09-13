import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolist_crud_test/models/task.dart';
import 'package:http/http.dart' as http;

Uri _baseUrl =
    Uri.https('crudcrud.com', 'api/3d91896afac3415ea03b748d32a8d9c7/tasks');
const _header = {'Content-Type': 'application/json'};

class TasksListNotifier extends StateNotifier<List<Task>> {
  TasksListNotifier() : super(const []);

  int get getLength {
    return state.length;
  }

  //Read Tasks
  Future<void> getTasks() async {
    final response = await http.get(_baseUrl, headers: _header);
    if (response.statusCode == 200) {
      List<dynamic> res = json.decode(response.body);
      List<Task> allTask = [];
      for (final r in res) {
        allTask.add(
            Task(id: r['id'], title: r['title'], completed: r['completed']));
      }
      state = [...allTask];
    } else {
      print("Failed getting tasks");
    }
  }

  //Create
  Future<void> addTasks(Task task) async {
    var taskJson = json.encode(task.toJson());
    final response =
        await http.post(_baseUrl, headers: _header, body: taskJson);
    if (response.statusCode == 200) {
      Map<String, dynamic> res = json.decode(response.body);
      Task newTask = Task.fromJson(res);
      state = [...state, newTask];
    } else {
      print('failed adding task');
    }
  }

  //Update Task
  Future<void> updateTask(Task task) async {
    final response = await http.get(_baseUrl, headers: _header);
    if (response.statusCode == 200) {
      List<dynamic> getTasks = json.decode(response.body);
      final selectedTask = getTasks.firstWhere((e) => e['id'] == task.id);
      final _body = json.encode({
        'id': selectedTask['id'],
        'title': selectedTask['title'],
        'completed': !selectedTask['completed']
      });
      final res = await http.put(
          Uri.parse('${_baseUrl}/${selectedTask['_id']}'),
          headers: _header,
          body: _body);
      if (res.statusCode == 200) {
        final updatedTasks = state
            .map((t) =>
                t.id == task.id ? t.copyWith(completed: !t.completed) : t)
            .toList();

        state = updatedTasks;
      } else {
        print('failed update task');
      }
    } else {
      print("Failed update task");
    }
  }

  //Delete Task
  Future<void> deleteTask(Task task) async {
    final response = await http.get(_baseUrl, headers: _header);
    if (response.statusCode == 200) {
      List<dynamic> getTasks = json.decode(response.body);
      final selectedTask = getTasks.firstWhere((e) => e['id'] == task.id);
      final res = await http.delete(
          Uri.parse('${_baseUrl}/${selectedTask['_id']}'),
          headers: _header);

      if (res.statusCode == 200) {
        final index = state.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          state.removeAt(index); // Remove the task from state
        }
      } else {
        print('failed delete task');
      }
    } else {
      print("failed deleting");
    }
  }
}

final tasksListProvider = StateNotifierProvider<TasksListNotifier, List<Task>>(
  (ref) => TasksListNotifier(),
);

enum TodoFilter { all, completed, active }

final tasksFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

// Provider to get filtered tasks
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final filter = ref.watch(tasksFilterProvider);
  final allTasks = ref.watch(tasksListProvider); // Replace with your task list provider

  return allTasks.where((task) {
    switch (filter) {
      case TodoFilter.all:
        return true;
      case TodoFilter.completed:
        return task.completed;
      case TodoFilter.active:
        return !task.completed;
    }
  }).toList();
});