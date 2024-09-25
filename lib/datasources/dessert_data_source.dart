import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'package:myapp/models/dessert.dart';
import 'package:myapp/pages/datatable.dart';

class DessertDataSource extends DataTableSource {
  DessertDataSource(this.context) {
    desserts = <Dessert>[
      Dessert('Chocolate Cake', 350, 15.0, 50, 5.0, 200, 4, 2),
      Dessert('Cheesecake', 400, 25.0, 30, 6.0, 150, 5, 1),
      Dessert('Fruit Salad', 120, 1.0, 30, 1.0, 10, 2, 1),
      Dessert('Panna Cotta', 250, 15.0, 20, 3.0, 100, 2, 1),
      Dessert('Brownie', 300, 18.0, 40, 4.0, 150, 3, 2),
      Dessert('Tiramisu', 450, 20.0, 35, 6.0, 100, 2, 1),
      Dessert('Macaron', 200, 5.0, 25, 2.0, 80, 1, 1),
      Dessert('Lemon Tart', 280, 12.0, 45, 3.0, 120, 4, 2),
      Dessert('Cupcake', 320, 15.0, 38, 3.5, 200, 5, 3),
      Dessert('Gelato', 200, 8.0, 30, 4.0, 80, 1, 1),
    ];
  }

  final BuildContext context;

  late List<Dessert> desserts;

  int _selectedCount = 0;

  @override
  DataRow? getRow(int index) {
    final format = NumberFormat.decimalPercentPattern(decimalDigits: 0);
    assert(index >= 0);
    if (index >= desserts.length) return null;

    var logger = Logger();
    logger.i(desserts.length);

    final dessert = desserts[index];

    return DataRow.byIndex(
      index: index,
      selected: dessert.selected,
      onSelectChanged: (value) {
        if (dessert.selected != value) {
          _selectedCount += value! ? 1 : -1;
          assert(_selectedCount >= 0);
          dessert.selected = value;
          notifyListeners();
        }
      },
      cells: [
        DataCell(Text(dessert.name)),
        DataCell(Text('${dessert.calories}')),
        DataCell(Text(dessert.fat.toStringAsFixed(1))),
        DataCell(Text('${dessert.carbs}')),
        DataCell(Text(dessert.protein.toStringAsFixed(1))),
        DataCell(Text('${dessert.sodium}')),
        DataCell(Text(format.format(dessert.calcium / 100))),
        DataCell(Text(format.format(dessert.iron / 100))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => desserts.length;

  @override
  int get selectedRowCount => _selectedCount;

  void selectAll(bool? checked) {
    for (final dessert in desserts) {
      dessert.selected = checked ?? false;
    }
    _selectedCount = checked! ? desserts.length : 0;
    notifyListeners();
  }

  void sort<T>(Comparable<T> Function(Dessert d) getField, bool ascending) {
    desserts.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  void updateSelectedDesserts(RestorableDessertSelections selectedRows) {
    _selectedCount = 0;
    for (var i = 0; i < desserts.length; i += 1) {
      var dessert = desserts[i];
      if (selectedRows.isSelected(i)) {
        dessert.selected = true;
        _selectedCount += 1;
      } else {
        dessert.selected = false;
      }
    }
    notifyListeners();
  }
}
