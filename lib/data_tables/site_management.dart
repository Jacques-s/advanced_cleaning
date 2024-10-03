import 'package:advancedcleaning/models/site_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SiteManagementDataSource extends DataTableSource {
  final List<Site> sites;
  final int rowTotalCount;

  final Function(Site) onView;
  final Function(Site) onEdit;
  final Function(Site) onDelete;

  SiteManagementDataSource({
    required this.sites,
    required this.rowTotalCount,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= sites.length) {
      return null;
    }

    final site = sites[index];
    return DataRow(
      cells: [
        DataCell(Text(site.createdAt.toString())),
        DataCell(Text(site.updatedAt.toString())),
        DataCell(Text(site.title)),
        DataCell(Text(site.status.name.capitalize!)),
        DataCell(
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.visibility,
                    color: Colors.blue,
                  ),
                  onPressed: () => onView(site),
                  tooltip: 'View Sites',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.amber,
                  ),
                  onPressed: () => onEdit(site),
                  tooltip: 'Edit Site',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () => onDelete(site),
                  tooltip: 'Delete Site',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rowTotalCount;

  @override
  int get selectedRowCount => 0;
}
