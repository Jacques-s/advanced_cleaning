import 'package:advancedcleaning/models/account_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountManagementDataSource extends DataTableSource {
  final List<Account> accounts;
  final int rowTotalCount;

  final Function(Account) onView;
  final Function(Account) onEdit;
  final Function(Account) onDelete;

  AccountManagementDataSource({
    required this.accounts,
    required this.rowTotalCount,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= accounts.length) {
      return null;
    }

    final account = accounts[index];
    return DataRow(
      cells: [
        DataCell(Text(account.createdAt.toString())),
        DataCell(Text(account.updatedAt.toString())),
        DataCell(Text(account.title)),
        DataCell(Text(account.status.name.capitalize!)),
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
                  onPressed: () => onView(account),
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
                  onPressed: () => onEdit(account),
                  tooltip: 'Edit Account',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () => onDelete(account),
                  tooltip: 'Delete Account',
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
