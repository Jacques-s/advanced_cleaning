import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_constants.dart';
import 'general_submit_button.dart';

class ManagementDialog extends StatelessWidget {
  const ManagementDialog(
      {required this.formKey,
      required this.dialogTitle,
      required this.submissionLabel,
      required this.onSubmission,
      required this.formFields,
      required this.isLoading,
      super.key});

  final Key formKey;
  final String dialogTitle;
  final String submissionLabel;
  final Function onSubmission;
  final List<Widget> formFields;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    dialogTitle,
                    style: const TextStyle(
                        color: appPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  )),
              ...formFields,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Get.width * 0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GeneralSubmitButton(
                        backgroundColor: appDangerColor,
                        onPress: () {
                          if (kIsWeb) {
                            Navigator.pop(context);
                          } else {
                            Get.back();
                          }
                        },
                        label: 'Cancel'),
                    GeneralSubmitButton(
                      onPress: () => onSubmission(),
                      label: submissionLabel,
                      isLoading: isLoading,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
