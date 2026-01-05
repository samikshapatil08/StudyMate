import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../theme.dart';
import '../blocs/todo/todo_bloc.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Your Tasks",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  BlocBuilder<TodoBloc, TodoState>(
                    builder: (context, state) {
                      bool isCalendar = false;
                      if (state is TodosLoaded) {
                        isCalendar = state.isCalendarView;
                      }
                      return IconButton(
                        icon: Icon(
                          isCalendar ? Icons.list_alt : Icons.calendar_month,
                          color: AppTheme.primaryPurple,
                        ),
                        onPressed: () =>
                            context.read<TodoBloc>().add(TodoViewToggled()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: AppTheme.primaryPurple, size: 28),
                    onPressed: () => _addTodoDialog(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  onChanged: (val) =>
                      context.read<TodoBloc>().add(TodoSearchChanged(val)),
                  decoration: InputDecoration(
                    hintText: "Search tasks...",
                    hintStyle: GoogleFonts.inter(
                        color: theme.textTheme.bodyMedium?.color),
                    prefixIcon: Icon(Icons.search,
                        color: theme.textTheme.bodyMedium?.color),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<TodoBloc, TodoState>(
                builder: (context, state) {
                  if (state is TodosLoading || state is TodosInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is TodosError) {
                    return Center(child: Text(state.message));
                  }

                  final loadedState = state as TodosLoaded;
                  if (loadedState.isCalendarView) {
                    return _buildCalendarView(loadedState.filteredTodos, theme);
                  }

                  if (loadedState.filteredTodos.isEmpty) {
                    return const Center(child: Text("No tasks found"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: loadedState.filteredTodos.length,
                    itemBuilder: (context, index) =>
                        _buildTodoItem(loadedState.filteredTodos[index], theme),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(
      List<QueryDocumentSnapshot> todos, ThemeData theme) {
    final selectedDayTasks =
        _getEventsForDay(todos, _selectedDay ?? DateTime.now());
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => _getEventsForDay(todos, day),
            onDaySelected: (sel, foc) {
              setState(() {
                _selectedDay = sel;
                _focusedDay = foc;
              });
            },
            onFormatChanged: (fmt) {
              if (_calendarFormat != fmt) {
                setState(() => _calendarFormat = fmt);
              }
            },
            onPageChanged: (foc) => _focusedDay = foc,
            calendarStyle: CalendarStyle(
              defaultTextStyle:
                  TextStyle(color: theme.textTheme.bodyLarge?.color),
              weekendTextStyle:
                  TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleTextStyle:
                  TextStyle(color: theme.textTheme.bodyLarge?.color),
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: theme.iconTheme.color),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: theme.iconTheme.color),
            ),
          ),
        ),
        if (_selectedDay != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tasks for ${_formatDate(_selectedDay!)}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
          ),
        Flexible(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: selectedDayTasks.length,
            itemBuilder: (context, index) =>
                _buildTodoItem(selectedDayTasks[index], theme),
          ),
        ),
      ],
    );
  }

  Widget _buildTodoItem(QueryDocumentSnapshot todo, ThemeData theme) {
    final data = todo.data() as Map<String, dynamic>;
    final deadline = data['deadline'] != null
        ? (data['deadline'] as Timestamp).toDate()
        : null;
    final isDone = data['isDone'] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: Key(todo.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (ctx) =>
                  context.read<TodoBloc>().add(TodoDeleteRequested(todo.id)),
              backgroundColor: Colors.red,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Checkbox(
              value: isDone,
              activeColor: AppTheme.primaryPurple,
              onChanged: (val) => context
                  .read<TodoBloc>()
                  .add(TodoToggleRequested(todo.id, val ?? false)),
            ),
            title: Text(
              data['title'] ?? '',
              style: GoogleFonts.inter(
                color: isDone ? Colors.grey : theme.textTheme.bodyLarge?.color,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: deadline != null
                ? Text(
                    "Due: ${_formatDate(deadline)}",
                    style: TextStyle(
                      color: deadline.isBefore(DateTime.now()) && !isDone
                          ? Colors.red
                          : Colors.grey,
                      fontSize: 12,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  List<QueryDocumentSnapshot> _getEventsForDay(
      List<QueryDocumentSnapshot> all, DateTime day) {
    return all.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final d = data['deadline'];
      return d != null && isSameDay((d as Timestamp).toDate(), day);
    }).toList();
  }

  String _formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}";

  void _addTodoDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final theme = Theme.of(context);
    DateTime? selDate;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text("New Task", style: TextStyle(color: theme.textTheme.bodyLarge?.color),),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(labelText: "Task Name")),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    final p = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (p != null) {
                      setS(() => selDate = p);
                    }
                  },
                  child: Text(selDate == null
                      ? "Set Deadline"
                      : "Due: ${_formatDate(selDate!)}"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                context
                    .read<TodoBloc>()
                    .add(TodoAddRequested(ctrl.text, deadline: selDate));
                Navigator.pop(ctx);
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}
