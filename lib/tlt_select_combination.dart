import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Raw Material Usage')),
        body: const RawMaterialUsageScreen(),
      ),
    );
  }
}

class RawMaterialUsageScreen extends StatefulWidget {
  const RawMaterialUsageScreen({super.key});

  @override
  _RawMaterialUsageScreenState createState() => _RawMaterialUsageScreenState();
}

class _RawMaterialUsageScreenState extends State<RawMaterialUsageScreen> {
  List<int> rawMaterials = [6000, 5500, 3000, 8000];
  List<int> orders = [1542, 115, 1689, 559];

  List<int> fulfilledOrders = [];
  Map<int, List<int>> rawMaterialUsage = {};
  Set<int> unusedRawMaterials = {};
  double totalScrap = 0;

  List<Map<String, dynamic>> selectedCombinations = [];

  @override
  void initState() {
    super.initState();
    calculateUsage();
  }

  void calculateUsage() {
    rawMaterials.sort((a, b) => b.compareTo(a));
    orders.sort((a, b) => b.compareTo(a));

    rawMaterialUsage.clear();
    unusedRawMaterials = Set.from(rawMaterials);
    fulfilledOrders.clear();
    totalScrap = 0;

    for (var rawMaterial in rawMaterials) {
      int leftover = rawMaterial;
      rawMaterialUsage[rawMaterial] = [];

      for (var order in orders) {
        if (leftover - order >= 80) {
          rawMaterialUsage[rawMaterial]!.add(order);
          fulfilledOrders.add(order);
          leftover -= order;
        }
      }

      totalScrap += leftover;
      if (rawMaterialUsage[rawMaterial]!.isEmpty) {
        rawMaterialUsage.remove(rawMaterial);
      } else {
        unusedRawMaterials.remove(rawMaterial);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void handleSelection(int selectedRawMaterial) {
    List<int> selectedOrders = rawMaterialUsage[selectedRawMaterial]!;
    int usedAmount = selectedOrders.reduce((a, b) => a + b);
    int leftover = selectedRawMaterial - usedAmount;

    rawMaterials.remove(selectedRawMaterial);
    for (var order in selectedOrders) {
      orders.remove(order);
    }

    selectedCombinations.add({
      'rawMaterial': selectedRawMaterial,
      'orders': selectedOrders,
      'leftover': leftover
    });

    calculateUsage();
  }

  @override
  Widget build(BuildContext context) {
    int totalFulfilled = fulfilledOrders.isNotEmpty
        ? fulfilledOrders.reduce((a, b) => a + b)
        : 0;
    int totalLeftoverRawMaterial = rawMaterials.isNotEmpty
        ? rawMaterials.reduce((a, b) => a + b) - totalFulfilled
        : 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total RM: $rawMaterials"),
          Text("Fulfilled Orders: $fulfilledOrders"),
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
          Text("Unused Raw Materials: $unusedRawMaterials"),
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
          ],
        ],
      ),
    );
  }
}
