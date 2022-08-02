import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final int _numPages = 10;
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    var pages = List.generate(
      _numPages,
      (index) => Center(
        child: Text("Page ${index + 1}"),
      ),
    );

    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.orange),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Number Paginator Example"),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).backgroundColor,
                child: pages[_currentPage - 1],
              ),
            ),
            NumberPaginator(
              numberPages: _numPages,
              onPageChange: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
