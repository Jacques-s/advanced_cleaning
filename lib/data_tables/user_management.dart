import 'package:advancedcleaning/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserManagementDataSource extends DataTableSource {
  final List<AppUser> users;
  final int rowTotalCount;

  final Function(AppUser) onView;
  final Function(AppUser) onEdit;
  final Function(AppUser) onDelete;

  UserManagementDataSource({
    required this.users,
    required this.rowTotalCount,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) {
      return null;
    }

    final user = users[index];
    return DataRow(
      cells: [
        DataCell(Text(user.createdAt.toString())),
        DataCell(Text(user.updatedAt.toString())),
        DataCell(Text(user.fullName)),
        DataCell(Text(user.status.name.capitalize!)),
        DataCell(
          Row(
            children: [
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 10),
              //   child: IconButton(
              //     icon: const Icon(
              //       Icons.visibility,
              //       color: Colors.blue,
              //     ),
              //     onPressed: () => onView(user),
              //     tooltip: 'View Users',
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.amber,
                  ),
                  onPressed: () => onEdit(user),
                  tooltip: 'Edit User',
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 10),
              //   child: IconButton(
              //     icon: const Icon(
              //       Icons.delete,
              //       color: Colors.red,
              //     ),
              //     onPressed: () => onDelete(user),
              //     tooltip: 'Delete User',
              //   ),
              // ),
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
