import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/account_controller.dart';
import 'package:advancedcleaning/data_tables/account_management.dart';
import 'package:advancedcleaning/models/account_model.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:advancedcleaning/shared_widgets/app_drawer.dart';
import 'package:advancedcleaning/shared_widgets/general_dropdown_field.dart';
import 'package:advancedcleaning/shared_widgets/general_submit_button.dart';
import 'package:advancedcleaning/shared_widgets/general_text_field.dart';
import 'package:advancedcleaning/shared_widgets/management_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountsScreenDesktop extends GetView<AccountController> {
  const AccountsScreenDesktop({super.key});

  void viewAccount(Account account) {
    controller.authController.setCurrentAccount = account;
    Get.toNamed(Routes.SITE_MANAGEMENT);
  }

  void editAccount(Account account) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    controller.titleController.text = account.title;
    controller.statusController.text = account.status.name;

    Get.dialog(
      Obx(
        () => ManagementDialog(
            formKey: formKey,
            dialogTitle: 'Editing: ${account.title}',
            submissionLabel: 'Edit Account',
            isLoading: controller.isLoading.value,
            onSubmission: () async {
              if (formKey.currentState!.validate()) {
                await controller.updateAccount(account);
              }
            },
            formFields: [
              GeneralTextFormField(
                  controller: controller.titleController,
                  label: 'Account Title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }),
              GeneralDropdownFormField(
                  label: 'Status',
                  options: Status.values
                      .map((status) =>
                          {'id': status.name, 'title': status.name.capitalize!})
                      .toList(),
                  initialSelection: account.status.name,
                  onSelect: (value) {
                    print(value);
                    controller.statusController.text = value ?? '';
                  },
                  validator: null)
            ]),
      ),
    );
  }

  void deleteAccount(Account account) {
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Obx(
        () => ManagementDialog(
          formKey: formKey,
          dialogTitle: 'Delete ${account.title}',
          submissionLabel: 'Delete',
          isLoading: controller.isLoading.value,
          onSubmission: () async {
            if (formKey.currentState!.validate()) {
              await controller.deleteAccount(account);
            }
          },
          formFields: const [
            Text(
              'Are you sure you want to delete this account? It cannot be undone.',
            ),
          ],
        ),
      ),
    );
  }

  void createAccount() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    controller.titleController.text = '';
    controller.statusController.text = Status.active.name;

    Get.dialog(
      Obx(
        () => ManagementDialog(
            formKey: formKey,
            dialogTitle: 'Create An Account',
            submissionLabel: 'Create Account',
            isLoading: controller.isLoading.value,
            onSubmission: () async {
              if (formKey.currentState!.validate()) {
                await controller.createAccount();
              }
            },
            formFields: [
              GeneralTextFormField(
                  controller: controller.titleController,
                  label: 'Account Title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: appPrimaryColor,
              foregroundColor: Colors.white,
              title: const Text(
                'Accounts',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            drawer: AppDrawer(
              activePage: "/accounts",
            ),
            body: Padding(
              padding: EdgeInsets.all(Get.width * 0.02),
              child: Obx(
                () {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (controller.accounts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No data yet'),
                          SizedBox(height: Get.height * 0.01),
                          GeneralSubmitButton(
                              onPress: () {
                                createAccount();
                              },
                              label: 'New Acccount'),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox(
                      width: double.infinity,
                      height: Get.height * 0.9,
                      child: SingleChildScrollView(
                        child: PaginatedDataTable(
                          header: const Text('Accounts'),
                          actions: [
                            TextButton.icon(
                              onPressed: () {
                                createAccount();
                              },
                              label: const Text('New Account'),
                              icon: const Icon(Icons.add),
                            )
                          ],
                          initialFirstRowIndex: controller.lastIndex.value,
                          onPageChanged: (index) {
                            if (controller.accounts.length <
                                controller.totalAccounts.value) {
                              controller.lastIndex.value =
                                  controller.accounts.length;
                              controller.fetchAccounts(nextPage: true);
                            }
                          },
                          rowsPerPage: controller.pageSize,
                          availableRowsPerPage: const [10],
                          onRowsPerPageChanged: (value) {
                            // You might want to handle changing rows per page here
                          },
                          sortColumnIndex: [
                            'createdAt',
                            'updateddAt',
                            'title',
                            'status'
                          ].indexOf(controller.sortColumn.value),
                          sortAscending: controller.sortAscending.value,
                          columns: [
                            DataColumn(
                              label: const Text('Created At'),
                              onSort: (columnIndex, ascending) =>
                                  controller.sort('createdAt', ascending),
                            ),
                            DataColumn(
                              label: const Text('Updated At'),
                              onSort: (columnIndex, ascending) =>
                                  controller.sort('updateddAt', ascending),
                            ),
                            DataColumn(
                              label: const Text('Title'),
                              onSort: (columnIndex, ascending) =>
                                  controller.sort('title', ascending),
                            ),
                            DataColumn(
                              label: const Text('Status'),
                              onSort: (columnIndex, ascending) =>
                                  controller.sort('status', ascending),
                            ),
                            const DataColumn(
                              label: Text('Actions'),
                            ),
                          ],
                          source: AccountManagementDataSource(
                            accounts: controller.accounts,
                            rowTotalCount: controller.totalAccounts.value,
                            onView: (account) => viewAccount(account),
                            onEdit: (account) => editAccount(account),
                            onDelete: (account) => deleteAccount(account),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            )));
  }
}
