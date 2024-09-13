import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert'; // Import the correct http package
import 'package:todolist_crud_test/models/task.dart';

Uri _baseUrl = Uri.https('crudcrud.com', 'api/77e66705202043cfa49e5181306c06aa/tasks');
const _header = {'Content-Type': 'application/json'};

class Service {
  //create tasks
  static Future<http.Response> createTasks(Task task) async {
    var taskJson = json.encode(task.toJson());
    final response = await http.post(_baseUrl, headers: _header, body: taskJson); 
    print(response);
    return response;
  }

  //getting tasks
  static Future<http.Response> getTasks() async{
    final response = await http.get(_baseUrl, headers: _header); 
    print(response);
    return response;
  }
}