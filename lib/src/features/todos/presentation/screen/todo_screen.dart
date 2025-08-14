import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../data/models/todos/todos.dart';
import '../bloc/todos_bloc/todos_bloc.dart';
import '../../../../core/widgets/message_field.dart';
import '../widgets/todo_card.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  initState() {
    super.initState();
    todoController = TextEditingController();
  }

  late TextEditingController todoController;

  @override
  void dispose() {
    super.dispose();
    todoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat.yMMMEd().format(DateTime.now()).toString();
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<TodosBloc, TodosState>(
              builder: (context, state) {
                return switch (state) {
                  TodosLoadingState() => Center(
                      child: SizedBox(child: CircularProgressIndicator()),
                    ),
                  TodosLoadedState() => Builder(builder: (context) {
                      if (state.todo.isNotEmpty) {
                        return ListView.builder(
                          itemCount: state.todo.length,
                          padding: const EdgeInsets.all(15),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            Todos todo = state.todo[index];
                            return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: TodoCard(
                                  onTap: () {
                                    context.read<TodosBloc>().add(EditTodoEvent(
                                        todo: todo, index: index));
                                  },
                                  onChanged: (p0) {
                                    context.read<TodosBloc>().add(
                                        UpdateTodoEvent(
                                            todo: todo.copyWith(
                                                isCompleted: !todo.isCompleted),
                                            index: index));
                                  },
                                  onPressedSlidable: (p0) {
                                    context
                                        .read<TodosBloc>()
                                        .add(DeleteTodoEvent(index: index));
                                  },
                                  onDismissed: () {
                                    context
                                        .read<TodosBloc>()
                                        .add(DeleteTodoEvent(index: index));
                                  },
                                  value: todo.isCompleted,
                                  date: todo.date,
                                  todo: todo.todo,
                                ));
                          },
                        );
                      } else {
                        return Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20),
                            child: SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  Lottie.asset('assets/lottie/empty_list.json'),
                                  Text(
                                    'Everything looks empty here !',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    }),
                  TodoErrorState() => Center(
                      child: SizedBox(child: Text(state.errorMessage)),
                    ),
                  TodosEditingstate() => Builder(
                      builder: (context) {
                        TextEditingController editingController =
                            TextEditingController(text: state.todo.todo);
                        return Center(
                          child: MessageField(
                            maxLines: 1,
                            minLines: 1,
                            onComplete: (p0) {
                              context.read<TodosBloc>().add(UpdateTodoEvent(
                                  todo: state.todo
                                      .copyWith(todo: editingController.text),
                                  index: state.index));
                            },
                            autofocus: true,
                            onSubmitted: () => context.read<TodosBloc>().add(
                                UpdateTodoEvent(
                                    todo: state.todo
                                        .copyWith(todo: editingController.text),
                                    index: state.index)),
                            controller: editingController,
                            labelText: 'Edit your TODO',
                            icon: Icons.done_rounded,
                          ),
                        );
                      },
                    )
                };
              },
            ),
          ),
          BlocBuilder<TodosBloc, TodosState>(
            builder: (context, state) {
              if (state is TodosEditingstate) {
                return SizedBox();
              } else {
                return MessageField(
                  maxLines: 1,
                  minLines: 1,
                  onComplete: (p0) {
                    if (todoController.text.isNotEmpty) {
                      Todos todo = Todos(
                          isCompleted: false,
                          date: date,
                          todo: todoController.text);
                      context.read<TodosBloc>().add(AddtodoEvent(todo: todo));
                      todoController.clear();
                      FocusScope.of(context).unfocus();
                    }
                  },
                  controller: todoController,
                  onSubmitted: () {
                    if (todoController.text.isNotEmpty) {
                      Todos todo = Todos(
                          isCompleted: false,
                          date: date,
                          todo: todoController.text);
                      context.read<TodosBloc>().add(AddtodoEvent(todo: todo));
                      todoController.clear();
                      FocusScope.of(context).unfocus();
                    }
                  },
                  prompt: 'Write your TODO',
                );
              }
            },
          )
        ],
      ),
    );
  }
}
