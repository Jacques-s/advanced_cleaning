import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/account_controller.dart';
import 'package:advancedcleaning/controllers/site_controller.dart';
import 'package:advancedcleaning/controllers/user_controller.dart';
import 'package:advancedcleaning/data_tables/user_management.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:advancedcleaning/models/user_model.dart';
import 'package:advancedcleaning/shared_widgets/app_drawer.dart';
import 'package:advancedcleaning/shared_widgets/general_dropdown_field.dart';
import 'package:advancedcleaning/shared_widgets/general_multi_dropdown_field.dart';
import 'package:advancedcleaning/shared_widgets/general_submit_button.dart';
import 'package:advancedcleaning/shared_widgets/general_text_field.dart';
import 'package:advancedcleaning/shared_widgets/management_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsersScreenDesktop extends GetView<UserManagementController> {
  const UsersScreenDesktop({super.key});

  void viewUser(AppUser user) {
    // controller.authController.setCurrentUser = user;
    // Get.toNamed(Routes.SITE_MANAGEMENT);
  }

  void deleteUser(AppUser user) {
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Obx(
        () => ManagementDialog(
          formKey: formKey,
          dialogTitle: 'Delete ${user.firstName}',
          submissionLabel: 'Delete',
          isLoading: controller.isLoading.value,
          onSubmission: () async {
            if (formKey.currentState!.validate()) {
              await controller.deleteUser(user);
            }
          },
          formFields: const [
            Text(
              'Are you sure you want to delete this user? It cannot be undone.',
            ),
          ],
        ),
      ),
    );
  }

  void createEditUser(AppUser? user) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final accountController = AccountController();
    final siteController = SiteController();
    final accountOptions = RxList<Map<String, String>>.empty();
    final siteOptions = RxList<Map<String, String>>.empty();

    if (user == null) {
      controller.firstNameController.text = '';
      controller.surnameController.text = '';
      controller.emailController.text = '';
      controller.cellNumebrController.text = '';
      controller.statusController.text = Status.active.name;

      controller.selectedRole.value = '';
      controller.selectedAccountId.value = '';
      controller.selectedSiteIds.value = [];

      controller.passwordController.text = '';
      controller.confirmPasswordController.text = '';
    } else {
      controller.firstNameController.text = user.firstName;
      controller.surnameController.text = user.surname;
      controller.emailController.text = user.email;
      controller.cellNumebrController.text = user.cellNumber ?? '';
      controller.statusController.text = user.status.name;

      controller.selectedRole.value = user.role.name;
      controller.selectedAccountId.value = user.accountId ?? '';
      controller.selectedSiteIds.value = user.siteIds;

      if (user.role != UserRole.admin) {
        accountOptions.value = [
          {'id': '', 'title': 'select account'},
          ...await accountController.fetchAllMappedAccounts()
        ];
      }

      if (user.accountId != null) {
        siteOptions.value = [
          ...await siteController.fetchAllMappedSites(accountID: user.accountId)
        ];
      }
    }

    Get.dialog(
      Obx(
        () => ManagementDialog(
            formKey: formKey,
            dialogTitle: user == null
                ? 'Create User'
                : 'Editing: ${user.firstName} ${user.surname}',
            submissionLabel: user == null ? 'Create User' : 'Update User',
            isLoading: controller.isLoading.value,
            onSubmission: () async {
              if (formKey.currentState!.validate()) {
                if (user == null) {
                  await controller.createUser();
                } else {
                  await controller.updateUser(user);
                }
              }
            },
            formFields: [
              GeneralTextFormField(
                  controller: controller.firstNameController,
                  label: 'Firstname',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }),
              GeneralTextFormField(
                  controller: controller.surnameController,
                  label: 'Surname',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }),
              GeneralTextFormField(
                  controller: controller.emailController,
                  label: 'Email',
                  validator: (value) {
                    final regex = RegExp(emailPattern);
                    if (value == null ||
                        value.isEmpty ||
                        !regex.hasMatch(value)) {
                      return 'This field is not valid';
                    }
                    return null;
                  }),
              if (user == null)
                Column(
                  children: [
                    const Divider(),
                    GeneralTextFormField(
                        controller: controller.passwordController,
                        label: 'Password',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        }),
                    GeneralTextFormField(
                        controller: controller.confirmPasswordController,
                        label: 'Confirm Password',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          } else if (value != controller.password) {
                            return 'The passwords do not match';
                          }
                          return null;
                        }),
                    const Divider(),
                  ],
                ),
              GeneralTextFormField(
                  controller: controller.cellNumebrController,
                  label: 'Cell Number',
                  validator: null),
              GeneralDropdownFormField(
                label: 'Role',
                options: [
                  const {'id': '', 'title': 'select role'},
                  ...UserRole.values.map((role) =>
                      {'id': role.name, 'title': role.name.capitalize!})
                ],
                initialSelection: controller.selectedRole.value,
                onSelect: (value) async {
                  controller.selectedRole.value = value ?? '';
                  if (controller.selectedRole.value != UserRole.admin.name) {
                    accountOptions.value = [
                      {'id': '', 'title': 'select account'},
                      ...await accountController.fetchAllMappedAccounts()
                    ];
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
              Obx(() {
                if (accountController.isLoading.isTrue) {
                  return const CircularProgressIndicator();
                } else if (controller.selectedRole.isNotEmpty &&
                    controller.selectedRole.value != UserRole.admin.name) {
                  return Column(
                    children: [
                      GeneralDropdownFormField(
                          label: "Account",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is required';
                            }
                            return null;
                          },
                          onSelect: (value) async {
                            controller.selectedAccountId.value = value ?? '';
                            controller.selectedSiteIds.value = [];

                            if (value != null && value.isNotEmpty) {
                              siteOptions.value = [
                                ...await siteController.fetchAllMappedSites(
                                    accountID: value)
                              ];
                            } else {
                              siteOptions.value = [];
                            }
                          },
                          initialSelection: controller.selectedAccountId.value,
                          options: accountOptions),
                      if (siteOptions.isNotEmpty)
                        GeneralMultiSelectDropdownFormField(
                            label: 'Sites',
                            initialSelections: controller.selectedSiteIds,
                            options: siteOptions,
                            onSelect: (results) {
                              controller.selectedSiteIds.value =
                                  results ?? List.empty();
                            },
                            validator: (values) {
                              if (values == null || values.isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            })
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              }),
              GeneralDropdownFormField(
                  label: 'Status',
                  options: Status.values
                      .map((status) =>
                          {'id': status.name, 'title': status.name.capitalize!})
                      .toList(),
                  initialSelection: Status.active.name,
                  onSelect: (value) {
                    controller.statusController.text = value ?? '';
                  },
                  validator: null)
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
                'Users',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            drawer: AppDrawer(
              activePage: "/users",
            ),
            body: Padding(
              padding: EdgeInsets.all(Get.width * 0.02),
              child: Obx(
                () {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (controller.users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No data yet'),
                          SizedBox(height: Get.height * 0.01),
                          GeneralSubmitButton(
                              onPress: () {
                                createEditUser(null);
                              },
                              label: 'New User'),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox(
                      width: double.infinity,
                      height: Get.height * 0.9,
                      child: SingleChildScrollView(
                        child: PaginatedDataTable(
                          header: const Text('Users'),
                          actions: [
                            TextButton.icon(
                              onPressed: () {
                                createEditUser(null);
                              },
                              label: const Text('New User'),
                              icon: const Icon(Icons.add),
                            )
                          ],
                          initialFirstRowIndex: controller.lastIndex.value,
                          onPageChanged: (index) {
                            if (controller.users.length <
                                controller.totalUsers.value) {
                              controller.lastIndex.value =
                                  controller.users.length;
                              controller.fetchUsers(nextPage: true);
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
                          source: UserManagementDataSource(
                            users: controller.users,
                            rowTotalCount: controller.totalUsers.value,
                            onView: (user) => viewUser(user),
                            onEdit: (user) => createEditUser(user),
                            onDelete: (user) => deleteUser(user),
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
