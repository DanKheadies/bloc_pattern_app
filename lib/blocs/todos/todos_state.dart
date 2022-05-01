part of 'todos_bloc.dart';

abstract class TodosState extends Equatable {
  @override
  List<Object> get props => [];
}

class TodosLoading extends TodosState {}

class TodosLoaded extends TodosState {
  final List<Todo> todos;

  TodosLoaded({
    this.todos = const <Todo>[],
  });

  @override
  List<Object> get props => [todos];
}
