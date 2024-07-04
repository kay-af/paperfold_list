import 'package:flutter/material.dart';
import 'package:paperfold_list/paperfold_list.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SafeArea(
        child: ExamplePage(),
      ),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  bool folded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            folded = !folded;
          });
        },
        child: const Icon(Icons.flip),
      ),
      body: SingleChildScrollView(
        child: PaperfoldList(
          itemExtent: 60,
          targetUnfold: folded ? 0 : 1,
          animationDuration: const Duration(seconds: 2),
          unmountOnFold: true,
          children: List.generate(
            100,
            (index) => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Sint veniam consequat nulla sunt. Dolore enim Lorem veniam cupidatat in amet eu sunt consequat culpa incididunt. Culpa labore culpa adipisicing enim exercitation eu aute.",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
