import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multiplexor Web',
      home: MultiplexorPage(),
    );
  }
}

class MultiplexorPage extends StatelessWidget {
  final DatabaseReference multiplexor1Ref =
      FirebaseDatabase.instance.reference().child('multiplexor_1');
  final DatabaseReference multiplexor2Ref =
      FirebaseDatabase.instance.reference().child('multiplexor_2');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Titulo con estilo
              Center(
                child: Text(
                  'Tarea Práctica - Web Flutter',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Contenido con los multiplexores
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: MultiplexorColumn(
                      title: "Multiplexor 1",
                      ref: multiplexor1Ref,
                    ),
                  ),
                  SizedBox(width: 80),
                  Expanded(
                    child: MultiplexorColumn(
                      title: "Multiplexor 2",
                      ref: multiplexor2Ref,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              // Pie de pagina con autores
              Divider(),
              Text(
                'Alumnos: Sebastián Araneda - Vicente Sanhueza - Universidad del Bío-Bío.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MultiplexorColumn extends StatefulWidget {
  final String title;
  final DatabaseReference ref;

  const MultiplexorColumn({required this.title, required this.ref});

  @override
  _MultiplexorColumnState createState() => _MultiplexorColumnState();
}

class _MultiplexorColumnState extends State<MultiplexorColumn> {
  int currentPage = 0;
  static const int eventsPerPage = 24;

  void _nextPage(int totalPages) {
    if (currentPage < totalPages - 1) {
      setState(() => currentPage++);
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      setState(() => currentPage--);
    }
  }

  Widget _buildEventCard(MapEntry entry, int eventNumber, bool isMostRecent) {
    final values = entry.value as Map<dynamic, dynamic>;
    final timestampString = entry.key.toString();

    DateTime dateTime;
    try {
      dateTime = DateTime.parse(timestampString);
    } catch (e) {
      dateTime = DateTime.now();
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.24,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4),
        child: ExpansionTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  "Evento #$eventNumber - ${dateTime.toLocal().toString().substring(0, 19)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMostRecent ? Colors.green : Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isMostRecent)
                Icon(Icons.star, color: Colors.green, size: 18),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: List.generate(4, (col) {
                      final columnItems = values.entries
                          .skip(col * 4)
                          .take(4)
                          .map((e) => Text("${e.key}: ${e.value}", style: TextStyle(fontSize: 13)))
                          .toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: columnItems,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.ref.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<MapEntry<dynamic, dynamic>> entries = data.entries.toList()
            ..sort((a, b) => b.key.compareTo(a.key));

          final totalEvents = entries.length;
          final totalPages = (totalEvents / eventsPerPage).ceil();
          final start = currentPage * eventsPerPage;
          final end = ((currentPage + 1) * eventsPerPage).clamp(0, totalEvents);
          final pageEvents = entries.sublist(start, end);

          final latest12Events = pageEvents.take(12).toList();
          final older12Events = pageEvents.skip(12).toList();

          final mostRecentEvent = entries.first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(latest12Events.length, (index) {
                        final entry = latest12Events[index];
                        final eventNumber = totalEvents - (start + index);
                        return _buildEventCard(entry, eventNumber, entry == mostRecentEvent);
                      }),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(older12Events.length, (index) {
                        final entry = older12Events[index];
                        final eventNumber = totalEvents - (start + index + 12);
                        return _buildEventCard(entry, eventNumber, entry == mostRecentEvent);
                      }),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: currentPage > 0 ? _previousPage : null,
                    child: Text('Anterior'),
                  ),
                  SizedBox(width: 16),
                  Text('Página ${currentPage + 1} de $totalPages'),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: currentPage < totalPages - 1 ? () => _nextPage(totalPages) : null,
                    child: Text('Siguiente'),
                  ),
                ],
              )
            ],
          );
        } else {
          return Text('No hay datos disponibles');
        }
      },
    );
  }
}
