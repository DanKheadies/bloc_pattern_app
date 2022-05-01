import 'dart:async';
// import 'dart:html';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
// import 'package:meta/meta.dart';

import 'package:bloc_pattern_app/blocs/todos/todos_bloc.dart';
import 'package:bloc_pattern_app/models/todo.dart';
import 'package:bloc_pattern_app/models/todos_filter.dart';

part 'todos_filter_event.dart';
part 'todos_filter_state.dart';

class TodosFilterBloc extends Bloc<TodosFilterEvent, TodosFilterState> {
  final TodosBloc _todosBloc;
  late StreamSubscription _todosSubscription;

  TodosFilterBloc({
    required TodosBloc todosBloc,
  })  : _todosBloc = todosBloc,
        super(TodosFilterLoading()) {
    on<UpdateFilter>(_onUpdateFilter);
    on<UpdateTodos>(_onUpdateTodos);

    _todosSubscription = todosBloc.stream.listen((state) {
      add(
        const UpdateFilter(),
      );
    });
  }

  void _onUpdateFilter(UpdateFilter event, Emitter<TodosFilterState> emit) {
    if (state is TodosFilterLoading) {
      add(
        const UpdateTodos(todosFilter: TodosFilter.pending),
      );
    }

    if (state is TodosFilterLoaded) {
      final state = this.state as TodosFilterLoaded;

      add(
        UpdateTodos(todosFilter: state.todosFilter),
      );
    }
  }

  void _onUpdateTodos(UpdateTodos event, Emitter<TodosFilterState> emit) {
    final state = _todosBloc.state;
    if (state is TodosLoaded) {
      List<Todo> todos = state.todos.where((todo) {
        switch (event.todosFilter) {
          case TodosFilter.all:
            return true;
          case TodosFilter.completed:
            return todo.isCompleted!;
          case TodosFilter.cancelled:
            return todo.isCancelled!;
          case TodosFilter.pending:
            return !(todo.isCancelled! || todo.isCompleted!);
          default:
            return true;
        }
      }).toList();

      emit(
        TodosFilterLoaded(
          filteredTodos: todos,
          todosFilter: event.todosFilter,
        ),
      );
    }
  }
}
