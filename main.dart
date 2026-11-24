import 'package:flutter/material.dart';

void main() {
  runApp(NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Мои заметки')),
        body: NotesWidget(),
      ),
    );
  }
}

class NotesWidget extends StatefulWidget {
  const NotesWidget({super.key});

  @override
  _NotesWidgetState createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  final TextEditingController _controller = TextEditingController();
  List<String> _notes = [];
  List<bool> _isImportant = [];
  int _editingIndex = -1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNote() {
    String inputValue = _controller.text;
    if (inputValue.isEmpty) return;

    setState(() {
      if (_editingIndex == -1) {
        _notes.add(inputValue);
        _isImportant.add(false);
      } else {
        _notes[_editingIndex] = inputValue;
        _editingIndex = -1;
      }
    });

    _controller.clear();
  }

  void _editNote(int index) {
    setState(() {
      _editingIndex = index;
      _controller.text = _notes[index];
    });
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
      _isImportant.removeAt(index);
      if (_editingIndex == index) {
        _editingIndex = -1;
        _controller.clear();
      } else if (_editingIndex > index) {
        _editingIndex--;
      }
    });
  }

  void _toggleImportant(int index) {
    setState(() {
      _isImportant[index] = !_isImportant[index];
    });
  }

  void _openNote(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Заметка'),
          content: Text(_notes[index]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: "Введите текст заметки"),
        ),
        ElevatedButton(
          onPressed: _saveNote,
          child: Text(_editingIndex == -1 ? 'Сохранить' : 'Обновить'),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: _notes.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openNote(index),
                onDoubleTap: () => _toggleImportant(index),
                onLongPress: () => _editNote(index),
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    _deleteNote(index);
                  } else if (details.primaryVelocity! > 0) {
                    setState(() {
                      _isImportant[index] = false;
                    });
                  }
                },
                child: Card(
                  color: _isImportant[index] ? Colors.yellow[100] : null,
                  child: ListTile(
                    title: Row(
                      children: [
                        if (_isImportant[index]) Text('⭐️ '),
                        Expanded(child: Text(_notes[index])),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}