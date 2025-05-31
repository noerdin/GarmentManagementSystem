import 'package:flutter/material.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import '../../ui/ui_helpers.dart';
import 'auth_viewmodel.dart';
import 'package:stacked/stacked.dart';

class LoginView extends StackedView<AuthViewModel> {
  const LoginView({super.key});

  @override
  Widget builder(
      BuildContext context,
      AuthViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and App Title
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.inventory_2_rounded,
                        size: 80,
                        color: kcPrimaryColor,
                      ),
                      verticalSpaceMedium,
                      Text(
                        'Garment Production',
                        style: heading1Style(context),
                        textAlign: TextAlign.center,
                      ),
                      verticalSpaceSmall,
                      Text(
                        'Management System',
                        style: heading3Style(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                verticalSpaceLarge,

                // Login Form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: defaultBoxShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Login',
                        style: heading3Style(context),
                      ),
                      verticalSpaceMedium,

                      // Error Message
                      if (viewModel.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kcErrorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: kcErrorColor,
                              ),
                              horizontalSpaceSmall,
                              Expanded(
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: const TextStyle(
                                    color: kcErrorColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        verticalSpaceMedium,
                      ],

                      // Email Field
                      TextField(
                        onChanged: viewModel.setEmail,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onTap: viewModel.clearErrorMessage,
                      ),
                      verticalSpaceMedium,

                      // Password Field
                      TextField(
                        onChanged: viewModel.setPassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        onTap: viewModel.clearErrorMessage,
                      ),
                      verticalSpaceSmall,

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: viewModel.resetPassword,
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(
                              color: kcPrimaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      verticalSpaceMedium,

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: viewModel.isBusy ? null : viewModel.login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kcPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: viewModel.isBusy
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                              : Text(
                            'Login',
                            style: buttonTextStyle(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                verticalSpaceLarge,

                // Footer Text
                Text(
                  '© 2025 Garment Production Management System',
                  style: captionStyle(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  AuthViewModel viewModelBuilder(BuildContext context) => AuthViewModel();
}
