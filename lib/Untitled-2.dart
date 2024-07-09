import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: RawMaterialOrderMatcher(),
  ));
}

class RawMaterialOrderMatcher extends StatefulWidget {
  const RawMaterialOrderMatcher({super.key});

  @override
  _RawMaterialOrderMatcherState createState() =>
      _RawMaterialOrderMatcherState();
}

class _RawMaterialOrderMatcherState extends State<RawMaterialOrderMatcher> {
  final List<int> rawMaterials = [
    5500,
    6000,
    6000,
    6000,
    5500,
    5500,
    6000,
    5500,
    6000,
    6000
  ];
  final List<int> orders = [
    1542,
    619,
    174,
    165,
    1689,
    599,
    599,
    1782,
    1689,
    599,
    599
  ];

  List<int> sortedRawMaterials = [];
  List<int> sortedOrders = [];

  List<int> fulfilledOrders = [];
  late Map<int, List<int>> usedMaterialsInOrders;
  int totalFulfilled = 0;
  int totalLeftover = 0;
  late Map<int, int> scrapAmounts;
  late Set<int> unusedRawMaterials;
  double totalScrap = 0;

  @override
  void initState() {
    super.initState();
    sortedRawMaterials = List.from(rawMaterials)
      ..sort((a, b) => b.compareTo(a));
    sortedOrders = List.from(orders)..sort((a, b) => b.compareTo(a));
    fulfilledOrders = [];
    usedMaterialsInOrders = {};
    totalFulfilled = 0;
    totalLeftover = 0;
    scrapAmounts = {};
    unusedRawMaterials = {};

    fulfillOrders();
    calculateScrap();
    unusedRawMaterials = getUnusedMaterials();
  }

  void fulfillOrders() {
    for (int rawMaterial in sortedRawMaterials) {
      List<int> currentOrders = [];
      int remainingMaterial = rawMaterial;

      for (int order in sortedOrders) {
        if (remainingMaterial >= order) {
          currentOrders.add(order);
          remainingMaterial -= order;
        }
      }

      if (currentOrders.isNotEmpty) {
        fulfilledOrders.addAll(currentOrders);
        usedMaterialsInOrders[rawMaterial] = List.from(currentOrders);
        totalFulfilled += currentOrders.fold(0, (sum, item) => sum + item);
      }

      totalLeftover += remainingMaterial;

      print(
          'Raw material $rawMaterial used in orders: $currentOrders and leftover is $remainingMaterial');
    }
  }

  void calculateScrap() {
    for (int rawMaterial in sortedRawMaterials) {
      if (usedMaterialsInOrders.containsKey(rawMaterial)) {
        int usedAmount = usedMaterialsInOrders[rawMaterial]!
            .fold(0, (sum, item) => sum + item);
        scrapAmounts[rawMaterial] = rawMaterial - usedAmount;
        if (rawMaterial - usedAmount < 500) {
          totalScrap += (rawMaterial - usedAmount);
        }
      } else {
        scrapAmounts[rawMaterial] = rawMaterial;
      }

      print(
          'Raw material $rawMaterial scrap amount: ${scrapAmounts[rawMaterial]}');
    }

    print('Total Scrap: $totalScrap');
  }

  Set<int> getUnusedMaterials() {
    Set<int> unusedMaterials = {};
    for (int rawMaterial in sortedRawMaterials) {
      if (!usedMaterialsInOrders.containsKey(rawMaterial)) {
        unusedMaterials.add(rawMaterial);
      }
    }

    print('Unused Raw Materials: $unusedMaterials');
    return unusedMaterials;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raw Material Order Matcher'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Raw Materials: $rawMaterials'),
            Text('Orders: $orders'),
            Text('Fulfilled Orders: $fulfilledOrders'),
            Text('Total Fulfilled: $totalFulfilled'),
            Text('Total Leftover Raw Material: $totalLeftover'),
            Text('Total Scrap: $totalScrap'),
            ...usedMaterialsInOrders.entries.map((entry) {
              int scrap = scrapAmounts[entry.key]!;
              print(
                  'Raw material ${entry.key} used in orders: ${entry.value} and leftover is $scrap');
              return Text(
                  'Raw material ${entry.key} used in orders: ${entry.value} and leftover is $scrap');
            }),
            if (unusedRawMaterials.isNotEmpty)
              Text('Unused Raw Materials: $unusedRawMaterials'),
          ],
        ),
      ),
    );
  }
}
