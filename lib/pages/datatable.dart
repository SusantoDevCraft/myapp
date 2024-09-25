import 'package:flutter/material.dart';
import 'package:myapp/datasources/dessert_data_source.dart';
import 'package:myapp/models/dessert.dart';

class MyDatatable extends StatefulWidget {
  const MyDatatable({super.key});

  @override
  _MyDatatableState createState() => _MyDatatableState();
}

class RestorableDessertSelections extends RestorableProperty<Set<int>> {
  // The set of indices of selected dessert rows
  Set<int> _dessertSelections = {};

  /// Returns whether or not a dessert row is selected by index.
  bool isSelected(int index) => _dessertSelections.contains(index);

  /// Takes a list of [Dessert]s and saves the row indices of selected rows
  /// into a [Set].
  void setDessertSelections(List<Dessert> desserts) {
    final updatedSet = <int>{};
    for (var i = 0; i < desserts.length; i += 1) {
      var dessert = desserts[i];
      if (dessert.selected) {
        updatedSet.add(i);
      }
    }
    _dessertSelections = updatedSet;
    notifyListeners();
  }

  @override
  Set<int> createDefaultValue() => _dessertSelections;

  @override
  Set<int> fromPrimitives(Object? data) {
    final selectedItemIndices = data as List<dynamic>;
    _dessertSelections = {
      ...selectedItemIndices.map<int>((dynamic id) => id as int),
    };
    return _dessertSelections;
  }

  @override
  void initWithValue(Set<int> value) {
    _dessertSelections = value;
  }

  @override
  Object toPrimitives() => _dessertSelections.toList();
}

class _MyDatatableState extends State<MyDatatable> with RestorationMixin {
  final RestorableDessertSelections _dessertSelections =
      RestorableDessertSelections();

  final RestorableInt _rowIndex = RestorableInt(0);
  final RestorableInt _rowsPerPage =
      RestorableInt(PaginatedDataTable.defaultRowsPerPage);
  final RestorableBool _sortAscending = RestorableBool(true);
  final RestorableIntN _sortColumnIndex = RestorableIntN(null);

  // Declare a _DessertDataSource instance and initialize it to null
  DessertDataSource? _dessertsDataSource;

  // Set restoration ID
  @override
  String get restorationId => 'data_table_demo';

  // Register restorable properties for restoration
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_dessertSelections, 'selected_row_indices');
    registerForRestoration(_rowIndex, 'current_row_index');
    registerForRestoration(_rowsPerPage, 'rows_per_page');
    registerForRestoration(_sortAscending, 'sort_ascending');
    registerForRestoration(_sortColumnIndex, 'sort_column_index');

    // Initialize _dessertsDataSource if it is null
    _dessertsDataSource ??= DessertDataSource(context);

    // Sort the data source according to the sort column index
    switch (_sortColumnIndex.value) {
      case 0:
        _dessertsDataSource!.sort<String>((d) => d.name, _sortAscending.value);
        break;
      case 1:
        _dessertsDataSource!.sort<num>((d) => d.calories, _sortAscending.value);
        break;
      case 2:
        _dessertsDataSource!.sort<num>((d) => d.fat, _sortAscending.value);
        break;
      case 3:
        _dessertsDataSource!.sort<num>((d) => d.carbs, _sortAscending.value);
        break;
      case 4:
        _dessertsDataSource!.sort<num>((d) => d.protein, _sortAscending.value);
        break;
      case 5:
        _dessertsDataSource!.sort<num>((d) => d.sodium, _sortAscending.value);
        break;
      case 6:
        _dessertsDataSource!.sort<num>((d) => d.calcium, _sortAscending.value);
        break;
      case 7:
        _dessertsDataSource!.sort<num>((d) => d.iron, _sortAscending.value);
        break;
    }

    // Update the selection of desserts
    _dessertsDataSource!.updateSelectedDesserts(_dessertSelections);

    // Add listener to _dessertsDataSource to update selected dessert row
    _dessertsDataSource!.addListener(_updateSelectedDessertRowListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize _dessertsDataSource if it is null
    _dessertsDataSource ??= DessertDataSource(context);

    // Add listener to _dessertsDataSource to update selected dessert row
    _dessertsDataSource!.addListener(_updateSelectedDessertRowListener);
  }

  @override
  void dispose() {
    // Dispose of the _rowsPerPage stream subscription
    _rowsPerPage.dispose();

    // Dispose of the _sortColumnIndex stream subscription
    _sortColumnIndex.dispose();

    // Dispose of the _sortAscending stream subscription
    _sortAscending.dispose();

    // Remove the listener that updates the selected dessert row
    // from the _dessertsDataSource
    _dessertsDataSource!.removeListener(_updateSelectedDessertRowListener);

    // Dispose of the _dessertsDataSource stream subscription
    _dessertsDataSource!.dispose();
    super.dispose();
  }

  // Update the selected dessert row
  void _updateSelectedDessertRowListener() {
    _dessertSelections.setDessertSelections(_dessertsDataSource!.desserts);
  }

  // Sort the data source
  void _sort<T>(
    Comparable<T> Function(Dessert d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _dessertsDataSource!.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex.value = columnIndex;
      _sortAscending.value = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Data Table'),
      ),
      body: Scrollbar(
        child: ListView(
          children: [
            PaginatedDataTable(
              header: const Text(
                  'Nutrition'), // Set the header text of the data table

              // FIXME: error disini
              rowsPerPage: _rowsPerPage.value,
              initialFirstRowIndex: _rowIndex.value,
              sortColumnIndex: _sortColumnIndex.value,
              sortAscending: _sortAscending.value,
              onRowsPerPageChanged: (value) {
                setState(() {
                  _rowsPerPage.value = value!;
                });
              },
              onPageChanged: (rowIndex) {
                setState(() {
                  _rowIndex.value = rowIndex;
                });
              },
              onSelectAll: _dessertsDataSource!
                  .selectAll, // Set the select all callback of the data table

              columns: [
                DataColumn(
                  label: const Text('Dessert 1 serving'),
                  onSort: (int columnIndex, bool ascending) =>
                      _sort<String>((d) => d.name, columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text('Calories'),
                  onSort: (int columnIndex, bool ascending) =>
                      _sort<num>((d) => d.calories, columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text('Fat (g)'),
                  onSort: (int columnIndex, bool ascending) =>
                      _sort<num>((d) => d.fat, columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text('Carbs (g)'),
                  onSort: (int columnIndex, bool ascending) {
                    _sort<num>((d) => d.carbs, columnIndex, ascending);
                  },
                ),
                DataColumn(
                  label: const Text('Protein (g)'),
                  onSort: (int columnIndex, bool ascending) {
                    _sort<num>((d) => d.protein, columnIndex, ascending);
                  },
                ),
                DataColumn(
                  label: const Text('Sodium (mg)'),
                  onSort: (int columnIndex, bool ascending) {
                    _sort<num>((d) => d.sodium, columnIndex, ascending);
                  },
                ),
                DataColumn(
                  label: const Text('Calcium (%)'),
                  onSort: (int columnIndex, bool ascending) {
                    _sort<num>((d) => d.calcium, columnIndex, ascending);
                  },
                ),
                DataColumn(
                  label: const Text('Iron (%)'),
                  onSort: (int columnIndex, bool ascending) {
                    _sort<num>((d) => d.iron, columnIndex, ascending);
                  },
                ),
              ],
              source: _dessertsDataSource!,
            )
          ],
        ),
      ),
    );
  }
}
