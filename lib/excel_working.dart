import 'dart:html' as html;
import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart' hide TableRow;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV Comparison',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CSV Comparison Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> commonHeaders = [];
  List<String> primaryKeys1 = [];
  List<String> primaryKeys2 = [];

  List<bool> selectedKeys1 = [];
  List<bool> selectedKeys2 = [];

  List<List<dynamic>> data1 = [];
  List<List<dynamic>> data2 = [];

  Future<void> pickFiles() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.csv';
    uploadInput.multiple = true;
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      if (uploadInput.files!.isEmpty) return;

      final file1 = uploadInput.files![0];
      final file2 =
          uploadInput.files!.length > 1 ? uploadInput.files![1] : null;

      final data1 = await _parseCsvFile(file1);
      final data2 =
          file2 != null ? await _parseCsvFile(file2) : <List<dynamic>>[];

      setState(() {
        this.data1 = data1;
        this.data2 = data2;
        commonHeaders.clear();
        primaryKeys1.clear();
        primaryKeys2.clear();
        selectedKeys1.clear();
        selectedKeys2.clear();
      });

      // Load common headers and data
      _loadData(data1, data2);
    });
  }

  Future<List<List<dynamic>>> _parseCsvFile(html.File file) async {
    var reader = html.FileReader();

    // Read file content as text
    reader.readAsText(file);

    // Wait for reading to complete
    await reader.onLoadEnd.first;

    // Parse CSV content
    String content = reader.result as String;
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(content);

    return csvTable;
  }

  void _loadData(List<List<dynamic>> data1, List<List<dynamic>> data2) {
    // Get headers
    List<String> headers1 =
        data1.first.map((header) => header.toString()).toList();
    List<String> headers2 = data2.isNotEmpty
        ? data2.first.map((header) => header.toString()).toList()
        : [];

    // Intersect headers
    commonHeaders = headers1.toSet().intersection(headers2.toSet()).toList();

    // Initialize selectedKeys based on common headers
    selectedKeys1.clear();
    selectedKeys1.addAll(List.generate(
      headers1.length,
      (index) => commonHeaders.contains(headers1[index]),
    ));

    selectedKeys2.clear();
    selectedKeys2.addAll(List.generate(
      headers2.length,
      (index) => commonHeaders.contains(headers2[index]),
    ));

    // Print data (for debugging)
    _printData(data1, 'Data from sheet1.csv:');
    _printData(data2, 'Data from sheet2.csv:');
  }

  void _printData(List<List<dynamic>> data, String title) {
    print(title);
    for (var row in data) {
      print(row.join(', '));
    }
    print('');
  }

  Future<void> compareAndUpdateSheets() async {
    // Prepare headers
    List<String> headers1 =
        data1.first.map((header) => header.toString()).toList();
    List<String> headers2 = data2.isNotEmpty
        ? data2.first.map((header) => header.toString()).toList()
        : [];

    // Initialize updated sheet with headers
    List<List<dynamic>> updatedSheet = [];

    // Create maps for quick lookup
    var dataMap1 = _createDataMap(data1, headers1[0]);
    var dataMap2 =
        _createDataMap(data2, headers2.isNotEmpty ? headers2[0] : '');

    // Iterate through sheet2 and merge data from sheet1 where IDs match
    for (var row2 in data2.skip(1)) {
      var id2 = row2[headers2.indexOf(headers2[0])]; // Get ID from sheet2

      if (dataMap1.containsKey(id2)) {
        var row1 = dataMap1[id2]!;
        var mergedRow = [
          ...row2,
          ...row1.skip(1) // Append data from sheet1, skipping ID column
        ];
        updatedSheet.add(mergedRow);
      } else {
        // Add row from sheet2 with empty fields for Name, Age, Location
        updatedSheet.add([...row2, '', '', '']);
      }
    }

    // Add rows from sheet1 that do not have matching IDs in sheet2
    for (var row1 in data1.skip(1)) {
      var id1 = row1[headers1.indexOf(headers1[0])]; // Get ID from sheet1
      if (!dataMap2.containsKey(id1)) {
        // Add row from sheet1 with empty Salary and Department
        updatedSheet.add([
          id1,
          '', '', // Empty fields for Salary, Department
          ...row1.skip(1) // Append Name, Age, Location from sheet1
        ]);
      }
    }

    // Sort updatedSheet by ID in ascending order
    updatedSheet.sort((a, b) => a[0].compareTo(b[0]));

    // Add headers from headers2 to updatedSheet
    updatedSheet.insert(0, headers2);

    // Print updated data with headers
    _printData2(updatedSheet, 'Updated Combined Data:');

    // Save updated CSV
    String csv = const ListToCsvConverter().convert(updatedSheet);
    final blob = html.Blob([csv]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'updated_sheet.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  // Helper method to create a data map based on ID
  Map<dynamic, List<dynamic>> _createDataMap(
      List<List<dynamic>> data, String idHeader) {
    var map = <dynamic, List<dynamic>>{};
    for (var row in data.skip(1)) {
      var id = row[data[0].indexOf(idHeader)];
      map[id] = row;
    }
    return map;
  }

  // Helper method to print data with headers
  void _printData2(List<List<dynamic>> data, String title) {
    print(title);
    for (var row in data) {
      print(row.join(', ')); // Join each row with comma and space
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Sheets Comparison'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: pickFiles,
                child: const Text('Pick CSV Files'),
              ),
              const SizedBox(height: 20),
              if (commonHeaders.isNotEmpty) ...[
                _buildFileHeaderSelection(
                    headers: commonHeaders,
                    selectedKeys: selectedKeys1,
                    fileNumber: 1),
                const SizedBox(height: 10),
                _buildFileHeaderSelection(
                    headers: commonHeaders,
                    selectedKeys: selectedKeys2,
                    fileNumber: 2),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Compare and update sheets
                    compareAndUpdateSheets();
                  },
                  child: const Text('Compare and Update Sheets'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileHeaderSelection(
      {required List<String> headers,
      required List<bool> selectedKeys,
      required int fileNumber}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Primary Keys for File $fileNumber',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: headers.length,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              title: Text(headers[index]),
              value: selectedKeys[index],
              onChanged: (value) {
                setState(() {
                  selectedKeys[index] = value!;
                });
              },
            );
          },
        ),
      ],
    );
  }
}
