import 'dart:convert';
import 'dart:html' as html;
import 'dart:html';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart' hide TableRow;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CSV Data Viewer',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CSV Data Viewer'),
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
  List<String> markNumbers = [];
  List<String> sections = [];
  List<String> lengths = [];
  List<int> quantities = [];
  List<int> totalOrderLengths = [];
  List<Map<String, dynamic>> totalOrder = [];

  List<String> vendorNames = [];
  List<String> documentDate = [];
  List<String> documentNumber = [];
  List<int> balancedPiece = [];
  List<int> pendingDays = [];
  List<int> rawLength = [];
  List<int> totalRawLength = [];
  List<Map<String, dynamic>> totalRaw = [];

  // Ensure you have imported html library for FileUploadInputElement

  Future<void> pickFirstFile() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.csv';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      if (uploadInput.files!.isEmpty) return;

      final file1 = uploadInput.files![0];
      final data1 = await _parseCsvFile(
          file1); // Assuming _parseCsvFile is your CSV parsing function

      setState(() {
        markNumbers.clear();
        sections.clear();
        lengths.clear();
        quantities.clear();
        totalOrderLengths.clear();
        totalOrder.clear(); // Clear previous data if needed

        // Parse and store data for file 1
        for (var i = 1; i < data1.length; i++) {
          if (data1[i].length >= 9) {
            markNumbers.add(data1[i][2].toString()); // Index 2 for Mark No.
            sections.add(data1[i][3].toString()); // Index 3 for Section
            lengths.add(data1[i][5].toString()); // Index 5 for Length
            int quantity = int.tryParse(data1[i][8].toString()) ?? 0;
            quantities.add(quantity); // Index 8 for Qty.

            int length = int.tryParse(data1[i][5].toString()) ?? 0;
            for (int j = 0; j < quantity; j++) {
              totalOrderLengths.add(length);
              totalOrder.add({
                'Id': i,
                'MarkNo': data1[i][2].toString(),
                'Section': data1[i][3].toString(),
                'Length': length,
              });
            }
          }
        }
        // print('Total Order Lengths: $totalOrderLengths');
        // print('Total Order:');
        // print(totalOrder);
      });
    });
  }

  Future<void> pickSecondFile() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.csv';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      if (uploadInput.files!.isEmpty) return;

      final file2 = uploadInput.files![0];
      final data2 = await _parseCsvFile(file2);
      print("file uploaded");

      setState(() {
        vendorNames.clear();
        documentDate.clear();
        documentNumber.clear();
        balancedPiece.clear();
        pendingDays.clear();
        rawLength.clear();
        totalRawLength.clear();

        // Parse and store data for file 2
        for (var i = 2; i < data2.length; i++) {
          if (data2[i].length >= 27) {
            vendorNames.add(data2[i][9].toString()); // Index 9 for Vendor Name
            documentDate
                .add(data2[i][8].toString()); // Index 8 for Document Date
            documentNumber
                .add(data2[i][7].toString()); // Index 7 for Document Number
            int bal = int.tryParse(data2[i][20].toString()) ?? 0;
            balancedPiece.add(bal);
            int days = int.tryParse(data2[i][23].toString()) ?? 0;
            pendingDays.add(days);

            int length = int.tryParse(data2[i][27].toString()) ??
                0; // Index 27 for Raw Length
            rawLength.add(length);

            int quantity = int.tryParse(data2[i][20].toString()) ?? 0;
            for (int j = 0; j < quantity; j++) {
              totalRawLength.add(length);
              totalRaw.add({
                'RawMaterialId': i - 1,
                'vendorNames': data2[i][9].toString(),
                'documentDate': data2[i][8].toString(),
                'documentNumber': data2[i][7].toString(),
                'pendingDays': int.tryParse(data2[i][23].toString()) ?? 0,
                'rawLength': length,
              });
            }
          }
        }

        // print('Total Raw Length: $totalRawLength');
        // print('Total Raw');
        // print(totalRaw);
      });
    });
  }

  Future<List<List<dynamic>>> _parseCsvFile(html.File file) async {
    var reader = html.FileReader();
    reader.readAsText(file);
    await reader.onLoadEnd.first;
    String content = reader.result as String;
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(content);
    return csvTable;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 40,
                children: [
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: pickFirstFile,
                      child: const Text('Pick First CSV File'),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: pickSecondFile,
                  child: const Text('Pick Second CSV File'),
                ),
              ),
              const SizedBox(height: 20),
              (rawLength.isNotEmpty && lengths.isNotEmpty)
                  ? SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          if (rawLength.isNotEmpty && lengths.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RawMaterialOrderMatcher(
                                  totalOrder: totalOrder,
                                  totalRaw: totalRaw,
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Calculate '),
                      ),
                    )
                  : const SizedBox.shrink(),
              if (markNumbers.isNotEmpty) ...[
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Mark Number')),
                    DataColumn(label: Text('Section')),
                    DataColumn(label: Text('Length')),
                    DataColumn(label: Text('Quantity')),
                  ],
                  rows: List.generate(
                    markNumbers.length,
                    (index) => DataRow(cells: [
                      DataCell(Text(markNumbers[index])),
                      DataCell(Text(sections[index])),
                      DataCell(Text(lengths[index])),
                      DataCell(Text(quantities[index].toString())),
                    ]),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (rawLength.isNotEmpty) ...[
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Vendor Name')),
                    DataColumn(label: Text('Document Date')),
                    DataColumn(label: Text('Document Number')),
                    DataColumn(label: Text('Pending Days')),
                    DataColumn(label: Text('Raw Length')),
                    DataColumn(label: Text('Balanced')),
                  ],
                  rows: List.generate(
                    vendorNames.length,
                    (index) => DataRow(cells: [
                      DataCell(Text(vendorNames[index])),
                      DataCell(Text(documentDate[index])),
                      DataCell(Text(documentNumber[index])),
                      DataCell(Text(pendingDays[index].toString())),
                      DataCell(Text(rawLength[index].toString())),
                      DataCell(Text(balancedPiece[index].toString())),
                    ]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class RawMaterialOrderMatcher extends StatefulWidget {
  final List<Map<String, dynamic>> totalOrder;
  final List<Map<String, dynamic>> totalRaw;

  const RawMaterialOrderMatcher({
    super.key,
    required this.totalOrder,
    required this.totalRaw,
  });

  @override
  _RawMaterialOrderMatcherState createState() =>
      _RawMaterialOrderMatcherState();
}

class _RawMaterialOrderMatcherState extends State<RawMaterialOrderMatcher> {
  List<Map<String, dynamic>> rawMaterials = [];
  List<Map<String, dynamic>> orders = [];
  List<int> fulfilledOrders = [];
  Map<int, List<int>> rawMaterialUsage = {};
  Set<int> unusedRawMaterials = {};
  double totalScrap = 0;
  List<Map<String, dynamic>> selectedCombinations = [];

  @override
  void initState() {
    super.initState();
    _matchOrdersWithRawMaterials();
  }

  void _matchOrdersWithRawMaterials() {
    rawMaterials = widget.totalRaw.map((rawMaterial) {
      return {
        'RawMaterialId': rawMaterial['RawMaterialId'],
        'rawLength': rawMaterial['rawLength'],
      };
    }).toList();

    orders = widget.totalOrder.map((order) {
      return {
        'Id': order['Id'],
        'Length': order['Length'],
      };
    }).toList();
    // print("rawMaterials${widget.totalRaw}");
    // print("orders${widget.totalOrder}");

    calculateUsage();
  }

  void exportToCsv(String csvData) {
    final encodedCsv = utf8.encode(csvData);
    final blob = Blob([encodedCsv]);
    final url = Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'selected_combinations.csv')
      ..click();
    html.Url.revokeObjectUrl(url);

    Url.revokeObjectUrl(url);
  }

  void calculateUsage() {
    // Sorting raw materials and orders by their lengths in descending order
    rawMaterials.sort((a, b) => b['rawLength'].compareTo(a['rawLength']));
    orders.sort((a, b) => b['Length'].compareTo(a['Length']));

    rawMaterialUsage.clear();
    unusedRawMaterials = Set.from(
        rawMaterials.map((rawMaterial) => rawMaterial['RawMaterialId']));
    fulfilledOrders.clear();
    totalScrap = 0;

    for (var rawMaterial in rawMaterials) {
      int leftover = rawMaterial['rawLength'];
      rawMaterialUsage[rawMaterial['rawLength']] = [];

      for (var order in orders) {
        int orderLength =
            order['Length']; // Ensure order length is treated as an integer
        if (leftover - orderLength >= 80) {
          rawMaterialUsage[rawMaterial['rawLength']]!.add(order['Length']);
          fulfilledOrders
              .add(order['Id']); // Add order ID to the fulfilledOrders set
          leftover -= orderLength;
        }
      }

      totalScrap += leftover;
      if (rawMaterialUsage[rawMaterial['rawLength']]!.isEmpty) {
        rawMaterialUsage.remove(rawMaterial['rawLength']);
      } else {
        unusedRawMaterials.remove(rawMaterial['rawLength']);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void handleSelection(int selectedRawMaterialLength) {
    List<int> orderIds = [];
    List<int> selectedOrders = rawMaterialUsage[selectedRawMaterialLength]!;
    int usedAmount = selectedOrders.fold(
      0,
      (sum, length) {
        var order = orders.firstWhere((order) => order['Length'] == length);
        orderIds.add(order['Id']);

        return sum + length; // Cast length to int
      },
    );
    int leftover = rawMaterials.firstWhere((rawMaterial) =>
            rawMaterial['rawLength'] ==
            selectedRawMaterialLength)['rawLength'] -
        usedAmount;
    int selectedRawMaterialId = rawMaterials.firstWhere((rawMaterial) =>
        rawMaterial['rawLength'] == selectedRawMaterialLength)['RawMaterialId'];

    rawMaterials.removeWhere(
        (rawMaterial) => rawMaterial['rawLength'] == selectedRawMaterialLength);
    for (var orderId in selectedOrders) {
      orders.removeWhere((order) => order['Length'] == orderId);
    }

    selectedCombinations.add({
      'rawMaterial': selectedRawMaterialLength,
      'RawMaterialId': selectedRawMaterialId,
      'orders': selectedOrders,
      'Ids': orderIds,
      'leftover': leftover
    });

    calculateUsage();
  }

  @override
  Widget build(BuildContext context) {
    int totalFulfilled =
        fulfilledOrders.isNotEmpty ? fulfilledOrders.length : 0;

    // Calculate total leftover raw materials
    int totalRawMaterial = rawMaterials.isNotEmpty
        ? rawMaterials
            .map((rawMaterial) => rawMaterial['rawLength'])
            .reduce((a, b) => a + b)
        : 0;
    int totalLeftoverRawMaterial = totalRawMaterial - totalFulfilled;
    List<int> rawLengths =
        rawMaterials.map((material) => material["rawLength"] as int).toList();
    List<int> orderLength =
        orders.map((order) => order["Length"] as int).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Raw Material Order Matcher')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Raw Material: $rawLengths"),
            Text("Total Orders: $orderLength"),
            Text("Total Orders: ${orders.length}"),
            Text("Total Fulfilled: $totalFulfilled"),
            Text("Total Leftover Raw Material: $totalLeftoverRawMaterial"),
            Text("Total Scrap: $totalScrap"),
            ...rawMaterialUsage.entries.map((entry) {
              int rawMaterial = entry.key;
              List<int> orders = entry.value;
              int usedAmount = orders.reduce((a, b) => a + b);
              int leftover = rawMaterial - usedAmount;
              return ListTile(
                title: Text(
                    "Raw material $rawMaterial used in orders: $orders and leftover is $leftover"),
              );
            }),
            // Text("Unused Raw Materials: $unusedRawMaterials"),
            const SizedBox(height: 20),
            if (rawMaterialUsage.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Select Best Combination'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: rawMaterialUsage.entries.map((entry) {
                            int rawMaterial = entry.key;
                            List<int> orders = entry.value;
                            int usedAmount = orders.reduce((a, b) => a + b);
                            int leftover = rawMaterial - usedAmount;
                            return ListTile(
                              title: Text(
                                  "Raw material $rawMaterial used in orders: $orders and leftover is $leftover"),
                              onTap: () {
                                handleSelection(rawMaterial);
                                Navigator.of(context).pop();
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                },
                child: const Text('Select Best Combination'),
              ),
            const SizedBox(height: 20),
            if (selectedCombinations.isNotEmpty)
              Expanded(
                child: selectedCombinationsTable(
                  selectedCombinations,
                  widget.totalRaw,
                  widget.totalOrder,
                ),
              ),
            if (rawMaterials.isEmpty || orders.isEmpty) ...[
              const Text("Selected Combinations:"),
              ...selectedCombinations.map((combination) {
                int rawMaterial = combination['rawMaterial'];
                List<int> orders = combination['orders'];
                int leftover = combination['leftover'];
                return ListTile(
                  title: Text(
                      "Raw material $rawMaterial used in orders: $orders and leftover is $leftover"),
                );
              }),
              const SizedBox(height: 20),
              Wrap(
                spacing: 40,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      String csvData = generateCsv(
                        selectedCombinations,
                        widget.totalRaw,
                        widget.totalOrder,
                      );
                      exportToCsv(csvData);
                      // print(selectedCombinations);
                    },
                    // onPressed: downloadCsv,
                    child: const Text('Download CSV'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      generatePdfWeb(
                        selectedCombinations,
                        widget.totalRaw,
                        widget.totalOrder,
                      );
                    },
                    // onPressed: downloadCsv,
                    child: const Text('Download Pdf'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget selectedCombinationsTable(
      List<Map<String, dynamic>> selectedCombinations,
      List<Map<String, dynamic>> rawMaterials,
      List<Map<String, dynamic>> orders) {
    double calculateDataRowHeight() {
      double maxHeight = 0.0;

      // Iterate through selectedCombinations to calculate maximum height needed
      for (var combination in selectedCombinations) {
        int rawMaterialId = combination['RawMaterialId'];
        List<int> orderIds = combination['Ids'];
        List<Map<String, dynamic>> matchingRawMaterials = rawMaterials
            .where(
                (rawMaterial) => rawMaterial['RawMaterialId'] == rawMaterialId)
            .toList();
        List<Map<String, dynamic>> matchingOrders =
            orders.where((order) => orderIds.contains(order['Id'])).toList();

        // Calculate height based on content in each cell
        double totalHeight = 0.0;
        totalHeight += 10.0; // Height of the first cell (RawMaterialId)
        totalHeight += 10.0; // Height of the second cell (Raw Length)
        totalHeight += 10.0; // Height of the third cell (Vendor Name)
        totalHeight += 10.0; // Height of the fourth cell (Document Date)
        totalHeight += 10.0; // Height of the fifth cell (Document Number)
        totalHeight += 10.0; // Height of the sixth cell (Pending Days)
        totalHeight +=
            10.0 * matchingOrders.length; // Height of Order ID cell(s)
        totalHeight +=
            10.0 * matchingOrders.length; // Height of Order Length cell(s)
        totalHeight +=
            10.0 * matchingOrders.length; // Height of Section cell(s)
        totalHeight +=
            10.0 * matchingOrders.length; // Height of Mark Number cell(s)

        // Update maxHeight if totalHeight is greater
        if (totalHeight > maxHeight) {
          maxHeight = totalHeight;
        }
      }

      // Add some padding (optional) to ensure content fits comfortably
      return maxHeight + 20.0;
    }

    return SingleChildScrollView(
      child: DataTable(
        dataRowHeight:
            calculateDataRowHeight(), // Adjust the height of each DataRow
        columns: const [
          DataColumn(label: Text('RawMaterialId')),
          DataColumn(label: Text('Raw Length')),
          DataColumn(label: Text('Vendor Name')),
          DataColumn(label: Text('Document Date')),
          DataColumn(label: Text('Document Number')),
          DataColumn(label: Text('Pending Days')),
          DataColumn(label: Text('Order ID')),
          DataColumn(label: Text('Order Length')),
          DataColumn(label: Text('Section')),
          DataColumn(label: Text('Mark Number')),
        ],
        rows: selectedCombinations.map((combination) {
          Set<int> seenIds = <int>{};
          List<Map<String, dynamic>> uniqueOrders = [];

          for (var order in orders) {
            if (!seenIds.contains(order['Id'])) {
              uniqueOrders.add(order);
              seenIds.add(order['Id']);
            }
          }
          int rawMaterialId = combination['RawMaterialId'];
          List<int> orderIds = combination['Ids'];
          List<Map<String, dynamic>> matchingRawMaterials = rawMaterials
              .where((rawMaterial) =>
                  rawMaterial['RawMaterialId'] == rawMaterialId)
              .toList();
          // List<Map<String, dynamic>> matchingOrders =
          //     orders.where((order) => orderIds.contains(order['Id'])).toList();
          List<Map<String, dynamic>> matchingOrders = [];
          // Use a Set to keep track of seen orderIds to avoid duplicates
          Set<int> seenOrderIds = {};

          // Iterate through each orderId in orderIds
          for (int orderId in orderIds) {
            // Find all orders that match the current orderId
            List<Map<String, dynamic>> ordersForId =
                uniqueOrders.where((order) => order['Id'] == orderId).toList();

            // Add each order found to matchingOrders
            for (var order in ordersForId) {
              matchingOrders.add(order);
            }
          }
          // print("orders$orders");
          // print("rawMaterialId$rawMaterialId");
          // print("orderIds$orderIds");
          // print("matchingRawMaterials$matchingRawMaterials");
          // print("matchingOrders$matchingOrders");

          return DataRow(cells: [
            DataCell(Text('$rawMaterialId')),
            DataCell(Text(
                '${matchingRawMaterials.isNotEmpty ? matchingRawMaterials[0]['rawLength'] : ''}')),
            DataCell(Text(
              '${matchingRawMaterials.isNotEmpty ? matchingRawMaterials[0]['vendorNames'] : ''}',
              maxLines: 2, // Limit lines to avoid excessive height
              overflow: TextOverflow.ellipsis, // Handle overflow
            )),
            DataCell(Text(
                '${matchingRawMaterials.isNotEmpty ? matchingRawMaterials[0]['documentDate'] : ''}')),
            DataCell(Text(
                '${matchingRawMaterials.isNotEmpty ? matchingRawMaterials[0]['documentNumber'] : ''}')),
            DataCell(Text(
                '${matchingRawMaterials.isNotEmpty ? matchingRawMaterials[0]['pendingDays'] : ''}')),
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: matchingOrders
                  .map((order) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${order['Id']}'),
                      ))
                  .toList(),
            )),
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: matchingOrders
                  .map((order) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${order['Length']}'),
                      ))
                  .toList(),
            )),
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: matchingOrders
                  .map((order) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${order['Section']}'),
                      ))
                  .toList(),
            )),
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: matchingOrders
                  .map((order) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${order['MarkNo']}'),
                      ))
                  .toList(),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  String generateCsv(
      List<Map<String, dynamic>> selectedCombinations,
      List<Map<String, dynamic>> rawMaterials,
      List<Map<String, dynamic>> orders) {
    // Define headers for CSV
    List<List<dynamic>> csvData = [
      [
        'RawMaterialId',
        'Raw Length',
        'Vendor Name',
        'Document Date',
        'Document Number',
        'Pending Days',
        'Order ID',
        'Order Length',
        'Section',
        'Mark Number',
      ]
    ];

    // Add rows based on selectedCombinations
    for (var combination in selectedCombinations) {
      Set<int> seenIds = <int>{};
      List<Map<String, dynamic>> uniqueOrders = [];

      for (var order in orders) {
        if (!seenIds.contains(order['Id'])) {
          uniqueOrders.add(order);
          seenIds.add(order['Id']);
        }
      }
      int rawMaterialId = combination['RawMaterialId'];
      List<int> orderIds = combination['Ids'];
      List<Map<String, dynamic>> matchingRawMaterials = rawMaterials
          .where((rawMaterial) => rawMaterial['RawMaterialId'] == rawMaterialId)
          .toList();
      // List<Map<String, dynamic>> matchingOrders =
      //     orders.where((order) => orderIds.contains(order['Id'])).toList();
      List<Map<String, dynamic>> matchingOrders = [];
      // Use a Set to keep track of seen orderIds to avoid duplicates
      Set<int> seenOrderIds = {};

// Iterate through each orderId in orderIds
      for (int orderId in orderIds) {
        // Find all orders that match the current orderId
        List<Map<String, dynamic>> ordersForId =
            uniqueOrders.where((order) => order['Id'] == orderId).toList();

        // Add each order found to matchingOrders
        for (var order in ordersForId) {
          matchingOrders.add(order);
        }
      }

      // Prepare data for each row
      List<dynamic> rowData = [
        rawMaterialId.toString(),
        matchingRawMaterials.isNotEmpty
            ? matchingRawMaterials[0]['rawLength'].toString()
            : '',
        matchingRawMaterials.isNotEmpty
            ? matchingRawMaterials[0]['vendorNames'].toString()
            : '',
        matchingRawMaterials.isNotEmpty
            ? matchingRawMaterials[0]['documentDate'].toString()
            : '',
        matchingRawMaterials.isNotEmpty
            ? matchingRawMaterials[0]['documentNumber'].toString()
            : '',
        matchingRawMaterials.isNotEmpty
            ? matchingRawMaterials[0]['pendingDays'].toString()
            : '',
        matchingOrders.map((order) => order['Id'].toString()).join(', '),
        matchingOrders.map((order) => order['Length'].toString()).join(', '),
        matchingOrders.map((order) => order['Section'].toString()).join(', '),
        matchingOrders.map((order) => order['MarkNo'].toString()).join(', '),
      ];

      csvData.add(rowData);
    }

    // Convert to CSV format
    String csv = const ListToCsvConverter().convert(csvData);
    return csv;
  }

  Future<void> generatePdfWeb(
      List<Map<String, dynamic>> selectedCombinations,
      List<Map<String, dynamic>> rawMaterials,
      List<Map<String, dynamic>> orders) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape, // Set landscape orientation
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
              headers: [
                'RawM\nId',
                'Raw\n Length',
                'Vendor\n Name',
                'Document\n Date',
                'Document\n Number',
                'Pending\n Days',
                'Order\n ID',
                'Order\n Length',
                'Section',
                'Mark\n Number'
              ],
              data: selectedCombinations.map((combination) {
                int rawMaterialId = combination['RawMaterialId'];
                List<int> orderIds = combination['Ids'];
                List<Map<String, dynamic>> matchingRawMaterials = rawMaterials
                    .where((rawMaterial) =>
                        rawMaterial['RawMaterialId'] == rawMaterialId)
                    .toList();
                List<Map<String, dynamic>> matchingOrders = [];
                Set<int> seenOrderIds = {};

                for (int orderId in orderIds) {
                  List<Map<String, dynamic>> ordersForId =
                      orders.where((order) => order['Id'] == orderId).toList();
                  for (var order in ordersForId) {
                    matchingOrders.add(order);
                  }
                }

                return [
                  '$rawMaterialId',
                  '${matchingRawMaterials.isNotEmpty ? matchingRawMaterials[0]['rawLength'] : ''}',
                  '${matchingRawMaterials.isNotEmpty ? matchingRawMaterials[0]['vendorNames'] : ''}',
                  '${matchingRawMaterials.isNotEmpty ? matchingRawMaterials[0]['documentDate'] : ''}',
                  '${matchingRawMaterials.isNotEmpty ? matchingRawMaterials[0]['documentNumber'] : ''}',
                  '${matchingRawMaterials.isNotEmpty ? matchingRawMaterials[0]['pendingDays'] : ''}',
                  matchingOrders.map((order) => '${order['Id']}').join('\n'),
                  matchingOrders
                      .map((order) => '${order['Length']}')
                      .join('\n'),
                  matchingOrders
                      .map((order) => '${order['Section']}')
                      .join('\n'),
                  matchingOrders.map((order) => '${order['MarkNo']}').join('\n')
                ];
              }).toList(),
              cellStyle:
                  const pw.TextStyle(fontSize: 14), // Set smaller font size
              headerStyle: pw.TextStyle(
                  fontSize: 10,
                  fontWeight:
                      pw.FontWeight.bold), // Set smaller font size for header
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.center,
              columnWidths: {
                0: const pw.FlexColumnWidth(0.8),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
                5: const pw.FlexColumnWidth(1),
                6: const pw.FlexColumnWidth(0.8),
                7: const pw.FlexColumnWidth(1),
                8: const pw.FlexColumnWidth(1.8),
                9: const pw.FlexColumnWidth(1.8),
              });
        },
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url);
    anchor.setAttribute('download', 'selected_combinations.pdf');
    anchor.click();
    html.Url.revokeObjectUrl(url);
  }
}
