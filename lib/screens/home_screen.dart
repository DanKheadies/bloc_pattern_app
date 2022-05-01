import 'package:flutter/material.dart';

import 'package:bloc_pattern_app/blocs/todos_filter/todos_filter_bloc.dart';
import 'package:bloc_pattern_app/models/todo.dart';
import 'package:bloc_pattern_app/models/todos_filter.dart';
import 'package:bloc_pattern_app/screens/add_todo_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/todos/todos_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Card _todoCard(BuildContext context, Todo todo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '#${todo.id}: ${todo.task}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.read<TodosBloc>().add(
                          UpdateTodo(
                            todo: todo.copyWith(
                              isCompleted: true,
                            ),
                          ),
                        );
                  },
                  icon: const Icon(Icons.add_task),
                ),
                IconButton(
                  onPressed: () {
                    context.read<TodosBloc>().add(
                          DeleteTodo(todo: todo),
                        );
                  },
                  icon: const Icon(Icons.cancel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BlocConsumer<TodosFilterBloc, TodosFilterState> _todos(String title) {
    return BlocConsumer<TodosFilterBloc, TodosFilterState>(
      listener: (context, state) {
        if (state is TodosFilterLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'There are ${state.filteredTodos.length} To Dos in your ${state.todosFilter.toString().split('.').last} list.',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TodosFilterLoading) {
          return const CircularProgressIndicator();
        }
        if (state is TodosFilterLoaded) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.filteredTodos.length,
                  itemBuilder: (context, index) {
                    return _todoCard(context, state.filteredTodos[index]);
                  },
                ),
              ],
            ),
          );
        } else {
          return const Text('Something went wrong.');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BloC Patterns: To Dos'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTodoScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
            ),
          ],
          bottom: TabBar(
            onTap: (tabIndex) {
              switch (tabIndex) {
                case 0:
                  BlocProvider.of<TodosFilterBloc>(context).add(
                    const UpdateTodos(
                      todosFilter: TodosFilter.pending,
                    ),
                  );
                  break;
                case 1:
                  BlocProvider.of<TodosFilterBloc>(context).add(
                    const UpdateTodos(
                      todosFilter: TodosFilter.completed,
                    ),
                  );
                  break;
              }
            },
            tabs: const [
              Tab(
                icon: Icon(
                  Icons.pending,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.add_task,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _todos('Pending To Dos'),
            _todos('Completed To Dos'),
          ],
        ),
      ),
    );
  }
}
